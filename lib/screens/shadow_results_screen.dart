import 'package:material_ui/material_ui.dart';

import '../style/palette.dart';
import '../style/playful_background.dart';
import 'shadow_screen.dart';

/// 一组跟读结束时给孩子看的小结。没有分数。
class ShadowSummary {
  const ShadowSummary({
    required this.themeId,
    required this.themeName,
    required this.themeColor,
    required this.heard,
    required this.recorded,
    required this.skipped,
    required this.total,
  });

  final String themeId;
  final String themeName;
  final Color themeColor;
  final int heard;
  final int recorded;
  final int skipped;
  final int total;
}

class ShadowResultsScreen extends StatelessWidget {
  const ShadowResultsScreen({required this.summary, super.key});

  final ShadowSummary summary;

  String get _cheer {
    if (summary.recorded == 0) {
      return '这次先听了听。下次可以试着自己读出来。';
    }
    if (summary.recorded == summary.total) {
      return '每个词都跟读了，真棒！';
    }
    return '已经跟着读了一些词，再来一组也行。';
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
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                child: Column(
                  children: [
                    const MascotBadge(size: 88),
                    const SizedBox(height: 8),
                    const Text(
                      '跟读结束',
                      style: TextStyle(fontSize: 36, color: Palette.ink),
                    ),
                    const SizedBox(height: 8),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: summary.themeColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                        child: Text(
                          summary.themeName,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _Count(label: '听过', value: summary.heard),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _Count(label: '录下', value: summary.recorded),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _Count(label: '跳过', value: summary.skipped),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '这一组共 ${summary.total} 个词',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF5C6B85),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _cheer,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.35,
                        color: Palette.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '录音只留在这台设备上，没有上传。',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Color(0xFF5C6B85)),
                    ),
                    const SizedBox(height: 20),
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
                            builder: (_) =>
                                ShadowScreen(themeId: summary.themeId),
                          ),
                        );
                      },
                      child: const Text('再跟一组'),
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

class _Count extends StatelessWidget {
  const _Count({required this.label, required this.value});

  final String label;
  final int value;

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
              '$value',
              style: const TextStyle(
                fontFamily: AppFonts.latin,
                fontWeight: FontWeight.w700,
                fontSize: 28,
                height: 1,
                color: Palette.ink,
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
