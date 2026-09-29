/// A symbol placed on the board. X always moves first.
enum Mark {
  x,
  o;

  Mark get opponent => switch (this) {
    Mark.x => Mark.o,
    Mark.o => Mark.x,
  };
}
