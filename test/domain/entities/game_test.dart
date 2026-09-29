import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/domain/entities/difficulty.dart';
import 'package:tic_tac_toe/domain/entities/game.dart';
import 'package:tic_tac_toe/domain/entities/game_outcome.dart';
import 'package:tic_tac_toe/domain/entities/game_settings.dart';
import 'package:tic_tac_toe/domain/entities/invalid_move_exception.dart';
import 'package:tic_tac_toe/domain/entities/mark.dart';

import '../../helpers/board_builder.dart';

void main() {
  const humanIsX = GameSettings(humanMark: Mark.x, difficulty: Difficulty.easy);
  const humanIsO = GameSettings(humanMark: Mark.o, difficulty: Difficulty.hard);

  group('Game', () {
    test('a new game starts on an empty board', () {
      final game = Game(settings: humanIsX);

      expect(game.board.emptyCells, hasLength(9));
      expect(game.isOver, isFalse);
      expect(game.outcome, isNull);
    });

    test('exposes the settings it was created with', () {
      final game = Game(settings: humanIsO);

      expect(game.humanMark, Mark.o);
      expect(game.cpuMark, Mark.x);
      expect(game.difficulty, Difficulty.hard);
    });

    test('the human moves first when playing X', () {
      final game = Game(settings: humanIsX);

      expect(game.isHumanTurn, isTrue);
      expect(game.isCpuTurn, isFalse);
    });

    test('the CPU moves first when the human plays O', () {
      final game = Game(settings: humanIsO);

      expect(game.isCpuTurn, isTrue);
      expect(game.isHumanTurn, isFalse);
    });

    test('play places the current mark and passes the turn', () {
      final game = Game(settings: humanIsX).play(4);

      expect(game.board[4], Mark.x);
      expect(game.isCpuTurn, isTrue);
    });

    test('play throws on a taken cell', () {
      final game = Game(settings: humanIsX).play(4);

      expect(() => game.play(4), throwsA(isA<InvalidMoveException>()));
    });

    test('play throws once the game is over', () {
      final game = Game(settings: humanIsX, board: boardOf('XXXOO....'));

      expect(game.isOver, isTrue);
      expect(game.currentMark, isNull);
      expect(() => game.play(8), throwsA(isA<InvalidMoveException>()));
    });

    test('outcome is a win when the human completes a line', () {
      final game = Game(settings: humanIsX, board: boardOf('XXXOO....'));

      expect(game.outcome, GameOutcome.win);
    });

    test('outcome is a loss when the CPU completes a line', () {
      final game = Game(settings: humanIsO, board: boardOf('XXXOO....'));

      expect(game.outcome, GameOutcome.loss);
    });

    test('outcome is a draw when the board fills up', () {
      final game = Game(settings: humanIsX, board: boardOf('XOXXOOOXX'));

      expect(game.outcome, GameOutcome.draw);
    });

    test('games with the same settings and board are equal', () {
      expect(Game(settings: humanIsX), Game(settings: humanIsX));
      expect(Game(settings: humanIsX), isNot(Game(settings: humanIsO)));
    });
  });
}
