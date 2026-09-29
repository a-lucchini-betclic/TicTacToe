import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Enforces the Clean Architecture dependency rule on `import` directives.
void main() {
  group('Dependency rule', () {
    test('the domain layer is pure Dart and knows no other layer', () {
      expect(
        _forbiddenImports('lib/domain', [
          'package:flutter',
          'package:shared_preferences',
          'package:tic_tac_toe/data',
          'package:tic_tac_toe/l10n',
          'package:tic_tac_toe/presentation',
        ]),
        isEmpty,
      );
    });

    test('the data layer does not know the presentation layer', () {
      expect(
        _forbiddenImports('lib/data', [
          'package:flutter_riverpod',
          'package:tic_tac_toe/l10n',
          'package:tic_tac_toe/presentation',
        ]),
        isEmpty,
      );
    });

    test('the presentation layer does not know the data layer', () {
      expect(
        _forbiddenImports('lib/presentation', [
          'package:shared_preferences',
          'package:tic_tac_toe/data',
        ]),
        isEmpty,
      );
    });
  });
}

final _import = RegExp(r"^\s*(?:import|export)\s+'([^']+)'", multiLine: true);

/// Lists `file imports uri` for every import or export under [directory] that
/// starts with one of the [forbidden] prefixes.
List<String> _forbiddenImports(String directory, List<String> forbidden) {
  final files = Directory(directory)
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList();
  expect(files, isNotEmpty, reason: 'no Dart file found in $directory');

  return [
    for (final file in files)
      for (final match in _import.allMatches(file.readAsStringSync()))
        if (forbidden.any(match.group(1)!.startsWith))
          '${file.path} imports ${match.group(1)}',
  ];
}
