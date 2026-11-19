import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../audio/sound_board.dart';
import '../game/hud_model.dart';
import '../game/word_catch_game.dart';
import '../style/palette.dart';
import '../style/playful_background.dart';
import 'results_screen.dart';

/// 一局对局。上方是中文提示，下面是 Flame 画的三条跑道。
class PlayScreen extends StatefulWidget {
  const PlayScreen({required this.themeId, super.key});

  final String themeId;

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  late final WordCatchGame _game;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _game = WordCatchGame(themeId: widget.themeId);
    _game.hud.addListener(_onHud);
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    _game.hud.removeListener(_onHud);
    super.dispose();
  }

  /// 方向键和 A / D 控制左右。按住不连发，避免一下滑过两列。
  bool _onKey(KeyEvent event) {
    if (event is! KeyDownEvent) {
      return false;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowLeft || key == LogicalKeyboardKey.keyA) {
      _game.moveBy(-1);
      return true;
    }
    if (key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.keyD) {
      _game.moveBy(1);
      return true;
    }
    return false;
  }

  void _onHud() {
    final result = _game.hud.result;
    if (!_game.hud.finished || result == null || _navigated || !mounted) {
      return;
    }
    _navigated = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => ResultsScreen(result: result)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).height < 680;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PlayfulBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                children: [
                  _Hud(game: _game, compact: compact),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Stack(
                          children: [
                            GameWidget<WordCatchGame>(
                              game: _game,
                              autofocus: false,
                              loadingBuilder: (_) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorBuilder: (context, error) => Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    '画面出错了\n$error',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            _LanePointerPad(
                              onTapLane: _game.moveToPoint,
                              onSwipe: _game.moveBy,
                            ),
                          ],
                        ),
                      ),
                    ),
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

class _Hud extends StatelessWidget {
  const _Hud({required this.game, required this.compact});

  final WordCatchGame game;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: game.hud,
      builder: (context, _) {
        final hud = game.hud;
        final feedbackColor = switch (hud.tone) {
          FeedbackTone.good => Palette.good,
          FeedbackTone.bad => Palette.bad,
          FeedbackTone.neutral => const Color(0xFF5C6B85),
        };
        return Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xF4FFFFFF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        tooltip: '返回',
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: Palette.ink,
                      ),
                      Expanded(
                        child: Text(
                          hud.round == 0
                              ? '准备'
                              : '第 ${hud.round} / ${hud.totalRounds} 题',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Palette.ink,
                          ),
                        ),
                      ),
                      const Text(
                        '分数 ',
                        style: TextStyle(fontSize: 16, color: Palette.ink),
                      ),
                      Text(
                        '${hud.score}',
                        style: const TextStyle(
                          fontFamily: AppFonts.latin,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Palette.ink,
                        ),
                      ),
                      const _MuteButton(),
                    ],
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      hud.prompt,
                      style: TextStyle(
                        fontSize: compact ? 32 : 40,
                        color: Palette.ink,
                        height: 1.1,
                      ),
                    ),
                  ),
                  if (hud.phonetic.isNotEmpty)
                    Text(
                      hud.phonetic,
                      style: const TextStyle(
                        fontFamily: AppFonts.latin,
                        fontSize: 16,
                        color: Color(0xFF5C6B85),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < 3; i++)
                        Icon(
                          i < hud.lives
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: i < hud.lives
                              ? const Color(0xFFE85D4C)
                              : const Color(0xFFB7C0D0),
                          size: 22,
                        ),
                      const SizedBox(width: 12),
                      const Text(
                        '连击 ',
                        style: TextStyle(fontSize: 16, color: Palette.ink),
                      ),
                      Text(
                        '${hud.combo}',
                        style: const TextStyle(
                          fontFamily: AppFonts.latin,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Palette.ink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: compact ? 22 : 26,
                    child: Text(
                      hud.feedback.isEmpty ? hud.hint : hud.feedback,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: compact ? 15 : 17,
                        color: feedbackColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MuteButton extends StatelessWidget {
  const _MuteButton();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: SoundBoard.muted,
      builder: (context, muted, _) {
        return IconButton(
          tooltip: muted ? '打开声音' : '关闭声音',
          onPressed: () => SoundBoard.muted.value = !muted,
          icon: Icon(
            muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
          ),
          color: Palette.ink,
        );
      },
    );
  }
}

/// 盖在跑道上的触摸层：轻点选列，左右滑一列。
///
/// 放在 Flutter 里而不是 Flame 的手势系统里，是为了和上方按钮互不抢事件。
class _LanePointerPad extends StatefulWidget {
  const _LanePointerPad({required this.onTapLane, required this.onSwipe});

  final void Function(double x) onTapLane;
  final void Function(int direction) onSwipe;

  @override
  State<_LanePointerPad> createState() => _LanePointerPadState();
}

class _LanePointerPadState extends State<_LanePointerPad> {
  Offset? _start;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (event) => _start = event.localPosition,
      onPointerUp: (event) {
        final start = _start;
        _start = null;
        if (start == null) {
          return;
        }
        final dx = event.localPosition.dx - start.dx;
        final dy = event.localPosition.dy - start.dy;
        if (dx.abs() >= 48 && dx.abs() > dy.abs()) {
          widget.onSwipe(dx < 0 ? -1 : 1);
          return;
        }
        if (dx.abs() < 28 && dy.abs() < 28) {
          widget.onTapLane(start.dx);
        }
      },
    );
  }
}
