import 'package:flutter_tts/flutter_tts.dart';

/// 用设备或浏览器自带的语音，把英文单词读出来。
///
/// 不打包教材录音。读不出来时返回失败，跟读页会改用文字说明。
class ModelVoice {
  /// 测试里关掉，避免去调语音插件。
  static bool enabled = true;

  FlutterTts? _tts;
  bool _prepared = false;

  Future<bool> speak(String text) async {
    if (!enabled || text.trim().isEmpty) {
      return false;
    }
    try {
      final tts = _tts ??= FlutterTts();
      if (!_prepared) {
        // 语速放慢一点，方便一年级跟着听。不同平台的范围不一样，失败就用默认速度。
        try {
          await tts.setSpeechRate(0.42);
        } catch (_) {}
        try {
          await tts.setVolume(1);
        } catch (_) {}
        // 词库显示的是英音，优先用英式英语。没有就退回美式。
        final british = await tts.setLanguage('en-GB');
        if (british == false || british == 0 || british == '0') {
          await tts.setLanguage('en-US');
        }
        _prepared = true;
      }
      await tts.stop();
      final result = await tts.speak(text);
      if (result == false || result == 0 || result == '0') {
        return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> stop() async {
    try {
      await _tts?.stop();
    } catch (_) {}
  }
}
