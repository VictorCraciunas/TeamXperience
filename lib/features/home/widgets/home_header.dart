import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/ui.dart';

/// The top of Home (mockup 02): the route mark, "TeamXperience", and the bell
/// that opens the player's notifications, with a red dot while one is unread
/// seen.
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, required this.unread, required this.onBell});

  final bool unread;
  final VoidCallback onBell;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.panel,
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          // The mockup's 12 / 14, plus the 1 px bottom border drawn inside.
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 9),
          child: Row(
            children: [
              Icon(TablerIcons.route, size: 22, color: colors.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'TeamXperience',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                    color: colors.text,
                  ),
                ),
              ),
              Semantics(
                button: true,
                label: unread ? 'Notificări noi' : 'Notificări',
                child: GestureDetector(
                  key: const ValueKey('bell'),
                  onTap: onBell,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.iconButtonBg,
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(TablerIcons.bell, size: 20, color: colors.text),
                        if (unread)
                          Positioned(
                            top: 10,
                            right: 11,
                            child: Container(
                              key: const ValueKey('bell-dot'),
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: colors.live,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
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
