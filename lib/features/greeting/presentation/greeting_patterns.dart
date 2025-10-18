import 'package:flutter/material.dart';

enum PatternStyle { none, stripes, dots, grid }

class SubtlePatternPainter extends CustomPainter {
  final PatternStyle style;
  final Color color; // use low opacity from caller
  const SubtlePatternPainter({required this.style, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    switch (style) {
      case PatternStyle.stripes:
        _paintStripes(canvas, size);
        break;
      case PatternStyle.dots:
        _paintDots(canvas, size);
        break;
      case PatternStyle.grid:
        _paintGrid(canvas, size);
        break;
      case PatternStyle.none:
        break;
    }
  }

  void _paintStripes(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 2;
    const spacing = 12.0;
    canvas.save();
    canvas.translate(size.width, 0);
    canvas.rotate(0.35); // ~20°
    for (double y = -size.height; y < size.height * 2; y += spacing) {
      canvas.drawLine(
          Offset(-size.width * 1.5, y), Offset(size.width * 1.5, y), p);
    }
    canvas.restore();
  }

  void _paintDots(Canvas canvas, Size size) {
    final p = Paint()..color = color;
    const gap = 10.0;
    for (double y = gap; y < size.height; y += gap) {
      for (double x = gap; x < size.width; x += gap) {
        canvas.drawCircle(Offset(x, y), 1.2, p);
      }
    }
  }

  void _paintGrid(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1;
    const gap = 14.0;
    for (double x = 0; x <= size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y <= size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant SubtlePatternPainter oldDelegate) =>
      oldDelegate.style != style || oldDelegate.color != color;
}
