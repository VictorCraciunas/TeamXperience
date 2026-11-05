import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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

  /// How far the raised circle sticks out above the bar, as the mockup's CSS
  /// lays it out: 1 + 6 + (33 - 24) - 26.
  static const double raisedRise = 10;

  static const double _side = 4;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // As tall as a tab whose icon sits in the active pill (2 + 29 + 2, then
    // 2 + the label), so the bar keeps its height when the raised tab is the
    // current one.
    final rowHeight = 33 + 2 + MediaQuery.textScalerOf(context).scale(11) * 1.45;

    final bar = DecoratedBox(
      decoration: BoxDecoration(
        color: colors.panel,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          // The mockup's 6 / 4 / 10, plus the 1 px top border drawn inside.
          padding: const EdgeInsets.fromLTRB(_side, 7, _side, 10),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: rowHeight),
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
      ),
    );

    final raised = items.indexWhere((item) => item.raised);
    if (raised < 0) return bar;

    // The whole column under the raised circle takes its taps, and taps on
    // the part of the circle above the bar are brought down into it.
    return _RaisedHitArea(
      index: raised,
      count: items.length,
      side: _side,
      rise: raisedRise,
      radius: RaisedNavButton.size / 2,
      child: Stack(
        children: [
          bar,
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: _side),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      child: i == raised
                          ? GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              excludeFromSemantics: true,
                              onTap: () => onSelected(i),
                            )
                          : const SizedBox(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lets a tap on the raised circle above the bar's top edge reach the bar,
/// which Flutter would otherwise send to the page behind.
class _RaisedHitArea extends SingleChildRenderObjectWidget {
  const _RaisedHitArea({
    required this.index,
    required this.count,
    required this.side,
    required this.rise,
    required this.radius,
    required super.child,
  });

  final int index;
  final int count;
  final double side;
  final double rise;
  final double radius;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderRaisedHitArea(index: index, count: count, side: side, rise: rise, radius: radius);

  @override
  void updateRenderObject(BuildContext context, _RenderRaisedHitArea renderObject) {
    renderObject
      ..index = index
      ..count = count
      ..side = side
      ..rise = rise
      ..radius = radius;
  }
}

class _RenderRaisedHitArea extends RenderProxyBox {
  _RenderRaisedHitArea({
    required this.index,
    required this.count,
    required this.side,
    required this.rise,
    required this.radius,
  });

  int index;
  int count;
  double side;
  double rise;
  double radius;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (position.dy < 0) {
      final cell = (size.width - 2 * side) / count;
      final centre = Offset(side + cell * (index + 0.5), radius - rise);
      if (position.dy < -rise || (position - centre).distance > radius) return false;
      return super.hitTest(result, position: Offset(position.dx, 0));
    }
    return super.hitTest(result, position: position);
  }
}
