import 'package:equatable/equatable.dart';
import 'package:tic_tac_toe/domain/entities/board.dart';
import 'package:tic_tac_toe/domain/entities/difficulty.dart';
import 'package:tic_tac_toe/domain/entities/game_outcome.dart';
import 'package:tic_tac_toe/domain/entities/game_settings.dart';
import 'package:tic_tac_toe/domain/entities/game_status.dart';
import 'package:tic_tac_toe/domain/entities/invalid_move_exception.dart';
import 'package:tic_tac_toe/domain/entities/mark.dart';

/// A single Human vs CPU game: the board plus the settings it is played with.
///
/// Immutable: every move returns a new [Game].
class Game extends Equatable {
  Game({required this.settings, Board? board}) : board = board ?? Board.empty();

  final GameSettings settings;
  final Board board;

  late final GameStatus status = GameStatus.of(board);

  Mark get humanMark => settings.humanMark;
  Mark get cpuMark => settings.cpuMark;
  Difficulty get difficulty => settings.difficulty;

  bool get isOver => status is! GameInProgress;

  /// The mark expected to play next, or `null` once the game is over.
  Mark? get currentMark => switch (status) {
    GameInProgress(:final nextMark) => nextMark,
    GameWon() || GameDrawn() => null,
  };

  bool get isHumanTurn => currentMark == humanMark;
  bool get isCpuTurn => currentMark == cpuMark;

  /// The result for the human player, or `null` while the game is running.
  GameOutcome? get outcome => switch (status) {
    GameInProgress() => null,
    GameDrawn() => GameOutcome.draw,
    GameWon(:final winner) =>
      winner == humanMark ? GameOutcome.win : GameOutcome.loss,
  };

  /// Places the current player's mark at [index].
  ///
  /// Throws an [InvalidMoveException] if the game is over or the cell is
  /// taken.
  Game play(int index) {
    final mark = currentMark;
    if (mark == null) {
      throw const InvalidMoveException('The game is already over.');
    }
    return Game(settings: settings, board: board.place(index, mark));
  }

  @override
  List<Object?> get props => [settings, board];
}
