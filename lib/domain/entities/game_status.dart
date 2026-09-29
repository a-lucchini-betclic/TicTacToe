import 'package:equatable/equatable.dart';
import 'package:tic_tac_toe/domain/entities/board.dart';
import 'package:tic_tac_toe/domain/entities/mark.dart';

/// Where a game stands. Sealed so that `switch` statements over it are
/// checked for exhaustiveness by the compiler.
sealed class GameStatus extends Equatable {
  const GameStatus();

  factory GameStatus.of(Board board) {
    final line = board.winningLine;
    if (line != null) return GameWon(line);
    if (board.isFull) return const GameDrawn();
    return GameInProgress(board.nextMark);
  }
}

final class GameInProgress extends GameStatus {
  const GameInProgress(this.nextMark);

  final Mark nextMark;

  @override
  List<Object?> get props => [nextMark];
}

final class GameWon extends GameStatus {
  const GameWon(this.line);

  final WinningLine line;

  Mark get winner => line.mark;

  @override
  List<Object?> get props => [line];
}

final class GameDrawn extends GameStatus {
  const GameDrawn();

  @override
  List<Object?> get props => [];
}
