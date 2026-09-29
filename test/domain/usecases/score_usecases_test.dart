import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/domain/entities/game_outcome.dart';
import 'package:tic_tac_toe/domain/entities/score.dart';
import 'package:tic_tac_toe/domain/usecases/get_score.dart';
import 'package:tic_tac_toe/domain/usecases/record_game_outcome.dart';

import '../../helpers/in_memory_score_repository.dart';

void main() {
  group('GetScore', () {
    test('returns the stored score', () async {
      final repository = InMemoryScoreRepository(const Score(wins: 2));

      expect(await GetScore(repository)(), const Score(wins: 2));
    });
  });

  group('RecordGameOutcome', () {
    test('adds the outcome to the stored score and returns it', () async {
      final repository = InMemoryScoreRepository(const Score(wins: 2));

      final score = await RecordGameOutcome(repository)(GameOutcome.loss);

      expect(score, const Score(wins: 2, losses: 1));
      expect(repository.score, const Score(wins: 2, losses: 1));
    });

    test('propagates storage errors', () async {
      final repository = InMemoryScoreRepository()..error = Exception('disk');

      expect(
        () => RecordGameOutcome(repository)(GameOutcome.win),
        throwsException,
      );
    });
  });
}
