import 'package:flame/components.dart';
import 'package:material_ui/material_ui.dart';

/// 三条竖直跑道。玩家所在的那一列会亮一圈，方便对上手指和键盘。
class LaneBackdrop extends PositionComponent {
  LaneBackdrop() : super(priority: -10, anchor: Anchor.topLeft);

  int activeLane = 1;

  static const List<Color> _fills = [
    Color(0x66FFE08A),
    Color(0x66B7F0C8),
    Color(0x66FFC2D4),
  ];

  @override
  void render(Canvas canvas) {
    if (size.x < 2 || size.y < 2) {
      return;
    }
    final laneWidth = size.x / 3;
    for (var i = 0; i < 3; i++) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(i * laneWidth + 8, 10, laneWidth - 16, size.y - 18),
        const Radius.circular(24),
      );
      canvas.drawRRect(rect, Paint()..color = _fills[i]);
      if (i == activeLane) {
        canvas.drawRRect(
          rect,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4
            ..color = const Color(0xFFFF8C42),
        );
      }
    }
  }
}
