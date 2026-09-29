import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tic_tac_toe/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a full game against the hard CPU is recorded as a loss', (
    tester,
  ) async {
    // Start from a clean score on the test device.
    await (await SharedPreferences.getInstance()).clear();
    await tester.pumpWidget(await app.createApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Hard'));
    await tester.tap(find.text('Start game'));
    await tester.pumpAndSettle();

    // The CPU answers 0 with 4 and blocks 1 with 2; 3 leaves 6 open.
    await _playAndWaitFor(tester, 0, find.text('Your turn'));
    await _playAndWaitFor(tester, 1, find.text('Your turn'));
    await _playAndWaitFor(tester, 3, find.text('CPU wins'));

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Losses'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });
}

/// Taps the cell at [index], then pumps real frames until [expected] shows.
Future<void> _playAndWaitFor(
  WidgetTester tester,
  int index,
  Finder expected,
) async {
  await tester.tap(find.byKey(ValueKey('cell-$index')));
  await tester.pump();
  final deadline = DateTime.now().add(const Duration(seconds: 5));
  while (expected.evaluate().isEmpty) {
    if (DateTime.now().isAfter(deadline)) {
      throw TimeoutException('Timed out waiting for $expected');
    }
    await tester.pump(const Duration(milliseconds: 100));
  }
}
