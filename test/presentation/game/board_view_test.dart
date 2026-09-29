import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/domain/entities/board.dart';
import 'package:tic_tac_toe/presentation/game/widgets/board_view.dart';
import 'package:tic_tac_toe/presentation/theme.dart';

import '../../helpers/board_builder.dart';
import '../../helpers/pump_app.dart';

Finder _cell(int index) => find.byKey(ValueKey('cell-$index'));

void main() {
  group('BoardView', () {
    Future<void> pumpBoard(
      WidgetTester tester,
      Board board, {
      ValueChanged<int>? onCellTap,
      List<int> highlightedCells = const [],
    }) => tester.pumpApp(
      Scaffold(
        body: BoardView(
          board: board,
          onCellTap: onCellTap,
          highlightedCells: highlightedCells,
        ),
      ),
    );

    testWidgets('shows the marks on the board', (tester) async {
      await pumpBoard(tester, boardOf('X...O....'), onCellTap: (_) {});

      expect(find.text('X'), findsOneWidget);
      expect(find.text('O'), findsOneWidget);
    });

    testWidgets('cells keep the same size whatever they hold', (tester) async {
      await pumpBoard(tester, boardOf('X...O....'), onCellTap: (_) {});

      final emptyCellSize = tester.getSize(_cell(8));

      expect(tester.getSize(_cell(0)), emptyCellSize);
      expect(tester.getSize(_cell(4)), emptyCellSize);
    });

    testWidgets('reports taps on empty cells', (tester) async {
      final taps = <int>[];
      await pumpBoard(tester, boardOf('X...O....'), onCellTap: taps.add);

      await tester.tap(_cell(8));

      expect(taps, [8]);
    });

    testWidgets('ignores taps on taken cells', (tester) async {
      final taps = <int>[];
      await pumpBoard(tester, boardOf('X...O....'), onCellTap: taps.add);

      await tester.tap(_cell(0));
      await tester.tap(_cell(4));

      expect(taps, isEmpty);
    });

    testWidgets('disables every cell without onCellTap', (tester) async {
      await pumpBoard(tester, Board.empty());

      for (var index = 0; index < Board.cellCount; index++) {
        expect(tester.widget<InkWell>(_cell(index)).onTap, isNull);
      }
    });

    testWidgets('describes each cell to screen readers', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpBoard(tester, boardOf('X...O....'), onCellTap: (_) {});

      expect(find.bySemanticsLabel('Row 1, column 1: X'), findsOneWidget);
      expect(find.bySemanticsLabel('Row 2, column 2: O'), findsOneWidget);
      expect(find.bySemanticsLabel('Row 3, column 3: empty'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('highlights the given cells', (tester) async {
      await pumpBoard(
        tester,
        boardOf('XXXOO....'),
        highlightedCells: [0, 1, 2],
      );

      Material materialOf(int index) => tester.widget<Material>(
        find.ancestor(of: _cell(index), matching: find.byType(Material)).first,
      );
      BorderSide borderOf(int index) => switch (materialOf(index).shape) {
        RoundedRectangleBorder(:final side) => side,
        _ => BorderSide.none,
      };

      expect(materialOf(0).color, materialOf(2).color);
      expect(materialOf(0).color, isNot(materialOf(3).color));
      for (final index in [0, 1, 2]) {
        expect(
          borderOf(index),
          BorderSide(color: AppTheme.light.colorScheme.primary, width: 4),
        );
      }
      for (final index in [3, 4, 5, 6, 7, 8]) {
        expect(borderOf(index), BorderSide.none);
      }
    });

    testWidgets('draws the highlight inside the cell', (tester) async {
      await pumpBoard(tester, boardOf('XXXOO....'));
      final plainSize = tester.getSize(_cell(0));

      await pumpBoard(
        tester,
        boardOf('XXXOO....'),
        highlightedCells: [0, 1, 2],
      );

      expect(tester.getSize(_cell(0)), plainSize);
    });
  });
}
