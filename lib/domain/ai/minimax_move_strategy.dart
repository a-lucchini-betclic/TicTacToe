import 'package:tic_tac_toe/domain/ai/move_strategy.dart';
import 'package:tic_tac_toe/domain/entities/board.dart';
import 'package:tic_tac_toe/domain/entities/mark.dart';

/// Hard: perfect play with minimax (negamax form) and alpha-beta pruning.
///
/// It never loses. Wins are scored higher the sooner they happen, so it
/// finishes the game as fast as possible and, if it is ever losing, holds
/// out as long as possible. Ties go to the lowest cell index, which keeps
/// the strategy deterministic.
class MinimaxMoveStrategy implements MoveStrategy {
  const MinimaxMoveStrategy();

  static const int _winScore = 10;
  static const int _infinity = 1000;

  @override
  int chooseMove(Board board, Mark mark) {
    final moves = board.emptyCells;
    var bestMove = moves.first;
    var bestScore = -_infinity;
    for (final move in moves) {
      final score = -_negamax(
        board.place(move, mark),
        mark.opponent,
        depth: 1,
        alpha: -_infinity,
        beta: -bestScore,
      );
      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }
    return bestMove;
  }

  /// Scores [board] from the point of view of [toPlay], who moves next.
  int _negamax(
    Board board,
    Mark toPlay, {
    required int depth,
    required int alpha,
    required int beta,
  }) {
    // Only the previous move can have completed a line, and it was played by
    // the opponent of [toPlay]: this position is lost for [toPlay].
    if (board.winningLine != null) return depth - _winScore;
    if (board.isFull) return 0;

    var best = -_infinity;
    var lowerBound = alpha;
    for (final move in board.emptyCells) {
      final score = -_negamax(
        board.place(move, toPlay),
        toPlay.opponent,
        depth: depth + 1,
        alpha: -beta,
        beta: -lowerBound,
      );
      if (score > best) best = score;
      if (best > lowerBound) lowerBound = best;
      if (lowerBound >= beta) break;
    }
    return best;
  }
}
