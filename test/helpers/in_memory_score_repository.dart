import 'package:tic_tac_toe/domain/entities/score.dart';
import 'package:tic_tac_toe/domain/repositories/score_repository.dart';

/// A [ScoreRepository] fake that keeps the score in memory.
class InMemoryScoreRepository implements ScoreRepository {
  InMemoryScoreRepository([this.score = Score.zero]);

  Score score;

  /// When set, [load] and [save] throw it, to simulate storage failures.
  Exception? error;

  @override
  Future<Score> load() async {
    if (error case final error?) throw error;
    return score;
  }

  @override
  Future<void> save(Score score) async {
    if (error case final error?) throw error;
    this.score = score;
  }
}
