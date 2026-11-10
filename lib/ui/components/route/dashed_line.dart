import 'package:flutter/material.dart';

import '../../theme/theme_context.dart';

/// The dashed line of the route, filling its parent along [axis].
class DashedLine extends StatelessWidget {
  const DashedLine({
    super.key,
    this.axis = Axis.horizontal,
    this.color,
    this.thickness = 2,
    this.dash = 5,
    this.gap = 4,
  });

  final Axis axis;

  /// Defaults to the tick colour.
  final Color? color;
  final double thickness;
  final double dash;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final horizontal = axis == Axis.horizontal;
    return SizedBox(
      width: horizontal ? double.infinity : thickness,
      height: horizontal ? thickness : double.infinity,
      child: CustomPaint(
        painter: _DashPainter(
          axis: axis,
          color: color ?? context.colors.tick,
          thickness: thickness,
          dash: dash,
          gap: gap,
        ),
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  _DashPainter({
    required this.axis,
    required this.color,
    required this.thickness,
    required this.dash,
    required this.gap,
  });

  final Axis axis;
  final Color color;
  final double thickness;
  final double dash;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final length = axis == Axis.horizontal ? size.width : size.height;
    for (var start = 0.0; start < length; start += dash + gap) {
      final end = (start + dash).clamp(0.0, length);
      final rect = axis == Axis.horizontal
          ? Rect.fromLTWH(start, 0, end - start, thickness)
          : Rect.fromLTWH(0, start, thickness, end - start);
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) =>
      old.axis != axis || old.color != color || old.thickness != thickness || old.dash != dash || old.gap != gap;
}
