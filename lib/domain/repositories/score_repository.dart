import 'package:tic_tac_toe/domain/entities/score.dart';

/// Persists the player's [Score] between app launches.
abstract interface class ScoreRepository {
  /// Returns the stored score, or [Score.zero] if none was saved yet.
  Future<Score> load();

  Future<void> save(Score score);
}
