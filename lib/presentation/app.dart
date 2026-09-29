import 'package:flutter/material.dart';
import 'package:tic_tac_toe/l10n/l10n.dart';
import 'package:tic_tac_toe/presentation/home/home_page.dart';
import 'package:tic_tac_toe/presentation/theme.dart';

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => context.l10n.appTitle,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomePage(),
    );
  }
}
