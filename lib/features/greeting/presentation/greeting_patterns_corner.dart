import 'package:flutter/material.dart';

/// Subtle corner patterns, anchored at top-right.
/// Keep opacity low from the caller (0.03–0.10 looks great).
enum CornerPattern { none, cornerDots, cornerChevrons }

class CornerPatternPainter extends CustomPainter {
  final CornerPattern style;
  final Color color; // low opacity suggested
  CornerPatternPainter({required this.style, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    switch (style) {
      case CornerPattern.cornerDots:
        _paintCornerDots(canvas, size);
        break;
      case CornerPattern.cornerChevrons:
        _paintCornerChevrons(canvas, size);
        break;
      case CornerPattern.none:
        break;
    }
  }

  // A radial falloff dot field anchored at top-right
  void _paintCornerDots(Canvas canvas, Size size) {
    final p = Paint()..color = color;
    final origin = Offset(size.width, 0); // top-right
    final maxR = size.shortestSide * 0.75;
    const gap = 12.0;

    for (double y = 0; y <= size.height * 0.75; y += gap) {
      for (double x = size.width * 0.25; x <= size.width; x += gap) {
        final pos = Offset(x, y);
        final d = (pos - origin).distance;
        if (d > maxR) continue;

        // Opacity + size fall off with distance
        final t = 1.0 - (d / maxR);
        final r = 1.2 + 1.0 * t; // 1.2..2.2 px
        final a = (p.color.a * (0.35 + 0.65 * t));
        canvas.drawCircle(pos, r, p..color = p.color.withValues(alpha: a));
      }
    }
  }

  // Tiny chevrons pointing towards the center from top-right triangle
  void _paintCornerChevrons(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final origin = Offset(size.width, 0);
    final maxR = size.shortestSide * 0.72;
    const step = 16.0;

    for (double y = 4; y <= size.height * 0.7; y += step) {
      for (double x = size.width * 0.3; x <= size.width; x += step) {
        final pos = Offset(x, y);
        final d = (pos - origin).distance;
        if (d > maxR) continue;

        final t = 1.0 - (d / maxR); // 0..1
        final w = 5 + 3 * t; // chevron size
        final h = 3 + 2 * t;

        final path = Path()
          ..moveTo(pos.dx - w / 2, pos.dy - h / 2)
          ..lineTo(pos.dx, pos.dy + h / 2)
          ..lineTo(pos.dx + w / 2, pos.dy - h / 2);
        final alpha = (color.a * (0.25 + 0.55 * t));
        canvas.drawPath(path, p..color = color.withValues(alpha: alpha));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CornerPatternPainter old) =>
      old.style != style || old.color != color;
}
