import 'package:flutter/material.dart';

import '../../theme/theme_context.dart';

/// A round icon button for the feed header. [active] shows a small dot (a
/// filter is applied).
class FeedIconButton extends StatelessWidget {
  const FeedIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: active ? colors.tick : colors.panel,
        shape: CircleBorder(side: BorderSide(color: colors.tick, width: 1.5)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon, color: active ? colors.onTick : colors.text, size: 22),
                if (active)
                  Positioned(
                    right: 11,
                    top: 11,
                    child: Container(
                      key: const ValueKey('feed-icon-active-dot'),
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: colors.live,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.tick, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
