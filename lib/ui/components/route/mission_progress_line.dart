import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../theme/theme_context.dart';
import 'trail_dot.dart';
import 'trail_segment.dart';

/// A live game's missions on a line, on a dark card, as in mockup 02: the
/// [done] missions as 14 px dots, the current one as a 22 px amber circle
/// with its number, the rest as rings, and the finish flag; the line is solid
/// up to the current mission and dashed after it.
class MissionProgressLine extends StatelessWidget {
  const MissionProgressLine({super.key, required this.total, required this.done});

  final int total;
  final int done;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final walked = done.clamp(0, total < 0 ? 0 : total);
    final hasCurrent = walked < total;
    final open = hasCurrent ? total - walked - 1 : 0;

    final stops = <Widget>[
      for (var i = 0; i < walked; i++)
        TrailDot(key: ValueKey('mission-done-$i'), size: 14, fill: colors.tickOnNavy),
      if (hasCurrent)
        TrailDot(
          key: const ValueKey('mission-current'),
          size: 22,
          fill: colors.soon,
          child: Text(
            '${walked + 1}',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.45, color: colors.onTick),
          ),
        ),
      for (var i = 0; i < open; i++)
        TrailDot(key: ValueKey('mission-open-$i'), size: 14, ring: colors.onNavy.withValues(alpha: .4)),
      Icon(TablerIcons.flag, size: 16, color: colors.onNavy.withValues(alpha: .6)),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 14, 2, 4),
      child: Row(
        children: [
          for (var i = 0; i < stops.length; i++) ...[
            if (i > 0)
              Expanded(
                // Solid while it leads to a done mission or the current one
                // (or, with every mission done, to the flag).
                child: i <= walked
                    ? TrailSegment(solid: true, color: colors.tickOnNavy)
                    : TrailSegment(solid: false, color: colors.onNavy.withValues(alpha: .35)),
              ),
            stops[i],
          ],
        ],
      ),
    );
  }
}
