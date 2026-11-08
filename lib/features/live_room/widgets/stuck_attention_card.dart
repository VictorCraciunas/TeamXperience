import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/components/layout/outline_card.dart';
import 'package:teamxperience/ui/ui.dart';

import '../logic/attention_queue.dart';
import '../logic/live_texts.dart';
import 'queue_card_texts.dart';
import 'queue_round_button.dart';

/// A team that is stuck or keeps answering wrong: a tap opens the team, the
/// bubble opens its chat.
class StuckAttentionCard extends StatelessWidget {
  const StuckAttentionCard({super.key, required this.item, required this.onTeam, required this.onChat});

  final StuckAttention item;
  final VoidCallback onTeam;
  final VoidCallback onChat;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTeam,
      child: OutlineCard(
        borderColor: colors.amber,
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(color: colors.warningSoft, shape: BoxShape.circle),
              child: SizedBox.square(
                dimension: 30,
                child: Icon(TablerIcons.hourglass, size: 15, color: colors.warning),
              ),
            ),
            const SizedBox(width: 10),
            QueueCardTexts(title: stuckTitle(item), subtitle: stuckSubtitle(item)),
            QueueRoundButton(
              icon: TablerIcons.message_circle,
              label: 'Scrie echipei',
              ink: colors.accent,
              onTap: onChat,
            ),
          ],
        ),
      ),
    );
  }
}
