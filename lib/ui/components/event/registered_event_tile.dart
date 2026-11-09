import 'package:flutter/material.dart';

import '../../theme/app_radius.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/theme_context.dart';
import '../layout/outline_card.dart';

/// An event the player is in, as "Înscrierile tale" in mockup 03: a navy date
/// block, the event and its line, and a green badge.
class RegisteredEventTile extends StatelessWidget {
  const RegisteredEventTile({
    super.key,
    required this.day,
    required this.month,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.onTap,
  });

  final String day;
  final String month;
  final String title;
  final String subtitle;
  final String badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: OutlineCard(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Container(
              key: const ValueKey('date-block'),
              width: 46,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(color: colors.navy, borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  Text(day, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, height: 1.1, color: colors.onNavy)),
                  Text(month, style: TextStyle(fontSize: 13, height: 1.45, color: colors.onNavy)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.cardTitle(context)),
                  Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.smallMuted(context)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            DecoratedBox(
              decoration: BoxDecoration(color: colors.successSoft, borderRadius: BorderRadius.circular(AppRadius.pill)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Text(
                  badge,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.45, color: colors.success),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
