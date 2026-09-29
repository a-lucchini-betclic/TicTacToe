import 'package:tic_tac_toe/domain/entities/score.dart';
import 'package:tic_tac_toe/domain/repositories/score_repository.dart';

class GetScore {
  const GetScore(this._repository);

  final ScoreRepository _repository;

  Future<Score> call() => _repository.load();
}
