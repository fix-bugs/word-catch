import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'palette.dart';

/// 首页和结算页背后的天空。对局画面自己在 Flame 里画。
class PlayfulBackground extends StatelessWidget {
  const PlayfulBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF9BE7FF), Color(0xFFFFF6E8), Color(0xFFFFE1C6)],
        ),
      ),
      child: child,
    );
  }
}

/// 首页和结算页上的小篮子脸，全部用矢量画，不依赖外部图片。
class MascotBadge extends StatelessWidget {
  const MascotBadge({this.size = 88, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: const _MascotPainter(),
    );
  }
}

class _MascotPainter extends CustomPainter {
  const _MascotPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.12, h * 0.28, w * 0.76, h * 0.62),
      Radius.circular(w * 0.22),
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
        ..strokeWidth = math.max(2, w * 0.035)
        ..color = const Color(0xFFFB8500),
    );
    final rim = Rect.fromCenter(
      center: Offset(w / 2, h * 0.32),
      width: w * 0.86,
      height: h * 0.22,
    );
    canvas.drawOval(rim, Paint()..color = const Color(0xFFFFE8A3));
    canvas.drawOval(
      rim,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(2, w * 0.03)
        ..color = const Color(0xFFFB8500),
    );
    final eye = Paint()..color = Palette.ink;
    canvas.drawCircle(Offset(w * 0.38, h * 0.58), w * 0.07, eye);
    canvas.drawCircle(Offset(w * 0.62, h * 0.58), w * 0.07, eye);
    final shine = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w * 0.40, h * 0.55), w * 0.025, shine);
    canvas.drawCircle(Offset(w * 0.64, h * 0.55), w * 0.025, shine);
    final smile = Path()
      ..moveTo(w * 0.40, h * 0.70)
      ..quadraticBezierTo(w * 0.50, h * 0.82, w * 0.60, h * 0.70);
    canvas.drawPath(
      smile,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(2, w * 0.035)
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF9A3412),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
