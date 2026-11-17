import 'package:flutter/material.dart';
import 'package:teamxperience/ui/theme/contrast.dart';
import 'package:teamxperience/ui/ui.dart';

import '../logic/chat_timeline.dart';
import 'bubble_position.dart';
import 'chat_message_row.dart';

/// A text message: mine in the accent colour on the right, the others on the
/// panel colour on the left.
class ChatTextBubble extends StatelessWidget {
  const ChatTextBubble({super.key, required this.entry});

  final ChatTextEntry entry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final mine = entry.mine;
    return ChatMessageRow(
      mine: mine,
      avatar: entry.avatar,
      name: entry.name,
      footer: entry.footer,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          color: mine ? colors.accent : colors.panel,
          border: mine ? null : Border.all(color: colors.insetBorder),
          borderRadius: bubbleRadius(mine, entry.position),
        ),
        child: Text(
          entry.text,
          style: AppTextStyles.body(context).copyWith(
            fontSize: 14,
            height: 1.45,
            color: mine ? readableOn([colors.accent]) : colors.text,
          ),
        ),
      ),
    );
  }
}
