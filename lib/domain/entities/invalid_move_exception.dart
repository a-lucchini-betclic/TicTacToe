/// Thrown when a move breaks the rules of the game.
class InvalidMoveException implements Exception {
  const InvalidMoveException(this.message);

  final String message;

  @override
  String toString() => 'InvalidMoveException: $message';
}
