import 'package:flutter/material.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/ui/components/misc/section_header.dart';
import 'package:teamxperience/ui/ui.dart';

import '../logic/attention_queue.dart';
import 'message_attention_card.dart';
import 'photo_attention_card.dart';
import 'stuck_attention_card.dart';

/// "Necesită atenție": the queue, with its count in a red pill.
class AttentionSection extends StatelessWidget {
  const AttentionSection({
    super.key,
    required this.items,
    required this.isDeciding,
    required this.onViewPhoto,
    required this.onReject,
    required this.onApprove,
    required this.onTeam,
    required this.onChat,
  });

  final List<AttentionItem> items;
  final bool Function(PhotoAttention item) isDeciding;
  final ValueChanged<PhotoAttention> onViewPhoto;
  final ValueChanged<PhotoAttention> onReject;
  final ValueChanged<PhotoAttention> onApprove;
  final ValueChanged<Team> onTeam;
  final ValueChanged<Team> onChat;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'Necesită atenție',
          top: 12,
          trailingChild: items.isEmpty
              ? null
              : DecoratedBox(
                  decoration: BoxDecoration(color: colors.live, borderRadius: BorderRadius.circular(99)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '${items.length}',
                      style: TextStyle(fontSize: 13, height: 1.45, fontWeight: FontWeight.w500, color: colors.onNavy),
                    ),
                  ),
                ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          child: items.isEmpty
              ? Text('Nimic de rezolvat acum.', style: TextStyle(fontSize: 14, height: 1.45, color: colors.muted))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      if (i > 0) const SizedBox(height: 6),
                      _card(items[i]),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Widget _card(AttentionItem item) => switch (item) {
        PhotoAttention() => PhotoAttentionCard(
            item: item,
            busy: isDeciding(item),
            onView: () => onViewPhoto(item),
            onReject: () => onReject(item),
            onApprove: () => onApprove(item),
          ),
        StuckAttention() => StuckAttentionCard(
            item: item,
            onTeam: () => onTeam(item.team),
            onChat: () => onChat(item.team),
          ),
        MessageAttention() => MessageAttentionCard(item: item, onChat: () => onChat(item.team)),
      };
}
