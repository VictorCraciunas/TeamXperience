import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/features/profile/logic/badge_catalog.dart';
import 'package:teamxperience/ui/components/misc/dashed_border.dart';
import 'package:teamxperience/ui/ui.dart';

/// A badge (mockup 08 `.bd`): a 44 px circle over its 11 px title, 3 apart.
/// Earned: its icon in teal or gold. Locked: a dashed ring with a lock, at 45 %.
class BadgeTile extends StatelessWidget {
  const BadgeTile({super.key, required this.badge, required this.earned, this.onTap});

  final ProfileBadge badge;
  final bool earned;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final Widget circle;
    if (earned) {
      circle = DecoratedBox(
        key: ValueKey('badge-${badge.id}'),
        decoration: BoxDecoration(
          color: badge.gold ? colors.warningSoft : colors.iconButtonBg,
          shape: BoxShape.circle,
        ),
        child: SizedBox.square(
          dimension: 44,
          child: Center(child: Icon(badge.icon, size: 22, color: badge.gold ? colors.warning : colors.accent)),
        ),
      );
    } else {
      circle = SizedBox.square(
        key: ValueKey('badge-${badge.id}'),
        dimension: 44,
        child: DashedBorder(
          color: colors.muted,
          circle: true,
          child: Center(child: Icon(TablerIcons.lock, size: 18, color: colors.muted)),
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Opacity(
        opacity: earned ? 1 : .45,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            circle,
            const SizedBox(height: 3),
            Text(
              badge.title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, height: 1.45, color: colors.text),
            ),
          ],
        ),
      ),
    );
  }
}
