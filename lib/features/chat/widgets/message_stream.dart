import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/enums/message_type.dart';
import 'package:teamxperience/enums/photo_approval_status.dart';
import 'package:teamxperience/enums/role.dart';
import 'package:teamxperience/features/chat/controller/chat_controller.dart';
import 'package:teamxperience/features/chat/widgets/bubble_position.dart';
import 'package:teamxperience/features/chat/widgets/day_separator.dart';
import 'package:teamxperience/features/chat/widgets/image_message_bubble.dart';
import 'package:teamxperience/features/chat/widgets/message_bubble.dart';

import '../../../model/team.dart';
import '../../../state_management/user_provider.dart';

const _months = [
  'ian', 'feb', 'mar', 'apr', 'mai', 'iun',
  'iul', 'aug', 'sep', 'oct', 'nov', 'dec',
];

String _dayLabel(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final msgDay = DateTime(date.year, date.month, date.day);
  final diff = today.difference(msgDay).inDays;
  if (diff == 0) return 'Astăzi';
  if (diff == 1) return 'Ieri';
  return '${date.day} ${_months[date.month - 1]} ${date.year}';
}

String _timeLabel(DateTime date) {
  return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

class MessagesStream extends StatelessWidget {
  final ChatController controller;

  const MessagesStream({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Team>(
      stream: controller.getTeamStream(),
      builder: (context, teamSnapshot) {
        final team = teamSnapshot.data;

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: controller.getMessages(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: context.colors.accent,
                  ),
                ),
              );
            }

            final docs = snapshot.data!.docs;
            final user =
                Provider.of<UserProvider>(context, listen: false).currentUser!;
            final isAdmin = user.role == Role.ADMIN;

            // Build chronological list of parsed messages
            final parsed = <_ParsedMsg>[];
            for (final doc in docs) {
              final data = doc.data();
              final senderRaw = data['sender'] as String? ?? Role.USER.name;
              final sender = Role.values.byName(senderRaw);
              final typeRaw = data['type'] as String?;
              final type = typeRaw != null
                  ? MessageType.values.byName(typeRaw)
                  : MessageType.text;
              final ts = data['timestamp'] as Timestamp?;
              final dateTime = ts?.toDate() ?? DateTime.now();

              parsed.add(_ParsedMsg(
                docId: doc.id,
                sender: sender,
                isMe: user.role == sender,
                type: type,
                text: data['text'] as String? ?? '',
                imageUrl: data['imageUrl'] as String?,
                approvalKey: data['approvalKey'] as String?,
                dateTime: dateTime,
                dayLabel: _dayLabel(dateTime),
                timeLabel: _timeLabel(dateTime),
              ));
            }

            // Compute grouping positions (chronological order)
            for (var i = 0; i < parsed.length; i++) {
              final m = parsed[i];
              final prev = i > 0 ? parsed[i - 1] : null;
              final next = i < parsed.length - 1 ? parsed[i + 1] : null;
              final samePrev = prev != null &&
                  prev.sender == m.sender &&
                  prev.dayLabel == m.dayLabel;
              final sameNext = next != null &&
                  next.sender == m.sender &&
                  next.dayLabel == m.dayLabel;

              if (samePrev && sameNext) {
                m.position = BubblePosition.middle;
              } else if (sameNext) {
                m.position = BubblePosition.first;
              } else if (samePrev) {
                m.position = BubblePosition.last;
              } else {
                m.position = BubblePosition.single;
              }
              m.showTime = !sameNext;
            }

            // Build widget list with day separators (chronological)
            final widgets = <Widget>[];
            String? lastDay;
            for (final m in parsed) {
              if (m.dayLabel != lastDay) {
                widgets.add(DaySeparator(
                  key: ValueKey('day-${m.dayLabel}'),
                  label: m.dayLabel,
                ));
                lastDay = m.dayLabel;
              }

              if (m.type == MessageType.image) {
                PhotoApprovalStatus? status;
                if (m.approvalKey != null && team != null) {
                  status = team.photoApprovals[m.approvalKey];
                }

                final isPending = status == PhotoApprovalStatus.pending;
                final canApprove = isAdmin && isPending && team != null;

                widgets.add(ImageMessageBubble(
                  key: ValueKey(m.docId),
                  imageUrl: m.imageUrl ?? '',
                  isMe: m.isMe,
                  position: m.position,
                  time: m.timeLabel,
                  showTime: m.showTime,
                  showApprovalActions: canApprove,
                  status: status,
                  onApprove:
                      canApprove ? () => controller.approvePhoto(team, m.approvalKey!) : null,
                  onDeny:
                      canApprove ? () => controller.denyPhoto(team, m.approvalKey!) : null,
                ));
              } else {
                widgets.add(MessageBubble(
                  key: ValueKey(m.docId),
                  text: m.text,
                  isMe: m.isMe,
                  position: m.position,
                  time: m.timeLabel,
                  showTime: m.showTime,
                ));
              }
            }

            // Reverse for the reverse ListView (newest at bottom)
            final reversed = widgets.reversed.toList();

            return Expanded(
              child: ListView(
                reverse: true,
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 10),
                children: reversed,
              ),
            );
          },
        );
      },
    );
  }
}

class _ParsedMsg {
  final String docId;
  final Role sender;
  final bool isMe;
  final MessageType type;
  final String text;
  final String? imageUrl;
  final String? approvalKey;
  final DateTime dateTime;
  final String dayLabel;
  final String timeLabel;
  BubblePosition position = BubblePosition.single;
  bool showTime = true;

  _ParsedMsg({
    required this.docId,
    required this.sender,
    required this.isMe,
    required this.type,
    required this.text,
    required this.imageUrl,
    required this.approvalKey,
    required this.dateTime,
    required this.dayLabel,
    required this.timeLabel,
  });
}
