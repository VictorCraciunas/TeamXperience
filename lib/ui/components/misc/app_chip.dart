import 'package:flutter/material.dart';

import '../../theme/app_radius.dart';
import '../../theme/theme_context.dart';
import 'app_chip_style.dart';

/// A small pill with a label and an optional icon, as in the mockups: puzzle
/// kinds, filters and the map link.
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.icon,
    this.style = AppChipStyle.plain,
    this.onTap,
  });

  final String label;
  final IconData? icon;
  final AppChipStyle style;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (fill, outline, labelColor, iconColor) = switch (style) {
      AppChipStyle.plain => (colors.panel, colors.border, colors.text, colors.accent),
      AppChipStyle.outlined => (colors.panel, colors.tick, colors.accent, colors.accent),
      AppChipStyle.selected => (colors.navy, colors.navy, colors.onNavy, colors.onNavy),
    };
    final chipIcon = icon;

    final chip = DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        border: Border.all(color: outline),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        // Borders are drawn inside the box, so 1 more than the mockup's 3 / 9.
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (chipIcon != null) ...[
              Icon(chipIcon, size: 13, color: iconColor),
              const SizedBox(width: 4),
            ],
            Text(label, style: TextStyle(fontSize: 11, color: labelColor, height: 1.45)),
          ],
        ),
      ),
    );

    final tap = onTap;
    if (tap == null) return chip;
    return GestureDetector(
      onTap: tap,
      behavior: HitTestBehavior.opaque,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 32),
        child: Align(widthFactor: 1, heightFactor: 1, child: chip),
      ),
    );
  }
}
