import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/domain/ai/random_move_strategy.dart';
import 'package:tic_tac_toe/domain/entities/board.dart';
import 'package:tic_tac_toe/domain/entities/mark.dart';

import '../../helpers/board_builder.dart';
import '../../helpers/fixed_random.dart';

void main() {
  group('RandomMoveStrategy', () {
    test('picks among empty cells using the injected Random', () {
      final board = boardOf('XO.X.O...');

      expect(RandomMoveStrategy(FixedRandom()).chooseMove(board, Mark.x), 2);
      expect(RandomMoveStrategy(FixedRandom(1)).chooseMove(board, Mark.x), 4);
    });

    test('only ever plays empty cells', () {
      final strategy = RandomMoveStrategy(Random(42));
      final board = boardOf('XO.X.O...');

      for (var i = 0; i < 100; i++) {
        expect(board.emptyCells, contains(strategy.chooseMove(board, Mark.x)));
      }
    });

    test('plays the only empty cell left', () {
      final strategy = RandomMoveStrategy(Random(42));

      expect(strategy.chooseMove(boardOf('XOXXOOOX.'), Mark.x), 8);
    });

    test('can play anywhere on an empty board', () {
      final strategy = RandomMoveStrategy(Random(7));
      final board = Board.empty();

      final moves = {
        for (var i = 0; i < 200; i++) strategy.chooseMove(board, Mark.x),
      };

      expect(moves, hasLength(9));
    });
  });
}
