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
    final top = leading ?? (tileIcon == null ? null : Icon(tileIcon, size: 15, color: colors.accent));

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.panel,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
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
