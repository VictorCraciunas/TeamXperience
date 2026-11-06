import 'package:flutter/material.dart';

import '../../theme/event_theme_scope.dart';

/// One bar per mission (mockup 06 `.seg`): the done ones in the accent, the
/// current one in the second accent, the rest in the ink at 18 %. 5 px high,
/// 3 px apart, sharing the width.
class MissionSegments extends StatelessWidget {
  const MissionSegments({super.key, required this.total, required this.done});

  final int total;

  /// Missions solved; the next one, if any, is the current one.
  final int done;

  @override
  Widget build(BuildContext context) {
    final palette = context.eventPalette;
    Color colour(int i) {
      if (i < done) return palette.accent;
      if (i == done) return palette.secondaryAccent;
      return palette.ink.withValues(alpha: .18);
    }

    return Row(
      children: [
        for (var i = 0; i < total; i++) ...[
          if (i > 0) const SizedBox(width: 3),
          Expanded(
            child: DecoratedBox(
              key: ValueKey('segment-$i'),
              decoration: BoxDecoration(color: colour(i), borderRadius: BorderRadius.circular(99)),
              child: const SizedBox(height: 5),
            ),
          ),
        ],
      ],
    );
  }
}
