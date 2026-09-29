import 'dart:math';

/// A [Random] that always returns the same values, to make randomized code
/// deterministic in tests.
class FixedRandom implements Random {
  FixedRandom([this.value = 0]);

  final int value;

  @override
  int nextInt(int max) => value % max;

  @override
  bool nextBool() => value.isOdd;

  @override
  double nextDouble() => 0;
}
