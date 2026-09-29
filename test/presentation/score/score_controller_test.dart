import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/domain/entities/game_outcome.dart';
import 'package:tic_tac_toe/domain/entities/score.dart';
import 'package:tic_tac_toe/presentation/providers.dart';
import 'package:tic_tac_toe/presentation/score/score_controller.dart';

import '../../helpers/in_memory_score_repository.dart';

void main() {
  late InMemoryScoreRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = InMemoryScoreRepository(const Score(wins: 1));
    container = ProviderContainer.test(
      overrides: [scoreRepositoryProvider.overrideWithValue(repository)],
      retry: (_, _) => null,
    );
  });

  group('ScoreController', () {
    test('loads the stored score', () async {
      expect(
        await container.read(scoreControllerProvider.future),
        const Score(wins: 1),
      );
    });

    test('record saves the outcome and exposes the new score', () async {
      await container.read(scoreControllerProvider.future);

      await container
          .read(scoreControllerProvider.notifier)
          .record(GameOutcome.draw);

      expect(
        container.read(scoreControllerProvider).value,
        const Score(wins: 1, draws: 1),
      );
      expect(repository.score, const Score(wins: 1, draws: 1));
    });

    test('exposes an error when the score cannot be loaded', () async {
      repository.error = Exception('disk');

      await expectLater(
        container.read(scoreControllerProvider.future),
        throwsException,
      );
      expect(container.read(scoreControllerProvider).hasError, isTrue);
    });
  });
}
