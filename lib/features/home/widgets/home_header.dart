import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/ui.dart';

/// The top of Home: "TeamXperience" as on the website (a yellow X), and the bell
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
              Expanded(
                // As on teamxperience.ro: Poppins bold, the X in the brand yellow.
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 1.45, color: colors.text),
                    children: [
                      const TextSpan(text: 'Team'),
                      TextSpan(text: 'X', style: TextStyle(color: colors.brandX)),
                      const TextSpan(text: 'perience'),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
