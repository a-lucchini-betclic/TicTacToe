import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/domain/entities/difficulty.dart';
import 'package:tic_tac_toe/domain/entities/game.dart';
import 'package:tic_tac_toe/domain/entities/game_outcome.dart';
import 'package:tic_tac_toe/domain/entities/game_settings.dart';
import 'package:tic_tac_toe/domain/entities/mark.dart';
import 'package:tic_tac_toe/domain/entities/score.dart';
import 'package:tic_tac_toe/presentation/game/game_controller.dart';
import 'package:tic_tac_toe/presentation/providers.dart';

import '../../helpers/fixed_random.dart';
import '../../helpers/in_memory_score_repository.dart';

const _delay = Duration(milliseconds: 500);

/// On easy, FixedRandom(0) makes the CPU always play the first empty cell.
const _humanIsX = GameSettings(humanMark: Mark.x, difficulty: Difficulty.easy);
const _humanIsO = GameSettings(humanMark: Mark.o, difficulty: Difficulty.easy);

void main() {
  late InMemoryScoreRepository repository;

  setUp(() => repository = InMemoryScoreRepository());

  /// Runs [body] in fake time with a container wired to test doubles.
  void runGame(
    GameSettings settings,
    void Function(
      FakeAsync async,
      GameController controller,
      Game Function() game,
    )
    body,
  ) {
    fakeAsync((async) {
      final container = ProviderContainer.test(
        overrides: [
          scoreRepositoryProvider.overrideWithValue(repository),
          randomProvider.overrideWithValue(FixedRandom()),
          cpuMoveDelayProvider.overrideWithValue(_delay),
        ],
      );
      final provider = gameControllerProvider(settings);
      // Keeps the auto-dispose provider alive for the whole test.
      container.listen(provider, (_, _) {});

      body(
        async,
        container.read(provider.notifier),
        () => container.read(provider),
      );
    });
  }

  group('GameController', () {
    test('waits for the human when the human plays X', () {
      runGame(_humanIsX, (async, controller, game) {
        async.elapse(_delay * 2);

        expect(game().board.emptyCells, hasLength(9));
        expect(game().isHumanTurn, isTrue);
      });
    });

    test('lets the CPU open after the delay when the human plays O', () {
      runGame(_humanIsO, (async, controller, game) {
        expect(game().isCpuTurn, isTrue);

        async.elapse(_delay);

        expect(game().board[0], Mark.x);
        expect(game().isHumanTurn, isTrue);
      });
    });

    test('the CPU answers a human move only after the delay', () {
      runGame(_humanIsX, (async, controller, game) {
        controller.play(4);
        expect(game().board[4], Mark.x);
        expect(game().isCpuTurn, isTrue);

        async.elapse(_delay - const Duration(milliseconds: 1));
        expect(game().isCpuTurn, isTrue);

        async.elapse(const Duration(milliseconds: 1));
        expect(game().board[0], Mark.o);
        expect(game().isHumanTurn, isTrue);
      });
    });

    test('ignores moves during the CPU turn and on taken cells', () {
      runGame(_humanIsX, (async, controller, game) {
        controller.play(4);
        final afterFirstMove = game();

        controller
          ..play(5)
          ..play(4);
        expect(game(), afterFirstMove);

        async.elapse(_delay);
        final afterCpuMove = game();
        controller.play(4);
        expect(game(), afterCpuMove);
      });
    });

    test('records a win when the human completes a line', () {
      runGame(_humanIsX, (async, controller, game) {
        // Human X: 3, 4, 5. CPU O answers 0, then 1.
        for (final move in [3, 4, 5]) {
          controller.play(move);
          async.elapse(_delay);
        }

        expect(game().outcome, GameOutcome.win);
        expect(repository.score, const Score(wins: 1));
      });
    });

    test('records a loss when the CPU completes a line', () {
      runGame(_humanIsO, (async, controller, game) {
        // CPU X: 0, 1, 2. Human O: 8, 7.
        async.elapse(_delay);
        for (final move in [8, 7]) {
          controller.play(move);
          async.elapse(_delay);
        }

        expect(game().outcome, GameOutcome.loss);
        expect(repository.score, const Score(losses: 1));
      });
    });

    test('restart starts a new game with the same settings', () {
      runGame(_humanIsO, (async, controller, game) {
        async.elapse(_delay);
        controller
          ..play(8)
          ..restart();

        expect(game(), Game(settings: _humanIsO));

        async.elapse(_delay);
        expect(game().board[0], Mark.x);
      });
    });

    test('cancels the pending CPU move when disposed', () {
      fakeAsync((async) {
        final container = ProviderContainer.test(
          overrides: [
            scoreRepositoryProvider.overrideWithValue(repository),
            cpuMoveDelayProvider.overrideWithValue(_delay),
          ],
        );
        final subscription = container.listen(
          gameControllerProvider(_humanIsO),
          (_, _) {},
        );
        expect(async.pendingTimers, hasLength(1));

        // Riverpod disposes unused auto-dispose providers asynchronously.
        subscription.close();
        async.elapse(Duration.zero);

        expect(async.pendingTimers, isEmpty);
      });
    });
  });
}
