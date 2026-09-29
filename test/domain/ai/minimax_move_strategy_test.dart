import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/domain/ai/minimax_move_strategy.dart';
import 'package:tic_tac_toe/domain/ai/move_strategy.dart';
import 'package:tic_tac_toe/domain/entities/board.dart';
import 'package:tic_tac_toe/domain/entities/game_status.dart';
import 'package:tic_tac_toe/domain/entities/mark.dart';

import '../../helpers/board_builder.dart';

void main() {
  group('MinimaxMoveStrategy', () {
    const strategy = MinimaxMoveStrategy();

    test('takes an immediate win instead of blocking', () {
      // Cell 0 is both the block and the first empty cell: only 5 shows that
      // O goes for the win.
      final board = boardOf('''
        . X X
        O O .
        X . .
      ''');

      expect(strategy.chooseMove(board, Mark.o), 5);
    });

    test("blocks the opponent's immediate win", () {
      // The lowest empty cell is 0, so only 8 shows that O blocks.
      final board = boardOf('''
        . . .
        . O .
        X X .
      ''');

      expect(strategy.chooseMove(board, Mark.o), 8);
    });

    test('answers a corner opening with the center', () {
      final board = boardOf('''
        X . .
        . . .
        . . .
      ''');

      expect(strategy.chooseMove(board, Mark.o), 4);
    });

    test('wins as fast as possible', () {
      // X wins now with 8. Playing 3 would also force a win, one move later:
      // only the depth-aware scoring prefers 8 over the lower index 3.
      final board = boardOf('''
        X O O
        . X .
        . . .
      ''');

      expect(strategy.chooseMove(board, Mark.x), 8);
    });

    test('never loses, whoever starts and whatever the opponent plays', () {
      for (final cpuMark in Mark.values) {
        final result = _playEveryGame(strategy, cpuMark);

        expect(result.losses, 0, reason: 'CPU playing $cpuMark');
        expect(result.games, greaterThan(0));
      }
    });
  });
}

/// Plays [cpu] against every possible sequence of opponent moves.
({int games, int losses}) _playEveryGame(MoveStrategy cpu, Mark cpuMark) {
  var games = 0;
  var losses = 0;

  void explore(Board board) {
    switch (GameStatus.of(board)) {
      case GameWon(:final winner):
        games++;
        if (winner != cpuMark) losses++;
      case GameDrawn():
        games++;
      case GameInProgress(:final nextMark) when nextMark == cpuMark:
        explore(board.place(cpu.chooseMove(board, cpuMark), cpuMark));
      case GameInProgress(:final nextMark):
        for (final move in board.emptyCells) {
          explore(board.place(move, nextMark));
        }
    }
  }

  explore(Board.empty());
  return (games: games, losses: losses);
}
