import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

import '../logic/chat_timeline.dart';
import 'announcement_card.dart';
import 'chat_photo_bubble.dart';
import 'chat_text_bubble.dart';
import 'day_separator.dart';
import 'game_event_line.dart';
import 'photo_review_card.dart';

/// The chat's lines, newest at the bottom (where the list starts), 10 px
/// apart and 3 px within a run of one sender's texts. Dragging closes the
/// keyboard.
class ChatEntryList extends StatelessWidget {
  const ChatEntryList({
    super.key,
    required this.entries,
    required this.emptyText,
    required this.onApprove,
    required this.onReject,
  });

  /// Oldest first.
  final List<ChatEntry> entries;
  final String emptyText;
  final ValueChanged<ChatPhotoReviewEntry> onApprove;
  final ValueChanged<ChatPhotoReviewEntry> onReject;

  Widget _line(ChatEntry entry) => switch (entry) {
        ChatDayEntry() => DaySeparator(label: entry.label),
        ChatGameEventEntry() => GameEventLine(text: entry.text),
        ChatAnnouncementEntry() => AnnouncementCard(title: entry.title, text: entry.text),
        ChatTextEntry() => ChatTextBubble(entry: entry),
        ChatPhotoEntry() => ChatPhotoBubble(entry: entry),
        ChatPhotoReviewEntry() => PhotoReviewCard(
            entry: entry,
            onApprove: () => onApprove(entry),
            onReject: () => onReject(entry),
          ),
      };

  static double _gapAfter(ChatEntry entry) => entry is ChatTextEntry && entry.footer == null ? 3 : 10;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(emptyText, textAlign: TextAlign.center, style: AppTextStyles.bodyMuted(context)),
        ),
      );
    }
    return ListView.builder(
      reverse: true,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 2),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[entries.length - 1 - index];
        return Padding(
          key: ValueKey(entry.key),
          padding: EdgeInsets.only(bottom: index == 0 ? 0 : _gapAfter(entry)),
          child: _line(entry),
        );
      },
    );
  }
}
