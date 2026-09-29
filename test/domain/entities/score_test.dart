import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/domain/entities/game_outcome.dart';
import 'package:tic_tac_toe/domain/entities/score.dart';

void main() {
  group('Score', () {
    test('starts at zero', () {
      expect(Score.zero.gamesPlayed, 0);
    });

    test('record increments the matching counter only', () {
      const score = Score(wins: 1, losses: 2, draws: 3);

      expect(
        score.record(GameOutcome.win),
        const Score(wins: 2, losses: 2, draws: 3),
      );
      expect(
        score.record(GameOutcome.loss),
        const Score(wins: 1, losses: 3, draws: 3),
      );
      expect(
        score.record(GameOutcome.draw),
        const Score(wins: 1, losses: 2, draws: 4),
      );
    });

    test('gamesPlayed sums all outcomes', () {
      expect(const Score(wins: 1, losses: 2, draws: 3).gamesPlayed, 6);
    });
  });
}
