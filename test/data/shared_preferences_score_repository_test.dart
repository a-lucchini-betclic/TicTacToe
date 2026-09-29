import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tic_tac_toe/data/repositories/shared_preferences_score_repository.dart';
import 'package:tic_tac_toe/domain/entities/score.dart';

void main() {
  const key = SharedPreferencesScoreRepository.storageKey;

  Future<SharedPreferencesScoreRepository> repositoryWith(
    Map<String, Object> values,
  ) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferencesScoreRepository(
      await SharedPreferences.getInstance(),
    );
  }

  group('SharedPreferencesScoreRepository', () {
    test('loads zero when nothing was saved', () async {
      final repository = await repositoryWith({});

      expect(await repository.load(), Score.zero);
    });

    test('loads what was saved', () async {
      final repository = await repositoryWith({});

      await repository.save(const Score(wins: 3, losses: 1, draws: 2));

      expect(
        await repository.load(),
        const Score(wins: 3, losses: 1, draws: 2),
      );
    });

    test('stores the score as JSON under a versioned key', () async {
      final repository = await repositoryWith({});

      await repository.save(const Score(wins: 1));

      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString(key), '{"wins":1,"losses":0,"draws":0}');
    });

    test('reads a score saved by a previous launch', () async {
      final repository = await repositoryWith({
        key: '{"wins":4,"losses":5,"draws":6}',
      });

      expect(
        await repository.load(),
        const Score(wins: 4, losses: 5, draws: 6),
      );
    });

    for (final corrupted in [
      'not json',
      '[1, 2, 3]',
      '{"wins":"1","losses":0,"draws":0}',
      '{"wins":1}',
      '{"wins":-1,"losses":0,"draws":0}',
    ]) {
      test('falls back to zero when the stored value is $corrupted', () async {
        final repository = await repositoryWith({key: corrupted});

        expect(await repository.load(), Score.zero);
      });
    }
  });
}
