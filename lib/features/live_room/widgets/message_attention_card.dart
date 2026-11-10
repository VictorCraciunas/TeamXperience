import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/components/layout/outline_card.dart';
import 'package:teamxperience/ui/ui.dart';

import '../logic/attention_queue.dart';
import 'queue_card_texts.dart';

/// "Mesaj nou de la Lupii": a tap opens the chat, which marks it read.
class MessageAttentionCard extends StatelessWidget {
  const MessageAttentionCard({super.key, required this.item, required this.onChat});

  final MessageAttention item;
  final VoidCallback onChat;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onChat,
      child: OutlineCard(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(color: colors.iconButtonBg, shape: BoxShape.circle),
              child: SizedBox.square(
                dimension: 30,
                child: Icon(TablerIcons.message_circle, size: 15, color: colors.accent),
              ),
            ),
            const SizedBox(width: 10),
            QueueCardTexts(title: 'Mesaj nou de la ${item.team.name}', subtitle: '„${item.text}”'),
          ],
        ),
      ),
    );
  }
}
