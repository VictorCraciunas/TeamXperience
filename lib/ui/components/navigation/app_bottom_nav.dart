import 'package:flutter/material.dart';

import '../../theme/theme_context.dart';
import 'app_nav_item.dart';
import 'nav_button.dart';
import 'raised_nav_button.dart';

/// The bottom bar of the mockups (`.nav`): panel fill, a top border, up to
/// five tabs sitting on the bottom, and an optional raised round tab.
class AppBottomNav extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables -- the assert reads items.length, which is not const-evaluable
  AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onSelected,
    required this.items,
  }) : assert(items.length <= 5, 'AppBottomNav supports at most 5 items');

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
          // The mockup's 6 / 4 / 10, plus the 1 px top border drawn inside.
          padding: const EdgeInsets.fromLTRB(4, 7, 4, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    heightFactor: 1,
                    child: items[i].raised
                        ? RaisedNavButton(item: items[i], onTap: () => onSelected(i))
                        : NavButton(
                            item: items[i],
                            index: i,
                            active: i == currentIndex,
                            onTap: () => onSelected(i),
                          ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
