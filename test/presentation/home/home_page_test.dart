import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/domain/entities/difficulty.dart';
import 'package:tic_tac_toe/domain/entities/game_settings.dart';
import 'package:tic_tac_toe/domain/entities/mark.dart';
import 'package:tic_tac_toe/domain/entities/score.dart';
import 'package:tic_tac_toe/presentation/game/game_page.dart';
import 'package:tic_tac_toe/presentation/home/home_page.dart';
import 'package:tic_tac_toe/presentation/providers.dart';

import '../../helpers/fixed_random.dart';
import '../../helpers/in_memory_score_repository.dart';
import '../../helpers/pump_app.dart';

void main() {
  group('HomePage', () {
    testWidgets('shows the stored score', (tester) async {
      await tester.pumpApp(
        const HomePage(),
        scoreRepository: InMemoryScoreRepository(
          const Score(wins: 3, losses: 5, draws: 7),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('3'), findsOneWidget);
      expect(find.text('Wins'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('Losses'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('Draws'), findsOneWidget);
    });

    testWidgets('tells the player when the score cannot load', (tester) async {
      await tester.pumpApp(
        const HomePage(),
        scoreRepository: InMemoryScoreRepository()..error = Exception('disk'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Your score could not be loaded.'), findsOneWidget);
    });

    testWidgets('starts a game as X on medium by default', (tester) async {
      await tester.pumpApp(const HomePage());

      await tester.tap(find.text('Start game'));
      await tester.pumpAndSettle();

      expect(
        tester.widget<GamePage>(find.byType(GamePage)).settings,
        const GameSettings(humanMark: Mark.x, difficulty: Difficulty.medium),
      );
    });

    testWidgets('starts a game with the selected settings', (tester) async {
      await tester.pumpApp(const HomePage());

      await tester.tap(find.text('O'));
      await tester.tap(find.text('Hard'));
      await tester.tap(find.text('Start game'));
      await tester.pumpAndSettle();

      expect(
        tester.widget<GamePage>(find.byType(GamePage)).settings,
        const GameSettings(humanMark: Mark.o, difficulty: Difficulty.hard),
      );
    });

    testWidgets('shows the updated score after a game', (tester) async {
      const delay = Duration(milliseconds: 300);
      await tester.pumpApp(
        const HomePage(),
        overrides: [
          randomProvider.overrideWithValue(FixedRandom()),
          cpuMoveDelayProvider.overrideWithValue(delay),
        ],
      );
      await tester.tap(find.text('Easy'));
      await tester.tap(find.text('Start game'));
      await tester.pumpAndSettle();

      // Human X: 3, 4, 5. The easy CPU answers 0, then 1.
      for (final index in [3, 4, 5]) {
        await tester.tap(find.byKey(ValueKey('cell-$index')));
        await tester.pump(delay);
        await tester.pumpAndSettle();
      }
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });
  });
}
