import 'dart:ui' show PathMetric;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../theme/theme_context.dart';

/// An event's main picture filling a fixed height, with room for small pills
/// on it. With no picture, or one that fails to load, a flat colour with a
/// dashed route line, so a card never looks broken.
class EventPicture extends StatelessWidget {
  const EventPicture({super.key, this.url, required this.height, this.fill, this.topLeft, this.topRight, this.bottomLeft});

  final String? url;
  final double height;

  /// Behind the picture; navy by default.
  final Color? fill;
  final Widget? topLeft;
  final Widget? topRight;
  final Widget? bottomLeft;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final link = url ?? '';
    final left = topLeft;
    final right = topRight;
    final bottom = bottomLeft;
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: fill ?? colors.navy,
            child: CustomPaint(painter: _RouteLine(colors.tickOnNavy)),
          ),
          if (link.isNotEmpty)
            CachedNetworkImage(
              imageUrl: link,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) => const SizedBox.shrink(),
            ),
          if (left != null || right != null)
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (left != null) Flexible(child: left),
                  if (left != null && right != null) const SizedBox(width: 8),
                  if (right != null) left == null ? Flexible(child: right) : right,
                ],
              ),
            ),
          if (bottom != null) Positioned(left: 6, bottom: 6, child: bottom),
        ],
      ),
    );
  }
}

/// A dashed line winding across the box, the app's route motif.
class _RouteLine extends CustomPainter {
  const _RouteLine(this.color);

  final Color color;

  static const double _dash = 6;
  static const double _gap = 6;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final route = Path()
      ..moveTo(w * .06, h * .88)
      ..cubicTo(w * .2, h * .5, w * .33, h * .82, w * .48, h * .53)
      ..cubicTo(w * .62, h * .25, w * .76, h * .35, w * .94, h * .18);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (final PathMetric metric in route.computeMetrics()) {
      var at = 0.0;
      while (at < metric.length) {
        canvas.drawPath(metric.extractPath(at, at + _dash), paint);
        at += _dash + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(_RouteLine oldDelegate) => oldDelegate.color != color;
}
