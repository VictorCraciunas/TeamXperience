import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A circle with a 2 px dashed outline and something in the middle (the
/// secret-missions lock).
class DashedCircle extends StatelessWidget {
  const DashedCircle({super.key, required this.size, required this.color, required this.child});

  final double size;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedCirclePainter(color),
      child: SizedBox(width: size, height: size, child: Center(child: child)),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  _DashedCirclePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2 - 1);
    const dashes = 10;
    const sweep = math.pi * 2 / dashes;
    for (var i = 0; i < dashes; i++) {
      canvas.drawArc(rect, i * sweep, sweep * 0.55, false, paint);
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter old) => old.color != color;
}
