import 'package:flutter/material.dart';
import 'package:tic_tac_toe/domain/entities/board.dart';
import 'package:tic_tac_toe/domain/entities/mark.dart';
import 'package:tic_tac_toe/l10n/l10n.dart';
import 'package:tic_tac_toe/presentation/labels.dart';

/// Draws a [Board] as a square 3x3 grid.
///
/// Stateless and unaware of game rules: it only reports taps on empty cells.
class BoardView extends StatelessWidget {
  const BoardView({
    required this.board,
    required this.onCellTap,
    this.highlightedCells = const [],
    super.key,
  });

  final Board board;

  /// Called with the index of the tapped empty cell. `null` disables the
  /// whole board.
  final ValueChanged<int>? onCellTap;

  /// Cells to emphasize, typically the winning line.
  final List<int> highlightedCells;

  static const double _spacing = 8;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Column(
        spacing: _spacing,
        children: [
          for (var row = 0; row < 3; row++)
            Expanded(
              child: Row(
                spacing: _spacing,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var column = 0; column < 3; column++)
                    Expanded(child: _cellAt(row * 3 + column)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  _Cell _cellAt(int index) {
    final onCellTap = this.onCellTap;
    return _Cell(
      index: index,
      mark: board[index],
      highlighted: highlightedCells.contains(index),
      onTap: onCellTap == null || !board.isEmptyAt(index)
          ? null
          : () => onCellTap(index),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.index,
    required this.mark,
    required this.highlighted,
    required this.onTap,
  });

  final int index;
  final Mark? mark;
  final bool highlighted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final mark = this.mark;

    return Semantics(
      button: true,
      enabled: onTap != null,
      label: l10n.cellLabel(
        index ~/ 3 + 1,
        index % 3 + 1,
        mark?.symbol ?? l10n.cellEmpty,
      ),
      child: Material(
        color: highlighted
            ? colors.primaryContainer
            : colors.surfaceContainerHighest,
        // The fill alone is too close to the plain cells, so the winning line
        // also gets a border, which is drawn inside the cell (the default
        // stroke alignment) so the cell keeps its size.
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: highlighted
              ? BorderSide(color: colors.primary, width: 4)
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: ValueKey('cell-$index'),
          onTap: onTap,
          child: ExcludeSemantics(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: mark == null
                  ? const SizedBox.shrink()
                  : FractionallySizedBox(
                      key: ValueKey(mark),
                      heightFactor: 0.6,
                      child: FittedBox(
                        child: Text(
                          mark.symbol,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: switch (mark) {
                              Mark.x => colors.primary,
                              Mark.o => colors.tertiary,
                            },
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
