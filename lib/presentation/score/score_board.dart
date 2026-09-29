import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tic_tac_toe/l10n/l10n.dart';
import 'package:tic_tac_toe/presentation/score/score_controller.dart';

/// The player's wins, draws and losses against the CPU.
class ScoreBoard extends ConsumerWidget {
  const ScoreBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final score = ref.watch(scoreControllerProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        // A failed save leaves an error next to the previous score: keep
        // showing it. The error text is for a score that never loaded.
        child: score.when(
          skipError: true,
          data: (score) => Row(
            children: [
              _Stat(label: l10n.scoreWins, value: score.wins),
              _Stat(label: l10n.scoreDraws, value: score.draws),
              _Stat(label: l10n.scoreLosses, value: score.losses),
            ],
          ),
          error: (_, _) => Text(
            l10n.scoreLoadError,
            textAlign: TextAlign.center,
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: MergeSemantics(
        child: Column(
          children: [
            Text('$value', style: textTheme.headlineMedium),
            Text(label, style: textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}
