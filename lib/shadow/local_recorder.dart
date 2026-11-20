import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

/// 一次录音的结果。路径只指向本机文件或浏览器内存里的地址。
class LocalTake {
  const LocalTake({required this.ok, this.path, this.message});

  final bool ok;
  final String? path;

  /// 给孩子看的说明。失败时才有。
  final String? message;
}

/// 把跟读录在本机。
///
/// 网页上是浏览器的临时地址，手机上是临时文件。这里没有任何上传。
class LocalRecorder {
  /// 测试里关掉，避免申请麦克风。
  static bool enabled = true;

  AudioRecorder? _recorder;
  bool recording = false;

  AudioRecorder get _mic => _recorder ??= AudioRecorder();

  /// 点「开始录音」时才申请麦克风。
  Future<LocalTake> start() async {
    if (!enabled) {
      return const LocalTake(ok: false, message: '现在不能录音。');
    }
    try {
      final allowed = await _mic.hasPermission();
      if (!allowed) {
        return const LocalTake(ok: false, message: '没有打开麦克风。可以先听一听，录音先不用。');
      }
      final path = await _outputPath();
      await _mic.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 22050,
          numChannels: 1,
        ),
        path: path,
      );
      recording = true;
      return const LocalTake(ok: true);
    } catch (_) {
      recording = false;
      return const LocalTake(ok: false, message: '录音没有开始。可以再试一次，或者先听下一个。');
    }
  }

  /// 停止并留下这一段声音的本地地址。
  Future<LocalTake> stop() async {
    if (!enabled) {
      recording = false;
      return const LocalTake(ok: false, message: '现在不能录音。');
    }
    try {
      final path = await _mic.stop();
      recording = false;
      if (path == null || path.isEmpty) {
        return const LocalTake(ok: false, message: '没有录到声音。再试一次吧。');
      }
      return LocalTake(ok: true, path: path);
    } catch (_) {
      recording = false;
      return const LocalTake(ok: false, message: '录音没有保存下来。可以再试一次。');
    }
  }

  /// 丢掉正在录的这一段，比如孩子点了跳过。
  Future<void> cancel() async {
    recording = false;
    if (_recorder == null) {
      return;
    }
    try {
      await _mic.cancel();
    } catch (_) {}
  }

  Future<void> dispose() async {
    await cancel();
    try {
      await _recorder?.dispose();
    } catch (_) {}
    _recorder = null;
  }

  Future<String> _outputPath() async {
    if (kIsWeb) {
      // 网页上这个路径不会被使用，录音留在浏览器内存里。
      return 'shadow.wav';
    }
    final dir = await getTemporaryDirectory();
    return '${dir.path}/word_catch_shadow_${DateTime.now().microsecondsSinceEpoch}.wav';
  }
}
