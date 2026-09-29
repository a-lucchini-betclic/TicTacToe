import 'package:flutter/material.dart';
import 'package:tic_tac_toe/domain/entities/game.dart';
import 'package:tic_tac_toe/domain/entities/game_outcome.dart';
import 'package:tic_tac_toe/l10n/l10n.dart';

/// One line telling the player what is happening, announced to screen
/// readers whenever it changes.
class GameStatusText extends StatelessWidget {
  const GameStatusText(this.game, {super.key});

  final Game game;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final message = switch (game.outcome) {
      GameOutcome.win => l10n.statusYouWon,
      GameOutcome.loss => l10n.statusCpuWon,
      GameOutcome.draw => l10n.statusDraw,
      null when game.isHumanTurn => l10n.statusYourTurn,
      null => l10n.statusCpuThinking,
    };
    return Semantics(
      liveRegion: true,
      child: Text(
        message,
        style: Theme.of(context).textTheme.headlineSmall,
        textAlign: TextAlign.center,
      ),
    );
  }
}
