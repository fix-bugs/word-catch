import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:material_ui/material_ui.dart';

import '../../style/palette.dart';

/// 接单词的小篮子。
///
/// 锚点在底部中央，所以 [position] 是篮子踩在地面上的那一点。
/// 篮口大约在组件高度 36% 的地方，判定用的就是这条线。
class CatcherBasket extends PositionComponent {
  CatcherBasket() : super(priority: 10, anchor: Anchor.bottomCenter);

  /// 要滑向的横坐标。游戏只改这个值，篮子自己做平滑移动。
  double targetX = 0;

  /// 连击数，用来在头顶画小星星。由游戏在得分时写进来。
  int combo = 0;

  double _time = 0;

  /// 世界坐标里的篮口高度。卡片顶部越过这条线还没被接住，就算漏了。
  double get mouthY => position.y - size.y * 0.64;

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    final gap = targetX - position.x;
    position.x += gap * (1 - math.exp(-14 * dt));
  }

  @override
  void render(Canvas canvas) {
    if (size.x < 2 || size.y < 2) {
      return;
    }
    canvas.save();
    canvas.translate(0, math.sin(_time * 4) * 2);

    final w = size.x;
    final h = size.y;
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.08, h * 0.34, w * 0.84, h * 0.60),
      Radius.circular(w * 0.18),
    );
    canvas.drawRRect(
      body.shift(const Offset(0, 4)),
      Paint()..color = const Color(0x33000000),
    );
    canvas.drawRRect(body, Paint()..color = const Color(0xFFFFB703));
    canvas.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0xFFFB8500),
    );

    final rim = Rect.fromCenter(
      center: Offset(w / 2, h * 0.36),
      width: w * 0.92,
      height: h * 0.22,
    );
    canvas.drawOval(rim, Paint()..color = const Color(0xFFFFE08A));
    canvas.drawOval(
      rim,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0xFFFB8500),
    );

    final eyeY = h * 0.58;
    final eye = Paint()..color = Palette.ink;
    canvas.drawCircle(Offset(w * 0.38, eyeY), w * 0.065, eye);
    canvas.drawCircle(Offset(w * 0.62, eyeY), w * 0.065, eye);
    final shine = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w * 0.40, eyeY - 2), w * 0.022, shine);
    canvas.drawCircle(Offset(w * 0.64, eyeY - 2), w * 0.022, shine);

    final smile = Path()
      ..moveTo(w * 0.40, h * 0.72)
      ..quadraticBezierTo(w * 0.50, h * 0.84, w * 0.60, h * 0.72);
    canvas.drawPath(
      smile,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF9A3412),
    );
    final cheek = Paint()..color = const Color(0x55E85D4C);
    canvas.drawCircle(Offset(w * 0.28, h * 0.70), w * 0.045, cheek);
    canvas.drawCircle(Offset(w * 0.72, h * 0.70), w * 0.045, cheek);

    if (combo >= 2) {
      _star(canvas, Offset(w * 0.18, h * 0.16), w * 0.08);
      _star(canvas, Offset(w * 0.82, h * 0.12), w * 0.07);
      if (combo >= 4) {
        _star(canvas, Offset(w * 0.50, h * 0.04), w * 0.09);
      }
    }
    canvas.restore();
  }

  void _star(Canvas canvas, Offset center, double radius) {
    final path = Path();
    for (var i = 0; i < 5; i++) {
      final angle = -math.pi / 2 + i * 4 * math.pi / 5;
      final point = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFFF8C42));
  }
}
