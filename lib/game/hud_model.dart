import 'package:flutter/foundation.dart';

import 'session_result.dart';

/// 反馈文字的颜色：平常、接对、接错或漏接。
enum FeedbackTone { neutral, good, bad }

/// 游戏逻辑和上方中文提示之间的那一层。
///
/// 中文一律用 Flutter 文字画，不交给 Flame 的默认字体，避免缺字。
class HudModel extends ChangeNotifier {
  String prompt = '准备接住';
  String phonetic = '';
  String feedback = '看中文，接住英文单词';
  String hint = '点跑道，或按左右方向键';
  FeedbackTone tone = FeedbackTone.neutral;

  int lives = 3;
  int score = 0;
  int combo = 0;
  int bestCombo = 0;
  int round = 0;
  int totalRounds = 8;

  bool finished = false;
  SessionResult? result;

  void touch() {
    notifyListeners();
  }
}
