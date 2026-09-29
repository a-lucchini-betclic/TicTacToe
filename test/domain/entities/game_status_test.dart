import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/domain/entities/board.dart';
import 'package:tic_tac_toe/domain/entities/game_status.dart';
import 'package:tic_tac_toe/domain/entities/mark.dart';

import '../../helpers/board_builder.dart';

void main() {
  group('GameStatus.of', () {
    test('is in progress with X to move on an empty board', () {
      expect(GameStatus.of(Board.empty()), const GameInProgress(Mark.x));
    });

    test('is in progress with O to move after X played', () {
      expect(GameStatus.of(boardOf('....X....')), const GameInProgress(Mark.o));
    });

    test('is won when a line is complete', () {
      final status = GameStatus.of(
        boardOf('''
          X X X
          O O .
          . . .
        '''),
      );

      expect(status, isA<GameWon>());
      status as GameWon;
      expect(status.winner, Mark.x);
      expect(status.line.cells, [0, 1, 2]);
    });

    test('a win on the last cell is a win, not a draw', () {
      final status = GameStatus.of(
        boardOf('''
          X O X
          O X O
          O X X
        '''),
      );

      expect(status, isA<GameWon>());
    });

    test('is drawn when the board is full without a line', () {
      final status = GameStatus.of(
        boardOf('''
          X O X
          X O O
          O X X
        '''),
      );

      expect(status, const GameDrawn());
    });
  });
}
