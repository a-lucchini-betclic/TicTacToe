import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tic_tac_toe/data/repositories/shared_preferences_score_repository.dart';
import 'package:tic_tac_toe/presentation/app.dart';
import 'package:tic_tac_toe/presentation/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(await createApp());
}

/// Composition root: the only place that knows every layer. It plugs the
/// data layer's implementations into the domain ports the UI depends on.
Future<Widget> createApp() async {
  final preferences = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [
      scoreRepositoryProvider.overrideWithValue(
        SharedPreferencesScoreRepository(preferences),
      ),
    ],
    child: const TicTacToeApp(),
  );
}
