import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/word_entry.dart';
import '../../style/palette.dart';

/// 落下的单词胶囊。
///
/// 做成圆角胶囊，而不是障碍物：孩子要先读出英文，再决定站到哪一列。
class WordCard extends PositionComponent {
  WordCard({
    required this.word,
    required this.lane,
    required this.isTarget,
    required this.color,
  }) : super(priority: 0, anchor: Anchor.topLeft);

  final WordEntry word;
  final int lane;
  final bool isTarget;
  final Color color;

  double _time = 0;
  TextPainter? _painter;
  double _paintedWidth = -1;

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    if (size.x < 2 || size.y < 2) {
      return;
    }
    canvas.save();
    // 只晃角度，不改真实坐标，避免影响接住判定。
    final wobble = math.sin(_time * 2.2 + lane) * 0.035;
    canvas.translate(size.x / 2, size.y / 2);
    canvas.rotate(wobble);
    canvas.translate(-size.x / 2, -size.y / 2);

    final body = RRect.fromRectAndRadius(
      Offset.zero & Size(size.x, size.y),
      Radius.circular(size.y / 2),
    );
    canvas.drawRRect(
      body.shift(const Offset(0, 5)),
      Paint()..color = const Color(0x33000000),
    );
    canvas.drawRRect(body, Paint()..color = const Color(0xFFFFFFF5));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(3, 3, size.x - 6, size.y * 0.46),
        Radius.circular(size.y / 2),
      ),
      Paint()..color = color.withValues(alpha: 0.22),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = color,
    );
    canvas.drawCircle(
      Offset(size.y * 0.42, size.y / 2),
      size.y * 0.12,
      Paint()..color = color,
    );

    final painter = _textPainter(size.x - size.y * 0.7);
    painter.paint(
      canvas,
      Offset(
        (size.x - painter.width) / 2 + size.y * 0.08,
        (size.y - painter.height) / 2,
      ),
    );
    canvas.restore();
  }

  TextPainter _textPainter(double maxWidth) {
    final cached = _painter;
    if (cached != null && _paintedWidth == maxWidth) {
      return cached;
    }
    var font = 30.0;
    TextPainter? painter;
    while (font >= 13) {
      painter = TextPainter(
        text: TextSpan(
          text: word.en,
          style: TextStyle(
            fontFamily: AppFonts.latin,
            fontWeight: FontWeight.w700,
            fontSize: font,
            color: Palette.ink,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      if (painter.width <= maxWidth) {
        break;
      }
      font -= 1;
    }
    _painter = painter;
    _paintedWidth = maxWidth;
    return painter!;
  }
}
