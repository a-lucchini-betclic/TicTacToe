import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/domain/entities/mark.dart';

void main() {
  group('Mark', () {
    test('opponent of X is O and vice versa', () {
      expect(Mark.x.opponent, Mark.o);
      expect(Mark.o.opponent, Mark.x);
    });
  });
}
