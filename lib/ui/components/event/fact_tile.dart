import 'package:flutter/material.dart';

import '../../theme/app_radius.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/theme_context.dart';

/// One fact about an event: an icon (or any [leading] widget), a value and a
/// label below it ("2 h / durată").
class FactTile extends StatelessWidget {
  const FactTile({super.key, this.icon, this.leading, required this.value, required this.label});

  final IconData? icon;

  /// Shown instead of [icon] when set.
  final Widget? leading;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tileIcon = icon;
    // In the mockup the icon sits on a 15 x 1.45 line.
    final top = leading ??
        (tileIcon == null ? null : SizedBox(height: 15 * 1.45, child: Icon(tileIcon, size: 15, color: colors.accent)));

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.panel,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Padding(
        // The mockup's 6 plus the 1 px border, which Flutter draws inside.
        padding: const EdgeInsets.all(7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (top != null) top,
            Text(value, style: AppTextStyles.cardTitle(context), textAlign: TextAlign.center),
            Text(label, style: AppTextStyles.smallMuted(context), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
