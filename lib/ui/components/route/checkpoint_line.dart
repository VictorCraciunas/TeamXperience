import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../theme/theme_context.dart';
import 'trail_dot.dart';
import 'trail_segment.dart';

/// Steps on a line, on a navy card, as the team preparation of mockup 02:
/// 18 px circles (the first [done] filled with a check, the rest empty
/// rings), solid lines between done steps and dashed ones after, and the
/// [labels] below, the first at the left and the last at the right.
class CheckpointLine extends StatelessWidget {
  const CheckpointLine({super.key, required this.labels, required this.done});

  final List<String> labels;
  final int done;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final count = labels.length;
    final label = TextStyle(fontSize: 11, height: 1.45, color: colors.onNavy.withValues(alpha: .85));

    Widget dot(int i) => i < done
        ? TrailDot(
            size: 18,
            fill: colors.tickOnNavy,
            child: Icon(TablerIcons.check, size: 12, color: colors.onTick),
          )
        : TrailDot(
            key: ValueKey('checkpoint-open-$i'),
            size: 18,
            ring: colors.onNavy.withValues(alpha: .5),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            for (var i = 0; i < count; i++) ...[
              if (i > 0)
                Expanded(
                  child: i < done
                      ? TrailSegment(solid: true, color: colors.tickOnNavy)
                      : TrailSegment(solid: false, color: colors.onNavy.withValues(alpha: .4)),
                ),
              dot(i),
            ],
          ],
        ),
        const SizedBox(height: 3),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < count; i++)
              Flexible(
                child: Text(
                  labels[i],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: i == 0
                      ? TextAlign.start
                      : i == count - 1
                          ? TextAlign.end
                          : TextAlign.center,
                  style: label,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
