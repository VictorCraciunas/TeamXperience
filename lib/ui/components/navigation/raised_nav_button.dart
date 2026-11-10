import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../theme/theme_context.dart';
import 'app_nav_item.dart';

/// The round tab in the middle of the bar: a 50 px circle in a 4 px page ring
/// (58 across), pulled 26 px up
/// (the mockup's margin-top: -26px), navy, or red while live.
///
/// When its pop-up opens ([AppNavItem.open]) the icon turns a quarter, like a
/// key in a lock, then becomes an X and the circle darkens (mockup 10).
class RaisedNavButton extends StatefulWidget {
  const RaisedNavButton({super.key, required this.item, required this.onTap});

  final AppNavItem item;
  final VoidCallback onTap;

  /// The circle's width and height: the mockup's 50 px box plus its 4 px
  /// border on each side (the mockup has no box-sizing reset).
  static const double size = 58;
  static const double _pull = 26;

  @override
  State<RaisedNavButton> createState() => _RaisedNavButtonState();
}

class _RaisedNavButtonState extends State<RaisedNavButton> with SingleTickerProviderStateMixin {
  late final AnimationController _turn = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    value: widget.item.open ? 1 : 0,
  )..addStatusListener((_) => setState(() {}));

  @override
  void didUpdateWidget(RaisedNavButton old) {
    super.didUpdateWidget(old);
    if (old.item.open == widget.item.open) return;
    if (!widget.item.open) {
      _turn.value = 0;
    } else if (MediaQuery.disableAnimationsOf(context)) {
      _turn.value = 1;
    } else {
      _turn.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _turn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final item = widget.item;
    final showX = item.open && _turn.isCompleted;
    final fill = item.live ? colors.live : (item.open ? colors.liveCard : colors.navy);
    final label = item.live ? colors.live : colors.navy;

    return Semantics(
      button: true,
      label: item.open ? 'Închide' : item.label,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Takes 32 px in the bar; the circle overflows 26 px above it.
            SizedBox(
              height: RaisedNavButton.size - RaisedNavButton._pull,
              width: 54,
              child: OverflowBox(
                alignment: Alignment.bottomCenter,
                minWidth: RaisedNavButton.size,
                maxWidth: RaisedNavButton.size,
                minHeight: RaisedNavButton.size,
                maxHeight: RaisedNavButton.size,
                child: Container(
                  key: const ValueKey('nav-raised-circle'),
                  width: RaisedNavButton.size,
                  height: RaisedNavButton.size,
                  decoration: BoxDecoration(
                    color: fill,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.page, width: 4),
                  ),
                  child: showX
                      ? Icon(TablerIcons.x, size: 22, color: colors.onNavy)
                      : AnimatedBuilder(
                          animation: _turn,
                          builder: (context, child) => Transform.rotate(
                            angle: Curves.easeOutBack.transform(_turn.value) * 1.5708,
                            child: child,
                          ),
                          child: Icon(item.icon, size: 22, color: colors.onNavy),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                item.label,
                maxLines: 1,
                style: TextStyle(color: label, fontSize: 12, height: 1.45, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
