import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/presentation/app.dart';
import 'package:tic_tac_toe/presentation/home/home_page.dart';
import 'package:tic_tac_toe/presentation/providers.dart';

import '../helpers/in_memory_score_repository.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) => tester.pumpWidget(
    ProviderScope(
      overrides: [
        scoreRepositoryProvider.overrideWithValue(InMemoryScoreRepository()),
      ],
      child: const TicTacToeApp(),
    ),
  );

  group('TicTacToeApp', () {
    testWidgets('opens on the home page', (tester) async {
      await pumpApp(tester);

      expect(find.byType(HomePage), findsOneWidget);
      expect(find.text('Tic-Tac-Toe'), findsOneWidget);
    });

    testWidgets('speaks French on French devices', (tester) async {
      tester.platformDispatcher.localesTestValue = const [Locale('fr')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      await pumpApp(tester);

      expect(find.text('Morpion'), findsOneWidget);
      expect(find.text('Commencer'), findsOneWidget);
    });
  });
}
