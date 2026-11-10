import 'package:flutter/material.dart';

import '../../theme/theme_context.dart';
import 'outline_card.dart';

/// A small stat in a `.card`, as in mockup 02's greeting: a 14 px value over
/// an 11 px label, or over a 4 px progress bar.
class MiniStatCard extends StatelessWidget {
  const MiniStatCard({super.key, required this.value, this.label, this.progress, this.accent = false});

  final String value;
  final String? label;

  /// 0 to 1; shows a bar instead of the label.
  final double? progress;

  /// The value in the accent colour (the level).
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final share = progress;
    final caption = label;
    return OutlineCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.45,
              color: accent ? colors.accent : colors.text,
            ),
          ),
          if (share != null) ...[
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: SizedBox(
                key: const ValueKey('stat-track'),
                height: 4,
                child: ColoredBox(
                  color: colors.insetBorder,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      key: const ValueKey('stat-fill'),
                      widthFactor: share.clamp(0.0, 1.0),
                      heightFactor: 1,
                      child: ColoredBox(color: colors.tick),
                    ),
                  ),
                ),
              ),
            ),
          ] else if (caption != null)
            Text(
              caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, height: 1.45, color: colors.muted),
            ),
        ],
      ),
    );
  }
}
