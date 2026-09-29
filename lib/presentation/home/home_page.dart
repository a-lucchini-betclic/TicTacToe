import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tic_tac_toe/domain/entities/difficulty.dart';
import 'package:tic_tac_toe/domain/entities/game_settings.dart';
import 'package:tic_tac_toe/domain/entities/mark.dart';
import 'package:tic_tac_toe/l10n/l10n.dart';
import 'package:tic_tac_toe/presentation/game/game_page.dart';
import 'package:tic_tac_toe/presentation/labels.dart';
import 'package:tic_tac_toe/presentation/score/score_board.dart';

/// Shows the score and lets the player set up the next game.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Mark _humanMark = Mark.x;
  Difficulty _difficulty = Difficulty.medium;

  void _startGame() {
    final settings = GameSettings(
      humanMark: _humanMark,
      difficulty: _difficulty,
    );
    unawaited(Navigator.of(context).push(GamePage.route(settings)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ScoreBoard(),
                  const SizedBox(height: 32),
                  Text(l10n.homeYourMark, style: textTheme.titleMedium),
                  const SizedBox(height: 8),
                  SegmentedButton<Mark>(
                    segments: [
                      for (final mark in Mark.values)
                        ButtonSegment(value: mark, label: Text(mark.symbol)),
                    ],
                    selected: {_humanMark},
                    onSelectionChanged: (selection) =>
                        setState(() => _humanMark = selection.single),
                  ),
                  const SizedBox(height: 4),
                  Text(l10n.homeMarkHint, style: textTheme.bodySmall),
                  const SizedBox(height: 24),
                  Text(l10n.homeDifficulty, style: textTheme.titleMedium),
                  const SizedBox(height: 8),
                  SegmentedButton<Difficulty>(
                    segments: [
                      for (final difficulty in Difficulty.values)
                        ButtonSegment(
                          value: difficulty,
                          label: Text(difficulty.label(l10n)),
                        ),
                    ],
                    selected: {_difficulty},
                    onSelectionChanged: (selection) =>
                        setState(() => _difficulty = selection.single),
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: _startGame,
                    child: Text(l10n.homeStartGame),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
