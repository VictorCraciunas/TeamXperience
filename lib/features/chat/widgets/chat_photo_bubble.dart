import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

import '../logic/chat_timeline.dart';
import 'bubble_position.dart';
import 'chat_message_row.dart';
import 'chat_picture.dart';
import 'photo_status_pill.dart';

/// A picture in a bubble, 230 px wide at most: a photo puzzle's with its
/// status pill and "Misiunea 3 · 10:53" (and the organiser's reason under a
/// rejected one), or a chat photo with its time.
class ChatPhotoBubble extends StatelessWidget {
  const ChatPhotoBubble({super.key, required this.entry});

  static const double maxWidth = 230;

  final ChatPhotoEntry entry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final status = entry.status;
    final reason = entry.reason;
    final small = TextStyle(fontSize: 12, color: colors.muted);
    return ChatMessageRow(
      mine: entry.mine,
      avatar: entry.avatar,
      name: entry.name,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxWidth),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: colors.panel,
            border: Border.all(color: colors.insetBorder),
            borderRadius: bubbleRadius(entry.mine, BubblePosition.single),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ChatPicture(url: entry.imageUrl, height: 130),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 2),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (status != null) PhotoStatusPill(status: status),
                    Text(entry.line, style: small),
                  ],
                ),
              ),
              if (reason != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 4, 2),
                  child: Text(reason, style: TextStyle(fontSize: 14, height: 1.4, color: colors.danger)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
