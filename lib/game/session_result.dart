import 'dart:ui';

/// 一局结束时交给结算页的成绩。
class SessionResult {
  const SessionResult({
    required this.themeId,
    required this.themeName,
    required this.themeColor,
    required this.score,
    required this.bestCombo,
    required this.caught,
    required this.roundsPlayed,
  });

  final String themeId;
  final String themeName;
  final Color themeColor;
  final int score;
  final int bestCombo;
  final int caught;
  final int roundsPlayed;
}
