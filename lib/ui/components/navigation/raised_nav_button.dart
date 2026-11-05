import 'package:flutter/material.dart';

import '../../theme/theme_context.dart';
import 'app_nav_item.dart';

/// The round tab in the middle of the bar: a 50 px circle pulled 26 px up out
/// of the bar (as the mockup's margin-top: -26px), navy, or red while live.
class RaisedNavButton extends StatelessWidget {
  const RaisedNavButton({super.key, required this.item, required this.onTap});

  final AppNavItem item;
  final VoidCallback onTap;

  static const double _size = 50;
  static const double _pull = 26;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fill = item.live ? colors.live : colors.navy;

    return Semantics(
      button: true,
      label: item.label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // As tall as a plain tab's icon line (29), so the circle's middle
            // stays inside the bar where taps land.
            const SizedBox(height: 20 * 1.45 - (_size - _pull)),
            // Takes 24 px in the bar; the circle overflows 26 px above it.
            SizedBox(
              height: _size - _pull,
              width: 54,
              child: OverflowBox(
                alignment: Alignment.bottomCenter,
                minWidth: _size,
                maxWidth: _size,
                minHeight: _size,
                maxHeight: _size,
                child: Container(
                  key: const ValueKey('nav-raised-circle'),
                  width: _size,
                  height: _size,
                  decoration: BoxDecoration(
                    color: fill,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.page, width: 4),
                  ),
                  child: Icon(item.icon, size: 22, color: colors.onNavy),
                ),
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                item.label,
                maxLines: 1,
                style: TextStyle(color: fill, fontSize: 11, height: 1.45, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
