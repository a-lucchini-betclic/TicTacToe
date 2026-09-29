import 'package:tic_tac_toe/domain/entities/score.dart';

/// Storage representation of a [Score]. Keeps the JSON format out of the
/// domain entity.
class ScoreDto {
  const ScoreDto({
    required this.wins,
    required this.losses,
    required this.draws,
  });

  ScoreDto.fromDomain(Score score)
    : this(wins: score.wins, losses: score.losses, draws: score.draws);

  /// Throws a [FormatException] if [json] is not a valid score.
  factory ScoreDto.fromJson(Object? json) {
    if (json case {
      'wins': final int wins,
      'losses': final int losses,
      'draws': final int draws,
    } when wins >= 0 && losses >= 0 && draws >= 0) {
      return ScoreDto(wins: wins, losses: losses, draws: draws);
    }
    throw FormatException('Not a valid score', json);
  }

  final int wins;
  final int losses;
  final int draws;

  Map<String, Object?> toJson() => {
    'wins': wins,
    'losses': losses,
    'draws': draws,
  };

  Score toDomain() => Score(wins: wins, losses: losses, draws: draws);
}
