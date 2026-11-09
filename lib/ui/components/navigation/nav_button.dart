import 'package:flutter/material.dart';

import '../../theme/theme_context.dart';
import 'app_nav_item.dart';

/// One plain tab of the bottom bar: a 20 px icon over an 11 px label, accent
/// when active.
class NavButton extends StatelessWidget {
  const NavButton({
    super.key,
    required this.item,
    required this.index,
    required this.active,
    required this.onTap,
  });

  final AppNavItem item;
  final int index;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = active ? colors.accent : colors.muted;

    return InkResponse(
      onTap: onTap,
      radius: 30,
      child: SizedBox(
        width: 54,
        child: Column(
          key: active ? ValueKey('nav-active-$index') : null,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              key: active ? const ValueKey('nav-pill') : null,
              // The mockup's `.on i`: the icon padded 2 px / 14 px in a pill.
              padding: active ? const EdgeInsets.symmetric(horizontal: 14, vertical: 2) : null,
              decoration: active
                  ? BoxDecoration(color: colors.navActivePill, borderRadius: BorderRadius.circular(99))
                  : null,
              child: SizedBox(
              width: 20,
              height: 20 * 1.45,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Icon(item.icon, size: 20, color: color),
                  if (item.showBadge)
                    Positioned(
                      key: ValueKey('nav-badge-$index'),
                      right: 13,
                      top: 3,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: colors.live,
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.panel, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                item.label,
                maxLines: 1,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  height: 1.45,
                  fontWeight: active ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
