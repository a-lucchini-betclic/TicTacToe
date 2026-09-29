import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/domain/entities/difficulty.dart';
import 'package:tic_tac_toe/domain/entities/game.dart';
import 'package:tic_tac_toe/domain/entities/game_settings.dart';
import 'package:tic_tac_toe/domain/entities/mark.dart';
import 'package:tic_tac_toe/presentation/providers.dart';

import '../helpers/board_builder.dart';
import '../helpers/fixed_random.dart';

void main() {
  group('providers', () {
    late ProviderContainer container;

    setUp(() {
      // FixedRandom(0) makes the random parts pick the first empty cell.
      container = ProviderContainer.test(
        overrides: [randomProvider.overrideWithValue(FixedRandom())],
      );
    });

    test('the CPU waits 600 ms before playing', () {
      expect(
        container.read(cpuMoveDelayProvider),
        const Duration(milliseconds: 600),
      );
    });

    test('the score repository must be provided by the composition root', () {
      expect(
        () => container.read(scoreRepositoryProvider),
        throwsA(
          isA<ProviderException>().having(
            (error) => error.exception,
            'exception',
            isA<UnimplementedError>(),
          ),
        ),
      );
    });

    group('playCpuTurnProvider', () {
      /// The CPU (O) answers [board] at [difficulty].
      ///
      /// The strategies are private to the provider, so they are told apart
      /// by the moves they pick.
      int cpuMove(Difficulty difficulty, String board) {
        final game = Game(
          settings: GameSettings(humanMark: Mark.x, difficulty: difficulty),
          board: boardOf(board),
        );
        final played = container.read(playCpuTurnProvider)(game);
        return [
          for (var index = 0; index < 9; index++)
            if (played.board[index] != game.board[index]) index,
        ].single;
      }

      // O can win with 5, X threatens 0, and 0 is also the first empty cell.
      const winAvailable = '.XXOO.X..';
      // Nothing to win or block: the best reply to a corner is the centre.
      const cornerOpening = 'X........';

      test('plays at random on easy', () {
        expect(cpuMove(Difficulty.easy, winAvailable), 0);
        expect(cpuMove(Difficulty.easy, cornerOpening), 1);
      });

      test('wins or blocks, else plays at random, on medium', () {
        expect(cpuMove(Difficulty.medium, winAvailable), 5);
        expect(cpuMove(Difficulty.medium, cornerOpening), 1);
      });

      test('plays perfectly on hard', () {
        expect(cpuMove(Difficulty.hard, winAvailable), 5);
        expect(cpuMove(Difficulty.hard, cornerOpening), 4);
      });
    });
  });
}
