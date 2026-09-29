import 'package:equatable/equatable.dart';
import 'package:tic_tac_toe/domain/entities/difficulty.dart';
import 'package:tic_tac_toe/domain/entities/mark.dart';

/// The choices a player makes before a game starts.
class GameSettings extends Equatable {
  const GameSettings({required this.humanMark, required this.difficulty});

  /// The human's mark. Since X always moves first, picking O lets the CPU
  /// open the game.
  final Mark humanMark;
  final Difficulty difficulty;

  Mark get cpuMark => humanMark.opponent;

  @override
  List<Object?> get props => [humanMark, difficulty];
}
