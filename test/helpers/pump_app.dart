import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/domain/repositories/score_repository.dart';
import 'package:tic_tac_toe/l10n/l10n.dart';
import 'package:tic_tac_toe/presentation/providers.dart';
import 'package:tic_tac_toe/presentation/theme.dart';

import 'in_memory_score_repository.dart';

extension PumpApp on WidgetTester {
  /// Pumps [widget] with the app's theme and localizations, in a
  /// [ProviderScope] that stores the score in memory.
  Future<void> pumpApp(
    Widget widget, {
    ScoreRepository? scoreRepository,
    List<Override> overrides = const [],
  }) {
    return pumpWidget(
      ProviderScope(
        overrides: [
          scoreRepositoryProvider.overrideWithValue(
            scoreRepository ?? InMemoryScoreRepository(),
          ),
          ...overrides,
        ],
        // Surface errors immediately instead of retrying in the background.
        retry: (_, _) => null,
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: widget,
        ),
      ),
    );
  }
}
