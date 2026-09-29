import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tic_tac_toe/domain/entities/game_settings.dart';
import 'package:tic_tac_toe/domain/entities/game_status.dart';
import 'package:tic_tac_toe/l10n/l10n.dart';
import 'package:tic_tac_toe/presentation/game/game_controller.dart';
import 'package:tic_tac_toe/presentation/game/widgets/board_view.dart';
import 'package:tic_tac_toe/presentation/game/widgets/game_status_text.dart';
import 'package:tic_tac_toe/presentation/labels.dart';

class GamePage extends ConsumerWidget {
  const GamePage({required this.settings, super.key});

  static Route<void> route(GameSettings settings) =>
      MaterialPageRoute(builder: (_) => GamePage(settings: settings));

  final GameSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final provider = gameControllerProvider(settings);
    final game = ref.watch(provider);
    final controller = ref.read(provider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                l10n.gameSummary(
                  settings.humanMark.symbol,
                  settings.difficulty.label(l10n),
                ),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              GameStatusText(game),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: BoardView(
                      board: game.board,
                      highlightedCells: switch (game.status) {
                        GameWon(:final line) => line.cells,
                        _ => const [],
                      },
                      onCellTap: game.isHumanTurn ? controller.play : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Fixed height so the board does not jump when the button shows.
              SizedBox(
                height: 48,
                child: game.isOver
                    ? FilledButton.icon(
                        onPressed: controller.restart,
                        icon: const Icon(Icons.replay),
                        label: Text(l10n.playAgain),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
