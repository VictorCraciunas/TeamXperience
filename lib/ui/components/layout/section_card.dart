import 'package:flutter/material.dart';

import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/theme_context.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.count,
    this.countLabel,
    this.tickColor,
    this.actionLabel = 'Vezi toate',
    this.onAction,
  });

  final String title;
  final Widget child;
  final int? count;

  /// Text for the badge, used instead of [count] when given (for example `2 din 3`).
  final String? countLabel;
  final Color? tickColor;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final badgeText = countLabel ?? (count == null ? null : '$count');
    final action = onAction;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.panelPadding),
      decoration: BoxDecoration(
        color: colors.panel,
        borderRadius: BorderRadius.circular(AppRadius.panel),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 0, 2, 10),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: tickColor ?? colors.tick,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (badgeText != null) ...[
                  const SizedBox(width: 8),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.inset,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(color: colors.insetBorder),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          color: colors.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
                if (action != null) ...[
                  const Spacer(),
                  InkWell(
                    onTap: action,
                    child: Text(
                      '$actionLabel ›',
                      style: TextStyle(
                        color: colors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Lets ink-based widgets (ListTile, InkWell) paint on top of the panel.
          Material(type: MaterialType.transparency, child: child),
        ],
      ),
    );
  }
}
