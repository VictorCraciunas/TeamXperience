import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

/// A dashed outline around [child], as CSS `border: Npx dashed`: a rounded
/// rectangle ([radius]) or, with [circle], a circle. The outline is drawn
/// inside the box, so the child's own padding should include [width].
/// [fill] paints the inside of the shape.
class DashedBorder extends StatelessWidget {
  const DashedBorder({
    super.key,
    required this.color,
    this.width = 2,
    this.radius = 0,
    this.circle = false,
    this.fill,
    this.dash = 4,
    this.gap = 3,
    this.child,
  });

  final Color color;
  final double width;
  final double radius;
  final bool circle;
  final Color? fill;
  final double dash;
  final double gap;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final inside = fill;
    final content =
        inside == null
            ? child
            : DecoratedBox(
              decoration: BoxDecoration(
                color: inside,
                shape: circle ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: circle ? null : BorderRadius.circular(radius),
              ),
              child: child,
            );
    return CustomPaint(
      foregroundPainter: _DashedBorderPainter(
        color: color,
        width: width,
        radius: radius,
        circle: circle,
        dash: dash,
        gap: gap,
      ),
      child: content,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.color,
    required this.width,
    required this.radius,
    required this.circle,
    required this.dash,
    required this.gap,
  });

  final Color color;
  final double width;
  final double radius;
  final bool circle;
  final double dash;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(width / 2);
    final path = Path();
    if (circle) {
      path.addOval(rect);
    } else {
      final r = radius > width / 2 ? radius - width / 2 : 0.0;
      path.addRRect(RRect.fromRectAndRadius(rect, Radius.circular(r)));
    }

    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = width;
    for (final PathMetric metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = distance + dash < metric.length ? distance + dash : metric.length;
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color ||
      old.width != width ||
      old.radius != radius ||
      old.circle != circle ||
      old.dash != dash ||
      old.gap != gap;
}
