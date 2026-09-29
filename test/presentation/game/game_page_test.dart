import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/domain/entities/difficulty.dart';
import 'package:tic_tac_toe/domain/entities/game_settings.dart';
import 'package:tic_tac_toe/domain/entities/mark.dart';
import 'package:tic_tac_toe/domain/entities/score.dart';
import 'package:tic_tac_toe/presentation/game/game_page.dart';
import 'package:tic_tac_toe/presentation/providers.dart';

import '../../helpers/fixed_random.dart';
import '../../helpers/in_memory_score_repository.dart';
import '../../helpers/pump_app.dart';

const _delay = Duration(milliseconds: 300);

/// On easy, FixedRandom(0) makes the CPU always play the first empty cell.
const _humanIsX = GameSettings(humanMark: Mark.x, difficulty: Difficulty.easy);
const _humanIsO = GameSettings(humanMark: Mark.o, difficulty: Difficulty.easy);

void main() {
  group('GamePage', () {
    late InMemoryScoreRepository repository;

    setUp(() => repository = InMemoryScoreRepository());

    Future<void> pumpGame(WidgetTester tester, GameSettings settings) =>
        tester.pumpApp(
          GamePage(settings: settings),
          scoreRepository: repository,
          overrides: [
            randomProvider.overrideWithValue(FixedRandom()),
            cpuMoveDelayProvider.overrideWithValue(_delay),
          ],
        );

    /// Taps a cell, then lets the CPU answer and the animations finish.
    Future<void> playTurn(WidgetTester tester, int index) async {
      await tester.tap(find.byKey(ValueKey('cell-$index')));
      await tester.pump(_delay);
      await tester.pumpAndSettle();
    }

    testWidgets('shows the settings and lets X start', (tester) async {
      await pumpGame(tester, _humanIsX);

      expect(find.text('You play X · Easy'), findsOneWidget);
      expect(find.text('Your turn'), findsOneWidget);
      expect(find.text('Play again'), findsNothing);
    });

    testWidgets('the CPU answers after a short delay', (tester) async {
      await pumpGame(tester, _humanIsX);

      await tester.tap(find.byKey(const ValueKey('cell-4')));
      await tester.pump();

      expect(find.text('CPU is thinking…'), findsOneWidget);
      expect(find.text('O'), findsNothing);

      await tester.pump(_delay);
      await tester.pumpAndSettle();

      expect(find.text('O'), findsOneWidget);
      expect(find.text('Your turn'), findsOneWidget);
    });

    testWidgets('the CPU opens when the human plays O', (tester) async {
      await pumpGame(tester, _humanIsO);

      expect(find.text('CPU is thinking…'), findsOneWidget);

      await tester.pump(_delay);
      await tester.pumpAndSettle();

      expect(find.text('X'), findsOneWidget);
      expect(find.text('Your turn'), findsOneWidget);
    });

    testWidgets('announces the win, records it and offers a rematch', (
      tester,
    ) async {
      await pumpGame(tester, _humanIsX);

      // Human X: 3, 4, 5. CPU O answers 0, then 1.
      await playTurn(tester, 3);
      await playTurn(tester, 4);
      await playTurn(tester, 5);

      expect(find.text('You won!'), findsOneWidget);
      expect(repository.score, const Score(wins: 1));

      await tester.tap(find.text('Play again'));
      await tester.pumpAndSettle();

      expect(find.text('Your turn'), findsOneWidget);
      expect(find.text('X'), findsNothing);
      expect(find.text('Play again'), findsNothing);
    });
  });
}
