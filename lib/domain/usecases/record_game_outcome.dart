import 'package:tic_tac_toe/domain/entities/game_outcome.dart';
import 'package:tic_tac_toe/domain/entities/score.dart';
import 'package:tic_tac_toe/domain/repositories/score_repository.dart';

/// Adds a finished game to the stored score and returns the updated score.
class RecordGameOutcome {
  const RecordGameOutcome(this._repository);

  final ScoreRepository _repository;

  Future<Score> call(GameOutcome outcome) async {
    final score = (await _repository.load()).record(outcome);
    await _repository.save(score);
    return score;
  }
}
