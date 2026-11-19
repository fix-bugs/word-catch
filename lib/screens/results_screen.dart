import 'package:material_ui/material_ui.dart';

import '../game/session_result.dart';
import '../style/palette.dart';
import '../style/playful_background.dart';
import 'play_screen.dart';

/// 一局结束。分数、最高连击、接住的单词数，然后可以再来或回首页。
class ResultsScreen extends StatelessWidget {
  const ResultsScreen({required this.result, super.key});

  final SessionResult result;

  String get _cheer {
    if (result.roundsPlayed > 0 && result.caught == result.roundsPlayed) {
      return '全部接住了，太厉害啦！';
    }
    if (result.caught == 0) {
      return '没关系，再来一局就更熟。';
    }
    return '已经记住一些词了，再玩一次吧。';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PlayfulBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                child: Column(
                  children: [
                    const MascotBadge(size: 96),
                    const SizedBox(height: 8),
                    const Text(
                      '本局结束',
                      style: TextStyle(fontSize: 36, color: Palette.ink),
                    ),
                    const SizedBox(height: 8),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: result.themeColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                        child: Text(
                          result.themeName,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      '${result.score}',
                      style: const TextStyle(
                        fontFamily: AppFonts.latin,
                        fontWeight: FontWeight.w700,
                        fontSize: 64,
                        height: 1,
                        color: Palette.coral,
                      ),
                    ),
                    const Text(
                      '得分',
                      style: TextStyle(fontSize: 18, color: Palette.ink),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: '最高连击',
                            value: '${result.bestCombo}',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _StatCard(
                            label: '接住单词',
                            value: '${result.caught}',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '本局进行了 ${result.roundsPlayed} 题',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF5C6B85),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _cheer,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, color: Palette.ink),
                    ),
                    const SizedBox(height: 22),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Palette.coral,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(56),
                        textStyle: const TextStyle(
                          fontFamily: AppFonts.display,
                          fontSize: 22,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute<void>(
                            builder: (_) => PlayScreen(themeId: result.themeId),
                          ),
                        );
                      },
                      child: const Text('再来一局'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        '返回首页',
                        style: TextStyle(fontSize: 18, color: Palette.ink),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xF4FFFFFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontFamily: AppFonts.latin,
                fontWeight: FontWeight.w700,
                fontSize: 32,
                color: Palette.ink,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 15, color: Color(0xFF5C6B85)),
            ),
          ],
        ),
      ),
    );
  }
}
