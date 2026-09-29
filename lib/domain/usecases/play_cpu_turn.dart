import 'package:tic_tac_toe/domain/ai/move_strategy.dart';
import 'package:tic_tac_toe/domain/entities/difficulty.dart';
import 'package:tic_tac_toe/domain/entities/game.dart';

/// Returns the [MoveStrategy] the CPU uses at a given [Difficulty].
typedef MoveStrategyResolver = MoveStrategy Function(Difficulty difficulty);

/// Lets the CPU play its move in a [Game].
class PlayCpuTurn {
  const PlayCpuTurn(this._strategyFor);

  final MoveStrategyResolver _strategyFor;

  /// Returns [game] after the CPU played.
  ///
  /// Throws a [StateError] if it is not the CPU's turn.
  Game call(Game game) {
    if (!game.isCpuTurn) {
      throw StateError('It is not the CPU turn.');
    }
    final move = _strategyFor(
      game.difficulty,
    ).chooseMove(game.board, game.cpuMark);
    return game.play(move);
  }
}
