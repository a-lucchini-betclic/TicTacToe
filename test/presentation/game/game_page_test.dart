import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/domain/entities/board.dart';
import 'package:tic_tac_toe/domain/entities/difficulty.dart';
import 'package:tic_tac_toe/domain/entities/game_settings.dart';
import 'package:tic_tac_toe/domain/entities/mark.dart';
import 'package:tic_tac_toe/domain/entities/score.dart';
import 'package:tic_tac_toe/presentation/game/game_page.dart';
import 'package:tic_tac_toe/presentation/game/widgets/board_view.dart';
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
      final cell = find.byKey(ValueKey('cell-$index'));
      // On small screens the board may be scrolled out of view.
      await tester.ensureVisible(cell);
      await tester.tap(cell);
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

    group('layout', () {
      /// A phone held sideways.
      const landscape = Size(874, 402);
      const portrait = Size(402, 874);

      void useScreen(WidgetTester tester, Size size, {double textScale = 1}) {
        tester.view
          ..physicalSize = size
          ..devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = textScale;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      }

      /// Human X wins on 3, 4, 5, the CPU (first empty cell) playing 0 and 1.
      Future<void> playToTheEnd(WidgetTester tester) async {
        await playTurn(tester, 3);
        await playTurn(tester, 4);
        await playTurn(tester, 5);
        expect(find.text('Play again'), findsOneWidget);
      }

      testWidgets('keeps every cell tappable in landscape', (tester) async {
        useScreen(tester, landscape);
        await pumpGame(tester, _humanIsX);

        expect(tester.takeException(), isNull);
        final board = tester.getRect(find.byType(BoardView));
        expect(board.width, board.height);
        for (var index = 0; index < Board.cellCount; index++) {
          final size = tester.getSize(find.byKey(ValueKey('cell-$index')));
          expect(size.width, greaterThanOrEqualTo(48));
          expect(size.height, greaterThanOrEqualTo(48));
        }
      });

      testWidgets('puts the status beside the board in landscape', (
        tester,
      ) async {
        useScreen(tester, landscape);
        await pumpGame(tester, _humanIsX);

        final board = tester.getRect(find.byType(BoardView));
        final status = tester.getRect(find.text('Your turn'));
        expect(status.left, greaterThanOrEqualTo(board.right));
      });

      testWidgets('survives large text in landscape', (tester) async {
        useScreen(tester, landscape, textScale: 2);
        await pumpGame(tester, _humanIsX);
        await playToTheEnd(tester);

        expect(tester.takeException(), isNull);
        expect(find.text('You won!'), findsOneWidget);
        final button = tester.getSize(find.byType(FilledButton));
        expect(button.height, greaterThanOrEqualTo(48));
        expect(
          tester.getSize(find.byKey(const ValueKey('cell-0'))).shortestSide,
          greaterThanOrEqualTo(48),
        );
      });

      testWidgets('lets the Play again button grow with the text', (
        tester,
      ) async {
        useScreen(tester, portrait, textScale: 3);
        await pumpGame(tester, _humanIsX);
        await playToTheEnd(tester);

        expect(tester.takeException(), isNull);
        // The slot grows with the text instead of capping the button at 48.
        expect(
          tester.getSize(find.byType(FilledButton)).height,
          greaterThan(48),
        );
      });

      testWidgets('survives large text in portrait', (tester) async {
        useScreen(tester, portrait, textScale: 2);
        await pumpGame(tester, _humanIsX);
        await playToTheEnd(tester);

        expect(tester.takeException(), isNull);
        expect(find.text('You won!'), findsOneWidget);
        expect(
          tester.getSize(find.byType(FilledButton)).height,
          greaterThanOrEqualTo(48),
        );
      });

      /// A small phone, such as a first-generation iPhone SE.
      const smallPortrait = Size(320, 568);

      for (final textScale in [2.0, 3.0]) {
        testWidgets(
          'scrolls instead of overflowing on a small phone at ${textScale}x '
          'text',
          (tester) async {
            useScreen(tester, smallPortrait, textScale: textScale);
            await pumpGame(tester, _humanIsX);
            await playToTheEnd(tester);

            expect(tester.takeException(), isNull);
            // The board keeps its full width instead of being squeezed.
            expect(
              tester.getSize(find.byKey(const ValueKey('cell-0'))).shortestSide,
              greaterThanOrEqualTo(48),
            );

            final playAgain = find.text('Play again');
            await tester.ensureVisible(playAgain);
            await tester.tap(playAgain);
            await tester.pumpAndSettle();

            expect(tester.takeException(), isNull);
            expect(find.text('Your turn'), findsOneWidget);
          },
        );
      }

      testWidgets('fills the width with the board on a regular phone', (
        tester,
      ) async {
        useScreen(tester, portrait);
        await pumpGame(tester, _humanIsX);

        // 402 wide minus 24 of padding on each side.
        expect(
          tester.getSize(find.byType(BoardView)),
          const Size(354, 354),
        );
      });

      testWidgets('caps the board at 480 on a tablet', (tester) async {
        useScreen(tester, const Size(768, 1024));
        await pumpGame(tester, _humanIsX);

        expect(
          tester.getSize(find.byType(BoardView)),
          const Size(480, 480),
        );
      });
    });
  });
}
