import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/ui.dart';

import '../logic/chat_row.dart';
import '../logic/chat_texts.dart';
import 'chat_count_badge.dart';
import 'team_initial_avatar.dart';

/// One team's conversation: its letter, name, when the chat last moved and
/// the last message (or the photo waiting). A chat with something to read is
/// tinted, outlined in teal, in bold and carries the red count. The whole row
/// opens the chat.
class ChatRowTile extends StatelessWidget {
  const ChatRowTile({super.key, required this.row, required this.now, required this.onTap});

  final ChatRow row;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final unread = row.isUnread;
    final preview = chatPreview(row);
    final time = chatTime(row.time, now);
    final previewColor = preview.photo ? colors.warning : (unread ? colors.text : colors.muted);
    final previewStyle = TextStyle(
      fontSize: 14,
      height: 1.4,
      fontWeight: unread ? FontWeight.w500 : FontWeight.w400,
      color: previewColor,
    );

    final name = Text(
      row.team.name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 15,
        height: 1.4,
        fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
        color: colors.text,
      ),
    );
    final timeText = Text(
      time,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 12,
        height: 1.4,
        fontWeight: unread ? FontWeight.w600 : FontWeight.w400,
        color: unread ? colors.accent : colors.muted,
      ),
    );
    // With large text the time goes under the name, so the name keeps room.
    final stacked = MediaQuery.textScalerOf(context).scale(1) > 1.3;

    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 68),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: unread ? colors.navActivePill : colors.panel,
            border: Border.all(color: unread ? colors.tick : colors.border),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Row(
            children: [
              TeamInitialAvatar(name: row.team.name, highlighted: unread),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (stacked) ...[name, if (time.isNotEmpty) timeText] else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Expanded(child: name),
                          if (time.isNotEmpty) ...[const SizedBox(width: 6), timeText],
                        ],
                      ),
                    if (preview.text.isNotEmpty)
                      Row(
                        children: [
                          if (preview.photo) ...[
                            Icon(TablerIcons.photo, size: 16, color: previewColor),
                            const SizedBox(width: 6),
                          ],
                          Expanded(
                            child: Text(
                              preview.text,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: previewStyle,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              if (unread) ...[
                const SizedBox(width: 12),
                MediaQuery.withClampedTextScaling(
                  maxScaleFactor: 1.3,
                  child: ChatCountBadge(count: row.badge),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
