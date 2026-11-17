import 'package:flutter/material.dart';
import 'package:teamxperience/ui/theme/app_radius.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';

import 'event_menu_badge.dart';

/// One of the big rows at the top of the event's ⋮ sheet: a tinted icon
/// tile, a title, a line under it and, when [badge] is above 0, a red count.
class EventMenuFeatureRow extends StatelessWidget {
  const EventMenuFeatureRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge = 0,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.button),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: colors.text, fontSize: 15, fontWeight: FontWeight.w500)),
                    Text(subtitle, style: TextStyle(color: colors.muted, fontSize: 12)),
                  ],
                ),
              ),
              if (badge > 0) ...[
                const SizedBox(width: 8),
                EventMenuBadge(count: badge),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
