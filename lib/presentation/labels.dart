import 'package:tic_tac_toe/domain/entities/difficulty.dart';
import 'package:tic_tac_toe/domain/entities/mark.dart';
import 'package:tic_tac_toe/l10n/l10n.dart';

/// User-facing names of domain values. Kept out of the domain layer, which
/// knows nothing about languages.
extension DifficultyLabel on Difficulty {
  String label(AppLocalizations l10n) => switch (this) {
    Difficulty.easy => l10n.difficultyEasy,
    Difficulty.medium => l10n.difficultyMedium,
    Difficulty.hard => l10n.difficultyHard,
  };
}

extension MarkSymbol on Mark {
  String get symbol => switch (this) {
    Mark.x => 'X',
    Mark.o => 'O',
  };
}
