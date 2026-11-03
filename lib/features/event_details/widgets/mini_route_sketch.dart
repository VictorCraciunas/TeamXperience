import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

/// The little dashed route at the top of the logistics card, drawn from the
/// mockup's curve and stretched to the card's width.
class MiniRouteSketch extends StatelessWidget {
  const MiniRouteSketch({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(color: colors.inset, border: Border(bottom: BorderSide(color: colors.insetBorder))),
      child: SizedBox(
        height: 58,
        width: double.infinity,
        child: CustomPaint(painter: _SketchPainter(line: colors.tick, start: colors.accent, end: colors.navy)),
      ),
    );
  }
}

class _SketchPainter extends CustomPainter {
  _SketchPainter({required this.line, required this.start, required this.end});

  final Color line;
  final Color start;
  final Color end;

  /// The width the mockup's path was drawn for.
  static const double _designWidth = 302;

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / _designWidth;
    Offset p(double x, double y) => Offset(x * sx, y);

    // M20 44 C 80 10, 140 50, 200 20 S 270 30, 282 14 (S mirrors the last control point: 260 -10).
    final path = Path()
      ..moveTo(p(20, 44).dx, 44)
      ..cubicTo(p(80, 10).dx, 10, p(140, 50).dx, 50, p(200, 20).dx, 20)
      ..cubicTo(p(260, -10).dx, -10, p(270, 30).dx, 30, p(282, 14).dx, 14);

    final paint = Paint()
      ..color = line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 9) {
        canvas.drawPath(metric.extractPath(d, d + 5), paint);
      }
    }
    canvas.drawCircle(p(20, 44), 5, Paint()..color = start);
    canvas.drawCircle(p(282, 14), 5, Paint()..color = end);
  }

  @override
  bool shouldRepaint(_SketchPainter old) => old.line != line || old.start != start || old.end != end;
}
