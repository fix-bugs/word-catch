/// 一局的长度、生命和得分。和画面分开，方便单独测试。
class GameRules {
  const GameRules._();

  /// 一局最多 8 题，适合低年级一次玩完。
  static const int rounds = 8;

  static const int lives = 3;

  /// 连击越高，这一下的分数越多。第一下 10 分，之后每次多 5 分。
  static int pointsForCombo(int combo) {
    final safe = combo < 1 ? 1 : combo;
    return 10 + (safe - 1) * 5;
  }

  /// 第 [roundIndex] 题（从 1 开始）里，最快的那张卡片落到篮口大约要几秒。
  ///
  /// 一开始留足阅读时间，后面轻轻加快，但不会快到看不清单词。
  static double fallSeconds(int roundIndex) {
    final eased = 4.2 - (roundIndex - 1) * 0.3;
    if (eased < 2.0) {
      return 2.0;
    }
    if (eased > 4.2) {
      return 4.2;
    }
    return eased;
  }
}
