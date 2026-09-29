import 'dart:math';

import 'package:tic_tac_toe/domain/ai/move_strategy.dart';
import 'package:tic_tac_toe/domain/ai/random_move_strategy.dart';
import 'package:tic_tac_toe/domain/entities/board.dart';
import 'package:tic_tac_toe/domain/entities/mark.dart';

/// Medium: takes a winning move if there is one, otherwise blocks the
/// opponent's winning move, otherwise plays at random.
///
/// Beatable: it does not see forks coming.
class WinOrBlockMoveStrategy implements MoveStrategy {
  WinOrBlockMoveStrategy(Random random)
    : _fallback = RandomMoveStrategy(random);

  final MoveStrategy _fallback;

  @override
  int chooseMove(Board board, Mark mark) =>
      _completingMove(board, mark) ??
      _completingMove(board, mark.opponent) ??
      _fallback.chooseMove(board, mark);

  /// An empty cell that would give [mark] three in a row, if any.
  int? _completingMove(Board board, Mark mark) {
    for (final index in board.emptyCells) {
      if (board.place(index, mark).winningLine != null) return index;
    }
    return null;
  }
}
