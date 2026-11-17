import 'package:flutter/material.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';

import '../logic/chat_button_texts.dart';

/// The red count on the chat button, ringed in the page colour.
class ChatUnreadBadge extends StatelessWidget {
  const ChatUnreadBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // A badge grows with large text only so far, or it would hide the button.
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.5,
      child: Container(
        constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: colors.live,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: colors.page, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          chatBadgeText(count),
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1.2, color: colors.onNavy),
        ),
      ),
    );
  }
}
