import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/theme/event_theme_scope.dart';

/// The missions still locked, as one stop (mockup 06), at 60 %: a 28 px
/// dashed ink ring with a 13 px lock, the label ("5 · 6") and the 16 px
/// finish flag, 6 px apart. On the right-hand side the row runs the other way.
class TrailLockedStop extends StatelessWidget {
  const TrailLockedStop({super.key, required this.label, this.mirrored = false});

  final String label;
  final bool mirrored;

  @override
  Widget build(BuildContext context) {
    final palette = context.eventPalette;
    final ring = SizedBox.square(
      key: const ValueKey('trail-locked'),
      dimension: 28,
      child: CustomPaint(
        painter: _DashedRing(palette.ink),
        child: Center(child: Icon(TablerIcons.lock, size: 13, color: palette.ink)),
      ),
    );
    final children = <Widget>[
      ring,
      const SizedBox(width: 6),
      Flexible(
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 11, height: 1.45, color: palette.ink),
        ),
      ),
      const SizedBox(width: 6),
      Icon(TablerIcons.flag, size: 16, color: palette.ink),
    ];
    return Opacity(
      opacity: .6,
      child: Row(mainAxisSize: MainAxisSize.min, children: mirrored ? children.reversed.toList() : children),
    );
  }
}

/// A 2 px dashed circle drawn inside its box.
class _DashedRing extends CustomPainter {
  _DashedRing(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 2.0;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    const dashes = 12;
    const sweep = 2 * math.pi / dashes;
    for (var i = 0; i < dashes; i++) {
      canvas.drawArc(rect, i * sweep, sweep * .55, false, paint);
    }
  }

  @override
  bool shouldRepaint(_DashedRing oldDelegate) => oldDelegate.color != color;
}
