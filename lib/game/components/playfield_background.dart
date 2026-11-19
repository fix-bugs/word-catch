import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:material_ui/material_ui.dart';

/// 对局背景：天空、太阳、慢慢飘的云和草地。
///
/// 全部现场绘制，这样手机竖屏和电脑窗口换尺寸时不会被一张固定图拉变形。
class PlayfieldBackground extends PositionComponent {
  PlayfieldBackground() : super(priority: -20, anchor: Anchor.topLeft);

  final List<_Cloud> _clouds = const [
    _Cloud(0.16, 0.10, 0.24, 0.4),
    _Cloud(0.58, 0.18, 0.30, 1.2),
    _Cloud(0.82, 0.06, 0.18, 2.0),
  ];

  double _time = 0;

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
    final rect = Offset.zero & Size(size.x, size.y);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF8FD3F4), Color(0xFFD8F6FF), Color(0xFFFFF1CC)],
        ).createShader(rect),
    );

    final sunRadius = math.min(size.x, size.y) * 0.075;
    canvas.drawCircle(
      Offset(size.x * 0.84, size.y * 0.07),
      sunRadius,
      Paint()..color = const Color(0xFFFFE08A),
    );

    final blob = Paint()..color = const Color(0xF2FFFFFF);
    for (final cloud in _clouds) {
      final drift = math.sin(_time * 0.25 + cloud.phase) * 14;
      final cx = size.x * cloud.x + drift;
      final cy = size.y * cloud.y;
      final cw = size.x * cloud.w;
      final ch = cw * 0.42;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy), width: cw, height: ch),
        blob,
      );
      canvas.drawCircle(Offset(cx - cw * 0.22, cy + 2), ch * 0.55, blob);
      canvas.drawCircle(Offset(cx + cw * 0.2, cy + 3), ch * 0.4, blob);
    }

    final hill = Path()
      ..moveTo(0, size.y * 0.78)
      ..quadraticBezierTo(
        size.x * 0.28,
        size.y * 0.66,
        size.x * 0.55,
        size.y * 0.80,
      )
      ..quadraticBezierTo(size.x * 0.78, size.y * 0.92, size.x, size.y * 0.74)
      ..lineTo(size.x, size.y)
      ..lineTo(0, size.y)
      ..close();
    canvas.drawPath(hill, Paint()..color = const Color(0xFFB7E4C7));
  }
}

class _Cloud {
  const _Cloud(this.x, this.y, this.w, this.phase);

  final double x;
  final double y;
  final double w;
  final double phase;
}
