import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:tic_tac_toe/domain/entities/game.dart';
import 'package:tic_tac_toe/domain/entities/game_settings.dart';
import 'package:tic_tac_toe/presentation/providers.dart';
import 'package:tic_tac_toe/presentation/score/score_controller.dart';

/// One game per [GameSettings]. Disposed when the game screen is closed.
final NotifierProviderFamily<GameController, Game, GameSettings>
gameControllerProvider = NotifierProvider.autoDispose.family(
  GameController.new,
);

/// Runs a Human vs CPU game: applies the human's moves, lets the CPU answer
/// after a short delay and records the outcome once the game is over.
class GameController extends Notifier<Game> {
  GameController(this._settings);

  final GameSettings _settings;
  Timer? _cpuTurn;

  @override
  Game build() {
    ref.onDispose(_cancelCpuTurn);
    return _newGame();
  }

  /// Plays the human's move at [index]. Ignored when it is not the human's
  /// turn or the cell is taken.
  void play(int index) {
    if (!state.isHumanTurn || !state.board.isEmptyAt(index)) return;
    _apply(state.play(index));
  }

  /// Starts over with the same settings.
  void restart() => state = _newGame();

  Game _newGame() {
    _cancelCpuTurn();
    final game = Game(settings: _settings);
    _scheduleCpuTurn(game);
    return game;
  }

  void _apply(Game game) {
    state = game;
    if (game.outcome case final outcome?) {
      unawaited(ref.read(scoreControllerProvider.notifier).record(outcome));
    } else {
      _scheduleCpuTurn(game);
    }
  }

  void _scheduleCpuTurn(Game game) {
    if (!game.isCpuTurn) return;
    _cpuTurn = Timer(
      ref.read(cpuMoveDelayProvider),
      () => _apply(ref.read(playCpuTurnProvider)(state)),
    );
  }

  void _cancelCpuTurn() {
    _cpuTurn?.cancel();
    _cpuTurn = null;
  }
}
