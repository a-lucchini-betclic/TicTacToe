import 'package:equatable/equatable.dart';
import 'package:tic_tac_toe/domain/entities/invalid_move_exception.dart';
import 'package:tic_tac_toe/domain/entities/mark.dart';

/// Three cells aligned in a row, a column or a diagonal, all held by [mark].
class WinningLine extends Equatable {
  const WinningLine({required this.mark, required this.cells});

  final Mark mark;
  final List<int> cells;

  @override
  List<Object?> get props => [mark, cells];
}

/// An immutable 3x3 Tic-Tac-Toe board.
///
/// Cells are addressed by index, row by row:
///
/// ```text
///  0 | 1 | 2
///  3 | 4 | 5
///  6 | 7 | 8
/// ```
class Board extends Equatable {
  Board.empty() : cells = List<Mark?>.unmodifiable(List<Mark?>.filled(9, null));

  Board.fromCells(List<Mark?> cells)
    : assert(cells.length == cellCount, 'A board has $cellCount cells'),
      cells = List<Mark?>.unmodifiable(cells);

  static const int cellCount = 9;

  static const List<List<int>> lines = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
  ];

  final List<Mark?> cells;

  Mark? operator [](int index) => cells[index];

  bool isEmptyAt(int index) => cells[index] == null;

  List<int> get emptyCells => [
    for (var i = 0; i < cellCount; i++)
      if (cells[i] == null) i,
  ];

  bool get isFull => cells.every((cell) => cell != null);

  /// The mark whose turn it is, derived from the marks already placed.
  Mark get nextMark {
    final xCount = cells.where((cell) => cell == Mark.x).length;
    final oCount = cells.where((cell) => cell == Mark.o).length;
    return xCount == oCount ? Mark.x : Mark.o;
  }

  WinningLine? get winningLine {
    for (final line in lines) {
      final mark = cells[line[0]];
      if (mark != null && cells[line[1]] == mark && cells[line[2]] == mark) {
        return WinningLine(mark: mark, cells: line);
      }
    }
    return null;
  }

  /// Returns a new board with [mark] placed at [index].
  ///
  /// Throws a [RangeError] if [index] is outside the board and an
  /// [InvalidMoveException] if the cell is already taken.
  Board place(int index, Mark mark) {
    RangeError.checkValidIndex(index, cells, 'index', cellCount);
    if (!isEmptyAt(index)) {
      throw InvalidMoveException('Cell $index is already taken.');
    }
    return Board.fromCells([...cells]..[index] = mark);
  }

  @override
  List<Object?> get props => [cells];
}
