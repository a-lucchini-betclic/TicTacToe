import 'dart:math';

import 'package:tic_tac_toe/domain/ai/move_strategy.dart';
import 'package:tic_tac_toe/domain/entities/board.dart';
import 'package:tic_tac_toe/domain/entities/mark.dart';

/// Easy: plays any empty cell at random.
class RandomMoveStrategy implements MoveStrategy {
  RandomMoveStrategy(this._random);

  final Random _random;

  @override
  int chooseMove(Board board, Mark mark) {
    final candidates = board.emptyCells;
    return candidates[_random.nextInt(candidates.length)];
  }
}
