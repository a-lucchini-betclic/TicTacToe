import 'package:equatable/equatable.dart';
import 'package:tic_tac_toe/domain/entities/game_outcome.dart';

/// The human player's all-time record against the CPU.
class Score extends Equatable {
  const Score({this.wins = 0, this.losses = 0, this.draws = 0})
    : assert(wins >= 0 && losses >= 0 && draws >= 0, 'Counts are >= 0');

  static const Score zero = Score();

  final int wins;
  final int losses;
  final int draws;

  int get gamesPlayed => wins + losses + draws;

  Score record(GameOutcome outcome) => switch (outcome) {
    GameOutcome.win => Score(wins: wins + 1, losses: losses, draws: draws),
    GameOutcome.loss => Score(wins: wins, losses: losses + 1, draws: draws),
    GameOutcome.draw => Score(wins: wins, losses: losses, draws: draws + 1),
  };

  @override
  List<Object?> get props => [wins, losses, draws];
}
