import 'package:flutter/material.dart';

import '../../theme/app_radius.dart';
import '../../theme/theme_context.dart';

enum StatusPillKind { live, soon, info }

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    this.kind = StatusPillKind.info,
    this.icon,
  });

  final String label;
  final StatusPillKind kind;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final Color background;
    final Color foreground;
    switch (kind) {
      case StatusPillKind.live:
        background = colors.live;
        foreground = Colors.white;
      case StatusPillKind.soon:
        background = colors.soon;
        foreground = const Color(0xFF0C092A);
      case StatusPillKind.info:
        background = colors.tick;
        foreground = Colors.white;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: foreground),
              const SizedBox(width: 5),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: foreground,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
