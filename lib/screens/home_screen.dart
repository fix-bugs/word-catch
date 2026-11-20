import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../audio/sound_board.dart';
import '../data/word_bank.dart';
import '../style/palette.dart';
import '../style/playful_background.dart';
import 'play_screen.dart';
import 'shadow_screen.dart';

/// 首页：标题、主题、简短玩法，然后开始。
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _themeId = 'animal';

  static const List<String> _steps = [
    '选一个主题，然后开始接词，或者开始跟读。',
    '接词：看中文，在三条跑道里接住对应的英文。',
    '接对加分，还能连击。接错或漏接会失去一颗心。',
    '跟读：先听单词，再自己读。可以录音回放，录音不会上传。',
    '电脑接词用左右方向键或 A / D。手机点跑道，也可以左右滑动。',
  ];

  void _startCatch() {
    unawaited(SoundBoard.instance.play('move'));
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => PlayScreen(themeId: _themeId)),
    );
  }

  void _startShadow() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ShadowScreen(themeId: _themeId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themes = WordBank.themes;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PlayfulBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: _MuteButton(),
                          ),
                          const SizedBox(height: 4),
                          const Center(child: MascotBadge(size: 96)),
                          const SizedBox(height: 8),
                          const Text(
                            '单词捕手',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 48,
                              color: Palette.ink,
                              height: 1.05,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            '接住正确的英文单词',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF5C6B85),
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            '选一个主题',
                            style: TextStyle(fontSize: 20, color: Palette.ink),
                          ),
                          const SizedBox(height: 10),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final columns = constraints.maxWidth >= 560
                                  ? 4
                                  : 2;
                              return GridView.count(
                                crossAxisCount: columns,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                childAspectRatio: columns == 4 ? 1.45 : 1.28,
                                children: [
                                  for (final theme in themes)
                                    _ThemeCard(
                                      theme: theme,
                                      selected: theme.id == _themeId,
                                      onTap: () =>
                                          setState(() => _themeId = theme.id),
                                    ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            '怎么玩',
                            style: TextStyle(fontSize: 20, color: Palette.ink),
                          ),
                          const SizedBox(height: 8),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: const Color(0xF2FFFFFF),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                children: [
                                  for (var i = 0; i < _steps.length; i++)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${i + 1}. ',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Palette.coral,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              _steps[i],
                                              style: const TextStyle(
                                                fontSize: 16,
                                                height: 1.35,
                                                color: Palette.ink,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '接词一局 8 题、3 颗心。跟读一组最多 8 个词。',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF5C6B85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                    child: Column(
                      children: [
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Palette.coral,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(54),
                            textStyle: const TextStyle(
                              fontFamily: AppFonts.display,
                              fontSize: 22,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: _startCatch,
                          child: const Text('开始接词'),
                        ),
                        const SizedBox(height: 8),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF2FA36B),
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(54),
                            textStyle: const TextStyle(
                              fontFamily: AppFonts.display,
                              fontSize: 22,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: _startShadow,
                          child: const Text('开始跟读'),
                        ),
                      ],
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

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.theme,
    required this.selected,
    required this.onTap,
  });

  final WordTheme theme;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xF7FFFFFF),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? Palette.coral : const Color(0x00000000),
              width: 3,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: theme.color,
                  shape: BoxShape.circle,
                ),
              ),
              const Spacer(),
              Text(
                theme.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  height: 1.05,
                  color: Palette.ink,
                ),
              ),
              Text(
                theme.blurb,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.1,
                  color: Color(0xFF5C6B85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MuteButton extends StatelessWidget {
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
