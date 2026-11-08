import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/components/layout/outline_card.dart';
import 'package:teamxperience/ui/ui.dart';

import '../logic/attention_queue.dart';
import 'queue_card_texts.dart';
import 'queue_round_button.dart';

/// "Poză de aprobat": the picture, the team, and the decision right here.
class PhotoAttentionCard extends StatelessWidget {
  const PhotoAttentionCard({
    super.key,
    required this.item,
    this.busy = false,
    required this.onView,
    required this.onReject,
    required this.onApprove,
  });

  final PhotoAttention item;

  /// A decision is on its way: both buttons rest.
  final bool busy;
  final VoidCallback onView;
  final VoidCallback onReject;
  final VoidCallback onApprove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final url = item.url;
    final stand = ColoredBox(
      color: colors.inset,
      child: Center(child: Icon(TablerIcons.photo, size: 18, color: colors.muted)),
    );
    return OutlineCard(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          GestureDetector(
            onTap: url == null ? null : onView,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox.square(
                dimension: 44,
                child: url == null
                    ? stand
                    : Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => stand),
              ),
            ),
          ),
          const SizedBox(width: 10),
          QueueCardTexts(title: 'Poză de aprobat', subtitle: '${item.team.name} · misiunea ${item.mission}'),
          QueueRoundButton(
            icon: TablerIcons.x,
            label: 'Respinge poza',
            fill: colors.dangerSoft,
            ink: colors.danger,
            onTap: busy ? null : onReject,
          ),
          QueueRoundButton(
            icon: TablerIcons.check,
            label: 'Aprobă poza',
            fill: colors.successSoft,
            ink: colors.success,
            onTap: busy ? null : onApprove,
          ),
        ],
      ),
    );
  }
}
