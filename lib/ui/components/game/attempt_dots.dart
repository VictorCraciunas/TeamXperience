import 'package:flutter/material.dart';

import '../../theme/event_theme_scope.dart';

/// "2 încercări rămase", "1 încercare rămasă", "20 de încercări rămase".
String attemptsLeftLabel(int left) {
  if (left == 1) return '1 încercare rămasă';
  final tail = left % 100;
  final de = left >= 20 && (tail == 0 || tail >= 20);
  return '$left ${de ? 'de ' : ''}încercări rămase';
}

/// How many answers a puzzle still takes (mockup 06): one 8 px dot per
/// attempt, filled in the accent while left and a 1.5 px accent ring once
/// used, 5 px apart, then the label. Past ten attempts only the label shows.
class AttemptDots extends StatelessWidget {
  const AttemptDots({super.key, required this.max, required this.left});

  static const int maxDots = 10;

  final int max;
  final int left;

  @override
  Widget build(BuildContext context) {
    final palette = context.eventPalette;
    final showDots = max <= maxDots;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showDots)
          for (var i = 0; i < max; i++) ...[
            if (i > 0) const SizedBox(width: 5),
            DecoratedBox(
              key: ValueKey('attempt-$i'),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < left ? palette.accent : null,
                border: i < left ? null : Border.all(color: palette.accent, width: 1.5),
              ),
              child: const SizedBox.square(dimension: 8),
            ),
          ],
        if (showDots && max > 0) const SizedBox(width: 9),
        Flexible(
          child: Text(
            attemptsLeftLabel(left),
            style: TextStyle(fontSize: 11, height: 1.45, color: palette.ink.withValues(alpha: .8)),
          ),
        ),
      ],
    );
  }
}
