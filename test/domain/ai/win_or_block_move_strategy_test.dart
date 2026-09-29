import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/domain/ai/win_or_block_move_strategy.dart';
import 'package:tic_tac_toe/domain/entities/mark.dart';

import '../../helpers/board_builder.dart';
import '../../helpers/fixed_random.dart';

void main() {
  group('WinOrBlockMoveStrategy', () {
    final strategy = WinOrBlockMoveStrategy(FixedRandom());

    test('completes its own line', () {
      final board = boardOf('''
        O O .
        X X .
        X . .
      ''');

      expect(strategy.chooseMove(board, Mark.o), 2);
    });

    test('prefers winning over blocking', () {
      final board = boardOf('''
        X X .
        O O .
        . . .
      ''');

      expect(strategy.chooseMove(board, Mark.x), 2);
    });

    test("blocks the opponent's line when it cannot win", () {
      final board = boardOf('''
        X . .
        . X .
        . . .
      ''');

      expect(strategy.chooseMove(board, Mark.o), 8);
    });

    test('falls back to a random empty cell otherwise', () {
      final board = boardOf('''
        X . .
        . . .
        . . .
      ''');

      // FixedRandom(0) picks the first empty cell.
      expect(strategy.chooseMove(board, Mark.o), 1);
    });
  });
}
