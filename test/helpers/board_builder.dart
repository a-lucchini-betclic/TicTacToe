import 'package:tic_tac_toe/domain/entities/board.dart';
import 'package:tic_tac_toe/domain/entities/mark.dart';

/// Builds a [Board] from a readable layout: `X`, `O` or `.` per cell, row by
/// row. Whitespace is ignored.
///
/// ```dart
/// final board = boardOf('''
///   X O .
///   . X .
///   . . O
/// ''');
/// ```
Board boardOf(String layout) {
  final symbols = layout.replaceAll(RegExp(r'\s'), '').split('');
  if (symbols.length != Board.cellCount) {
    throw ArgumentError.value(layout, 'layout', 'must describe 9 cells');
  }
  return Board.fromCells([
    for (final symbol in symbols)
      switch (symbol) {
        'X' => Mark.x,
        'O' => Mark.o,
        '.' => null,
        _ => throw ArgumentError.value(symbol, 'layout', 'unknown symbol'),
      },
  ]);
}
