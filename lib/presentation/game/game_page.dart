import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tic_tac_toe/domain/entities/game_settings.dart';
import 'package:tic_tac_toe/domain/entities/game_status.dart';
import 'package:tic_tac_toe/l10n/l10n.dart';
import 'package:tic_tac_toe/presentation/game/game_controller.dart';
import 'package:tic_tac_toe/presentation/game/widgets/board_view.dart';
import 'package:tic_tac_toe/presentation/game/widgets/game_status_text.dart';
import 'package:tic_tac_toe/presentation/labels.dart';

const double _padding = 24;
const double _maxBoardSide = 480;
const double _minTapTarget = 48;

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

    final summary = Text(
      l10n.gameSummary(
        settings.humanMark.symbol,
        settings.difficulty.label(l10n),
      ),
      style: Theme.of(context).textTheme.titleMedium,
      textAlign: TextAlign.center,
    );
    final status = GameStatusText(game);
    final board = BoardView(
      board: game.board,
      highlightedCells: switch (game.status) {
        GameWon(:final line) => line.cells,
        _ => const [],
      },
      onCellTap: game.isHumanTurn ? controller.play : null,
    );
    // Always reserves room for the button so the board does not jump when it
    // shows, yet grows with the text size instead of clipping the label.
    final playAgain = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: _minTapTarget),
      child: game.isOver
          ? FilledButton.icon(
              onPressed: controller.restart,
              icon: const Icon(Icons.replay),
              label: Text(l10n.playAgain),
            )
          : null,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(_padding),
          child: LayoutBuilder(
            builder: (context, constraints) =>
                constraints.maxWidth > constraints.maxHeight
                ? _Landscape(
                    constraints: constraints,
                    board: board,
                    panel: [
                      summary,
                      const SizedBox(height: 8),
                      status,
                      const SizedBox(height: 24),
                      playAgain,
                    ],
                  )
                : Column(
                    children: [
                      summary,
                      const SizedBox(height: 8),
                      status,
                      const SizedBox(height: 24),
                      Expanded(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: _maxBoardSide,
                            ),
                            child: board,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      playAgain,
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// The board on one side, sized by the available height, and the summary,
/// status and Play-again button on the other, scrolling if they do not fit.
class _Landscape extends StatelessWidget {
  const _Landscape({
    required this.constraints,
    required this.board,
    required this.panel,
  });

  final BoxConstraints constraints;
  final Widget board;
  final List<Widget> panel;

  @override
  Widget build(BuildContext context) {
    // Leaves at least 40 % of the width to the panel on near-square screens.
    final boardSide = min(
      min(constraints.maxHeight, _maxBoardSide),
      constraints.maxWidth * 0.6,
    );
    return Row(
      spacing: _padding,
      children: [
        SizedBox.square(dimension: boardSide, child: board),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: panel),
            ),
          ),
        ),
      ],
    );
  }
}
