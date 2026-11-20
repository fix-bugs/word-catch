import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import '../data/word_bank.dart';
import '../data/word_entry.dart';
import '../shadow/local_recorder.dart';
import '../shadow/model_voice.dart';
import '../shadow/shadow_queue.dart';
import '../style/palette.dart';
import '../style/playful_background.dart';
import 'shadow_results_screen.dart';

/// 跟读：听单词，自己读，再听自己的声音。不打分，也不上传录音。
class ShadowScreen extends StatefulWidget {
  const ShadowScreen({required this.themeId, super.key});

  final String themeId;

  @override
  State<ShadowScreen> createState() => _ShadowScreenState();
}

class _ShadowScreenState extends State<ShadowScreen> {
  final ModelVoice _voice = ModelVoice();
  final LocalRecorder _recorder = LocalRecorder();
  late final List<WordEntry> _words;
  late final WordTheme _theme;

  AudioPlayer? _playback;
  Timer? _autoStop;

  int _index = 0;
  int _skipped = 0;
  final Set<int> _heard = {};
  final Set<int> _recorded = {};

  bool _recording = false;
  String? _takePath;
  String _hint = '先听一听，再跟着读。';

  static const List<String> _cheers = [
    '录好啦！听一听自己的声音。',
    '真棒，你跟读了！',
    '说得很认真，可以再听一遍。',
  ];

  @override
  void initState() {
    super.initState();
    _theme = WordBank.themeById(widget.themeId);
    _words = buildShadowQueue(WordBank.wordsFor(widget.themeId), Random());
    WidgetsBinding.instance.addPostFrameCallback((_) => _playModel());
  }

  @override
  void dispose() {
    _autoStop?.cancel();
    unawaited(_voice.stop());
    unawaited(_recorder.dispose());
    unawaited(_playback?.dispose());
    super.dispose();
  }

  WordEntry? get _word =>
      _index >= 0 && _index < _words.length ? _words[_index] : null;

  Future<void> _playModel() async {
    final word = _word;
    if (word == null) {
      return;
    }
    await _stopPlayback();
    final ok = await _voice.speak(word.en);
    if (!mounted || _word?.id != word.id) {
      return;
    }
    setState(() {
      if (ok) {
        _heard.add(_index);
        _hint = '听一听，再跟着读。';
      } else {
        _hint = '这台设备暂时读不出来。你可以看着单词自己读。';
      }
    });
  }

  Future<void> _toggleRecord() async {
    if (_recording) {
      await _finishRecording();
      return;
    }
    await _voice.stop();
    await _stopPlayback();
    final started = await _recorder.start();
    if (!mounted) {
      return;
    }
    if (!started.ok) {
      setState(() => _hint = started.message ?? '录音没有开始。');
      return;
    }
    setState(() {
      _recording = true;
      _takePath = null;
      _hint = '正在听你读…说完再点停止。';
    });
    _autoStop?.cancel();
    // 小孩有时忘了点停止，录太久就自动停下来。
    _autoStop = Timer(const Duration(seconds: 8), () {
      if (mounted && _recording) {
        unawaited(_finishRecording());
      }
    });
  }

  Future<void> _finishRecording() async {
    _autoStop?.cancel();
    final take = await _recorder.stop();
    if (!mounted) {
      return;
    }
    setState(() {
      _recording = false;
      if (take.ok && take.path != null) {
        _takePath = take.path;
        _recorded.add(_index);
        _hint = _cheers[_recorded.length % _cheers.length];
      } else {
        _hint = take.message ?? '没有录到声音。再试一次吧。';
      }
    });
  }

  Future<void> _playTake() async {
    final path = _takePath;
    if (path == null) {
      return;
    }
    await _voice.stop();
    final player = _playback ??= AudioPlayer();
    await player.stop();
    final source = kIsWeb ? UrlSource(path) : DeviceFileSource(path);
    try {
      await player.play(source);
      if (!mounted) {
        return;
      }
      setState(() => _hint = '这是你刚才读的声音。');
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _hint = '这段录音暂时放不出来。可以再录一次。');
    }
  }

  Future<void> _stopPlayback() async {
    try {
      await _playback?.stop();
    } catch (_) {}
  }

  Future<void> _skip() async {
    _autoStop?.cancel();
    await _voice.stop();
    await _recorder.cancel();
    await _stopPlayback();
    if (!mounted) {
      return;
    }
    setState(() {
      _recording = false;
      _skipped += 1;
      _hint = '这个先跳过。';
    });
    _advance();
  }

  Future<void> _next() async {
    if (_recording) {
      await _finishRecording();
    }
    await _voice.stop();
    await _stopPlayback();
    _advance();
  }

  void _advance() {
    if (_index + 1 >= _words.length) {
      _openResults();
      return;
    }
    setState(() {
      _index += 1;
      _takePath = null;
      _recording = false;
      _hint = '先听一听，再跟着读。';
    });
    unawaited(_playModel());
  }

  void _openResults() {
    if (!mounted) {
      return;
    }
    final summary = ShadowSummary(
      themeId: _theme.id,
      themeName: _theme.name,
      themeColor: _theme.color,
      heard: _heard.length,
      recorded: _recorded.length,
      skipped: _skipped,
      total: _words.length,
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ShadowResultsScreen(summary: summary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final word = _word;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PlayfulBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: word == null
                  ? const Center(child: Text('这个主题里没有单词。'))
                  : Column(
                      children: [
                        _topBar(),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    word.en,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: AppFonts.latin,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 52,
                                      height: 1.05,
                                      color: Palette.ink,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  word.meaning,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    color: Palette.ink,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '英 /${word.ipaUk}/',
                                  style: const TextStyle(
                                    fontFamily: AppFonts.latin,
                                    fontSize: 18,
                                    color: Color(0xFF5C6B85),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _hint,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.3,
                                    color: Palette.ink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                          child: _actions(),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 12, 0),
      child: Row(
        children: [
          IconButton(
            tooltip: '返回',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded),
            color: Palette.ink,
          ),
          Expanded(
            child: Text(
              '${_theme.name}  ·  第 ${_index + 1} / ${_words.length} 个',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Palette.ink),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _actions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF3D6FE8),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
            textStyle: const TextStyle(
              fontFamily: AppFonts.display,
              fontSize: 20,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: _recording ? null : () => unawaited(_playModel()),
          icon: const Icon(Icons.volume_up_rounded),
          label: const Text('听一听'),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: _recording ? Palette.bad : Palette.coral,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
            textStyle: const TextStyle(
              fontFamily: AppFonts.display,
              fontSize: 20,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: () => unawaited(_toggleRecord()),
          icon: Icon(_recording ? Icons.stop_rounded : Icons.mic_rounded),
          label: Text(
            _recording ? '停止录音' : (_takePath == null ? '开始录音' : '再录一次'),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: Palette.ink,
            minimumSize: const Size.fromHeight(48),
            textStyle: const TextStyle(
              fontFamily: AppFonts.display,
              fontSize: 20,
            ),
            side: const BorderSide(color: Color(0xFF8AA0C4), width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: _takePath == null || _recording
              ? null
              : () => unawaited(_playTake()),
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('听我的'),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: _recording ? null : () => unawaited(_skip()),
                child: const Text(
                  '跳过',
                  style: TextStyle(fontSize: 18, color: Color(0xFF5C6B85)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2FA36B),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  textStyle: const TextStyle(
                    fontFamily: AppFonts.display,
                    fontSize: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => unawaited(_next()),
                child: Text(_index + 1 >= _words.length ? '看结果' : '下一个'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
