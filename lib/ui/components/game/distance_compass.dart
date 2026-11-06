import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../theme/event_theme_scope.dart';
import '../../theme/theme_context.dart';

/// How far and which way a location puzzle's target is (mockup 07): a 46 px
/// accent circle whose arrow points at [bearing] (degrees from north), the
/// distance at 22, the walk line, and "mai aproape" / "mai departe".
class DistanceCompass extends StatelessWidget {
  const DistanceCompass({
    super.key,
    required this.distance,
    required this.line,
    required this.bearing,
    this.trend,
    this.closer = true,
  });

  final String distance;
  final String line;
  final double bearing;
  final String? trend;

  /// Whether [trend] is good news (success colour) or not (danger colour).
  final bool closer;

  @override
  Widget build(BuildContext context) {
    final palette = context.eventPalette;
    final word = trend;
    return DecoratedBox(
      key: const ValueKey('distance-compass'),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border.all(color: palette.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        // The mockup's 10 / 12, plus the 1 px border drawn inside.
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        child: Row(
          children: [
            DecoratedBox(
              key: const ValueKey('compass-arrow'),
              decoration: BoxDecoration(color: palette.accent, shape: BoxShape.circle),
              child: SizedBox.square(
                dimension: 46,
                child: Center(
                  child: Transform.rotate(
                    angle: bearing * math.pi / 180,
                    child: Icon(TablerIcons.arrow_up, size: 24, color: palette.onAccent),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(distance, style: TextStyle(fontSize: 22, height: 1.1, fontWeight: FontWeight.w500, color: palette.ink)),
                  Text(line, style: TextStyle(fontSize: 11, height: 1.45, color: palette.ink.withValues(alpha: .8))),
                ],
              ),
            ),
            if (word != null) ...[
              const SizedBox(width: 12),
              Text(
                word,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                  color: closer ? context.colors.success : context.colors.danger,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
