import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tic_tac_toe/data/models/score_dto.dart';
import 'package:tic_tac_toe/domain/entities/score.dart';
import 'package:tic_tac_toe/domain/repositories/score_repository.dart';

/// Stores the [Score] as JSON in the platform's key-value storage.
class SharedPreferencesScoreRepository implements ScoreRepository {
  const SharedPreferencesScoreRepository(this._preferences);

  /// Versioned so a future format change can migrate old data.
  @visibleForTesting
  static const String storageKey = 'score.v1';

  final SharedPreferences _preferences;

  @override
  Future<Score> load() async {
    final raw = _preferences.getString(storageKey);
    if (raw == null) return Score.zero;
    try {
      return ScoreDto.fromJson(jsonDecode(raw)).toDomain();
    } on FormatException catch (error) {
      // Corrupted data must not lock the player out: start over from zero.
      log('Discarding unreadable score', name: 'score', error: error);
      return Score.zero;
    }
  }

  @override
  Future<void> save(Score score) async {
    final saved = await _preferences.setString(
      storageKey,
      jsonEncode(ScoreDto.fromDomain(score).toJson()),
    );
    if (!saved) throw StateError('The score could not be saved.');
  }
}
