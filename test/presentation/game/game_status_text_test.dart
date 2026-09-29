import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/domain/entities/difficulty.dart';
import 'package:tic_tac_toe/domain/entities/game.dart';
import 'package:tic_tac_toe/domain/entities/game_settings.dart';
import 'package:tic_tac_toe/domain/entities/mark.dart';
import 'package:tic_tac_toe/presentation/game/widgets/game_status_text.dart';

import '../../helpers/board_builder.dart';
import '../../helpers/pump_app.dart';

void main() {
  const humanIsX = GameSettings(humanMark: Mark.x, difficulty: Difficulty.easy);
  const humanIsO = GameSettings(humanMark: Mark.o, difficulty: Difficulty.easy);

  final cases = <(String, Game)>[
    ('Your turn', Game(settings: humanIsX)),
    ('CPU is thinking…', Game(settings: humanIsO)),
    ('You won!', Game(settings: humanIsX, board: boardOf('XXXOO....'))),
    ('CPU wins', Game(settings: humanIsO, board: boardOf('XXXOO....'))),
    ("It's a draw", Game(settings: humanIsX, board: boardOf('XOXXOOOXX'))),
  ];

  group('GameStatusText', () {
    for (final (message, game) in cases) {
      testWidgets('shows "$message"', (tester) async {
        await tester.pumpApp(GameStatusText(game));

        expect(find.text(message), findsOneWidget);
      });
    }

    testWidgets('is a live region for screen readers', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpApp(GameStatusText(Game(settings: humanIsX)));

      expect(
        tester.getSemantics(find.text('Your turn')),
        isSemantics(isLiveRegion: true),
      );
      semantics.dispose();
    });
  });
}
