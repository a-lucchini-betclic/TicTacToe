import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/domain/entities/board.dart';
import 'package:tic_tac_toe/domain/entities/invalid_move_exception.dart';
import 'package:tic_tac_toe/domain/entities/mark.dart';

import '../../helpers/board_builder.dart';

void main() {
  group('Board', () {
    test('empty board has 9 empty cells and X to move', () {
      final board = Board.empty();

      expect(board.cells, hasLength(9));
      expect(board.emptyCells, [0, 1, 2, 3, 4, 5, 6, 7, 8]);
      expect(board.isFull, isFalse);
      expect(board.nextMark, Mark.x);
      expect(board.winningLine, isNull);
    });

    test('place returns a new board and leaves the original untouched', () {
      final board = Board.empty();

      final next = board.place(4, Mark.x);

      expect(next[4], Mark.x);
      expect(board[4], isNull);
      expect(next.emptyCells, isNot(contains(4)));
    });

    test('place throws InvalidMoveException on a taken cell', () {
      final board = Board.empty().place(0, Mark.x);

      expect(
        () => board.place(0, Mark.o),
        throwsA(isA<InvalidMoveException>()),
      );
    });

    test('place throws RangeError outside the board', () {
      expect(() => Board.empty().place(9, Mark.x), throwsRangeError);
      expect(() => Board.empty().place(-1, Mark.x), throwsRangeError);
    });

    test('cells cannot be mutated from outside', () {
      final board = Board.empty();

      expect(() => board.cells[0] = Mark.x, throwsUnsupportedError);
    });

    test('nextMark alternates based on the marks already placed', () {
      expect(boardOf('X........').nextMark, Mark.o);
      expect(boardOf('XO.......').nextMark, Mark.x);
    });

    test('isFull is true only when no cell is empty', () {
      expect(boardOf('XOXXOOOXX').isFull, isTrue);
      expect(boardOf('XOXXOOOX.').isFull, isFalse);
    });

    test('detects every winning line', () {
      for (final line in Board.lines) {
        final cells = List<Mark?>.filled(9, null);
        for (final index in line) {
          cells[index] = Mark.o;
        }

        expect(
          Board.fromCells(cells).winningLine,
          WinningLine(mark: Mark.o, cells: line),
          reason: 'line $line',
        );
      }
    });

    test('has no winning line when no three marks align', () {
      expect(boardOf('XOXXOOOXX').winningLine, isNull);
    });

    test('boards with the same cells are equal', () {
      expect(boardOf('X...O....'), boardOf('X...O....'));
      expect(boardOf('X...O....'), isNot(boardOf('O...X....')));
    });
  });
}
