import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/domain/ai/move_strategy.dart';
import 'package:tic_tac_toe/domain/entities/board.dart';
import 'package:tic_tac_toe/domain/entities/difficulty.dart';
import 'package:tic_tac_toe/domain/entities/game.dart';
import 'package:tic_tac_toe/domain/entities/game_settings.dart';
import 'package:tic_tac_toe/domain/entities/mark.dart';
import 'package:tic_tac_toe/domain/usecases/play_cpu_turn.dart';

class _FixedMoveStrategy implements MoveStrategy {
  _FixedMoveStrategy(this.move);

  final int move;
  Mark? requestedMark;

  @override
  int chooseMove(Board board, Mark mark) {
    requestedMark = mark;
    return move;
  }
}

void main() {
  group('PlayCpuTurn', () {
    const cpuStarts = GameSettings(
      humanMark: Mark.o,
      difficulty: Difficulty.medium,
    );

    test("plays the move chosen by the difficulty's strategy", () {
      final strategy = _FixedMoveStrategy(4);
      Difficulty? requestedDifficulty;
      final playCpuTurn = PlayCpuTurn((difficulty) {
        requestedDifficulty = difficulty;
        return strategy;
      });

      final game = playCpuTurn(Game(settings: cpuStarts));

      expect(requestedDifficulty, Difficulty.medium);
      expect(strategy.requestedMark, Mark.x);
      expect(game.board[4], Mark.x);
      expect(game.isHumanTurn, isTrue);
    });

    test("throws when it is the human's turn", () {
      final playCpuTurn = PlayCpuTurn((_) => _FixedMoveStrategy(0));
      final game = Game(
        settings: const GameSettings(
          humanMark: Mark.x,
          difficulty: Difficulty.easy,
        ),
      );

      expect(() => playCpuTurn(game), throwsStateError);
    });
  });
}
