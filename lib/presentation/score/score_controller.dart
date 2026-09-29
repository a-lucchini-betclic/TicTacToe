import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tic_tac_toe/domain/entities/game_outcome.dart';
import 'package:tic_tac_toe/domain/entities/score.dart';
import 'package:tic_tac_toe/presentation/providers.dart';

final scoreControllerProvider = AsyncNotifierProvider<ScoreController, Score>(
  ScoreController.new,
);

/// Exposes the player's score and keeps it up to date as games finish.
class ScoreController extends AsyncNotifier<Score> {
  @override
  Future<Score> build() => ref.watch(getScoreProvider)();

  Future<void> record(GameOutcome outcome) async {
    state = await AsyncValue.guard(
      () => ref.read(recordGameOutcomeProvider)(outcome),
    );
  }
}
