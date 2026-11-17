import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

import '../logic/chat_timeline.dart';
import 'chat_entry_list.dart';

/// The chat page from plain values: the [header], the lines (a spinner
/// while they load) and the [composer], on the inset colour.
class ChatView extends StatelessWidget {
  const ChatView({
    super.key,
    required this.header,
    required this.composer,
    required this.entries,
    required this.loading,
    required this.emptyText,
    required this.onApprove,
    required this.onReject,
  });

  final Widget header;
  final Widget composer;
  final List<ChatEntry> entries;
  final bool loading;
  final String emptyText;
  final ValueChanged<ChatPhotoReviewEntry> onApprove;
  final ValueChanged<ChatPhotoReviewEntry> onReject;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ColoredBox(
      color: colors.inset,
      child: Column(
        children: [
          header,
          Expanded(
            child: loading
                ? Center(child: CircularProgressIndicator(color: colors.accent))
                : ChatEntryList(entries: entries, emptyText: emptyText, onApprove: onApprove, onReject: onReject),
          ),
          composer,
        ],
      ),
    );
  }
}
