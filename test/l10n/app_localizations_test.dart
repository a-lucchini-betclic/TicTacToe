import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/l10n/app_localizations.dart';

void main() {
  group('French typography', () {
    final fr = lookupAppLocalizations(const Locale('fr'));

    test('puts a narrow no-break space before "!"', () {
      expect(fr.statusYouWon, 'Vous avez gagné !');
    });

    test('puts a no-break space before ":"', () {
      expect(fr.cellLabel(1, 2, 'X'), 'Ligne 1, colonne 2 : X');
    });
  });
}
