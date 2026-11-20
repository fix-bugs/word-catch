import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// 很短的占位音效，文件由程序生成，不是教材录音。
///
/// 播放失败就静默跳过，对局不依赖声音。
class SoundBoard {
  SoundBoard._();

  static final SoundBoard instance = SoundBoard._();

  /// 测试里关掉，避免去调平台通道。
  static bool enabled = true;

  /// 首页和对局共用的静音开关，不写入磁盘。
  static final muted = ValueNotifier<bool>(false);

  final Map<String, AudioPlayer> _players = {};

  Future<void> play(String name) async {
    if (!enabled || muted.value) {
      return;
    }
    try {
      final player = _players.putIfAbsent(name, AudioPlayer.new);
      await player.stop();
      await player.play(AssetSource('sfx/$name.wav'));
    } catch (error) {
      debugPrint('音效播放失败：$error');
    }
  }
}
