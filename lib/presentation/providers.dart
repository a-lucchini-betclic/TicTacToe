import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tic_tac_toe/domain/ai/minimax_move_strategy.dart';
import 'package:tic_tac_toe/domain/ai/random_move_strategy.dart';
import 'package:tic_tac_toe/domain/ai/win_or_block_move_strategy.dart';
import 'package:tic_tac_toe/domain/entities/difficulty.dart';
import 'package:tic_tac_toe/domain/repositories/score_repository.dart';
import 'package:tic_tac_toe/domain/usecases/get_score.dart';
import 'package:tic_tac_toe/domain/usecases/play_cpu_turn.dart';
import 'package:tic_tac_toe/domain/usecases/record_game_outcome.dart';

// Dependency graph of the presentation layer.
//
// The presentation layer only knows domain abstractions: concrete
// implementations from the data layer are injected in `main.dart` by
// overriding [scoreRepositoryProvider].

final scoreRepositoryProvider = Provider<ScoreRepository>(
  (ref) => throw UnimplementedError(
    'scoreRepositoryProvider must be overridden, see main.dart.',
  ),
);

final randomProvider = Provider<Random>((ref) => Random());

/// Pause before the CPU plays, so its move does not appear instantly.
final cpuMoveDelayProvider = Provider<Duration>(
  (ref) => const Duration(milliseconds: 600),
);

final playCpuTurnProvider = Provider<PlayCpuTurn>((ref) {
  final random = ref.watch(randomProvider);
  final easy = RandomMoveStrategy(random);
  final medium = WinOrBlockMoveStrategy(random);
  const hard = MinimaxMoveStrategy();
  return PlayCpuTurn(
    (difficulty) => switch (difficulty) {
      Difficulty.easy => easy,
      Difficulty.medium => medium,
      Difficulty.hard => hard,
    },
  );
});

final getScoreProvider = Provider<GetScore>(
  (ref) => GetScore(ref.watch(scoreRepositoryProvider)),
);

final recordGameOutcomeProvider = Provider<RecordGameOutcome>(
  (ref) => RecordGameOutcome(ref.watch(scoreRepositoryProvider)),
);
