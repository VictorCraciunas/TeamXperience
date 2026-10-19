import 'package:flutter/material.dart';

import '../../theme/theme_context.dart';
import 'app_nav_item.dart';

class AppBottomNav extends StatelessWidget {
  AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onSelected,
    required this.items,
  }) : assert(items.length <= 4, 'AppBottomNav supports at most 4 items');

  final int currentIndex;
  final ValueChanged<int> onSelected;
  final List<AppNavItem> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.panel,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _NavButton(
                    item: items[i],
                    index: i,
                    active: i == currentIndex,
                    onTap: () => onSelected(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
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
    final color = active ? colors.text : colors.muted;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                key: active ? ValueKey('nav-active-$index') : null,
                width: 52,
                height: 28,
                decoration: BoxDecoration(
                  color: active ? colors.navActivePill : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.icon, size: 20, color: color),
              ),
              if (item.showBadge)
                Positioned(
                  key: ValueKey('nav-badge-$index'),
                  right: 11,
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
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              item.label,
              maxLines: 1,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
