import 'package:tic_tac_toe/domain/entities/board.dart';
import 'package:tic_tac_toe/domain/entities/mark.dart';

/// Decides where the CPU plays. One implementation per difficulty level.
abstract interface class MoveStrategy {
  /// Returns the index of the cell [mark] should play on [board].
  ///
  /// [board] must have at least one empty cell.
  int chooseMove(Board board, Mark mark);
}
