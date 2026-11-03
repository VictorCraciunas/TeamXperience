import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../theme/app_text_styles.dart';
import '../../theme/theme_context.dart';
import '../misc/app_chip.dart';
import '../misc/app_chip_style.dart';
import 'dashed_line.dart';

/// The route at a glance: start pin, dashed line with the length on it,
/// finish flag, an optional map link, and the start and end names below.
class RouteStrip extends StatelessWidget {
  const RouteStrip({
    super.key,
    required this.centerLabel,
    required this.startLabel,
    required this.endLabel,
    this.mapLabel,
    this.onMapTap,
  });

  final String centerLabel;
  final String startLabel;
  final String endLabel;

  /// The map chip shows only when both [mapLabel] and [onMapTap] are set.
  final String? mapLabel;
  final VoidCallback? onMapTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final label = mapLabel;
    final tap = onMapTap;
    final small = AppTextStyles.smallMuted(context);

    return DecoratedBox(
      decoration: BoxDecoration(color: colors.panel, border: Border(bottom: BorderSide(color: colors.border))),
      child: Padding(
        // 1 more at the bottom for the border, which Flutter draws inside.
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // The mockup's icons sit on a 16 x 1.45 line.
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 16 * 1.45),
              child: Row(
                children: [
                  Icon(TablerIcons.map_pin, size: 16, color: colors.accent),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const DashedLine(),
                        ColoredBox(
                          color: colors.panel,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              centerLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: small.copyWith(color: colors.text),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(TablerIcons.flag, size: 16, color: colors.navy),
                  if (label != null && tap != null) ...[
                    const SizedBox(width: 6),
                    AppChip(label: label, icon: TablerIcons.map, style: AppChipStyle.outlined, onTap: tap),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(child: Text(startLabel, style: small, maxLines: 1, overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    endLabel,
                    style: small,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
