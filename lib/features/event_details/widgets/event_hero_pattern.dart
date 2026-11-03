import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Thin rings around a point at 70 % across and 40 % down, 19 px apart: the
/// hero of an event without a picture.
class EventHeroPattern extends CustomPainter {
  EventHeroPattern(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width * 0.7, size.height * 0.4);
    final reach = math.sqrt(size.width * size.width + size.height * size.height);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var r = 18.5; r < reach; r += 19) {
      canvas.drawCircle(centre, r, paint);
    }
  }

  @override
  bool shouldRepaint(EventHeroPattern old) => old.color != color;
}
