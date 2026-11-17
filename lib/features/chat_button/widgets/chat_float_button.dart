import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';

import '../logic/chat_button_texts.dart';
import 'chat_unread_badge.dart';

/// The round teal chat button with the unread count.
class ChatFloatButton extends StatelessWidget {
  const ChatFloatButton({super.key, required this.count, required this.onTap});

  static const double size = 56;

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      label: chatButtonLabel(count),
      excludeSemantics: true,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: colors.accent.withValues(alpha: .35), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: Material(
                  color: colors.accent,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    key: const ValueKey('chat-float-button'),
                    onTap: onTap,
                    // The panel colour is white in the light theme and dark
                    // on the dark theme's light teal.
                    child: Icon(TablerIcons.message_circle, size: 26, color: colors.panel),
                  ),
                ),
              ),
            ),
            Positioned(top: -2, right: -2, child: ChatUnreadBadge(count: count)),
          ],
        ),
      ),
    );
  }
}
