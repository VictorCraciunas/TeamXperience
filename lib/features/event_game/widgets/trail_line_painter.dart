import 'package:flutter/material.dart';
import 'package:teamxperience/features/event_game/logic/trail_layout.dart';

/// The route line (mockup 06): 3 px in the accent, solid up to the stop at
/// [solidUpTo], then dashed 7 / 6 at 75 %.
class TrailLinePainter extends CustomPainter {
  TrailLinePainter({required this.points, required this.solidUpTo, required this.color});

  final List<Offset> points;
  final int solidUpTo;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final path = trailPath(points);
    final solidLength = trailLengthTo(points, solidUpTo);
    final solid = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final dashed = Paint()
      ..color = color.withValues(alpha: color.a * .75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    for (final metric in path.computeMetrics()) {
      final end = solidLength.clamp(0.0, metric.length);
      if (end > 0) canvas.drawPath(metric.extractPath(0, end), solid);
      for (var start = end; start < metric.length; start += 13) {
        canvas.drawPath(metric.extractPath(start, (start + 7).clamp(0.0, metric.length)), dashed);
      }
    }
  }

  @override
  bool shouldRepaint(TrailLinePainter oldDelegate) =>
      oldDelegate.solidUpTo != solidUpTo || oldDelegate.color != color || !_same(oldDelegate.points, points);

  static bool _same(List<Offset> a, List<Offset> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
