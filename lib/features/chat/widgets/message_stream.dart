import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/enums/message_type.dart';
import 'package:teamxperience/enums/role.dart';
import 'package:teamxperience/features/chat/controller/chat_controller.dart';
import 'package:teamxperience/features/chat/widgets/image_message_bubble.dart';
import 'package:teamxperience/model/team.dart';

import '../../../state_management/user_provider.dart';
import 'message_bubble.dart';

class MessagesStream extends StatelessWidget {
  final ChatController controller;

  const MessagesStream({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Team>(
      stream: controller.getTeamStream(),
      builder: (context, teamSnapshot) {
        final team = teamSnapshot.data;
        final pendingKey = team != null ? controller.pendingApprovalKey(team) : null;

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: controller.getMessages(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.lightBlueAccent,
                  ),
                ),
              );
            }

            final docs = snapshot.data!.docs;
            final user = Provider.of<UserProvider>(context, listen: false).currentUser!;
            final isAdmin = user.role == Role.ADMIN;

            String? latestImageMessageId;
            for (final doc in docs) {
              final type = doc.data()['type'] as String?;
              if (type == MessageType.image.name) {
                latestImageMessageId = doc.id;
              }
            }

            final bubbles = <Widget>[];
            for (final doc in docs.reversed) {
              final data = doc.data();
              final senderRaw = data['sender'] as String? ?? Role.USER.name;
              final sender = Role.values.byName(senderRaw);
              final isMe = user.role == sender;
              final typeRaw = data['type'] as String?;
              final type = typeRaw != null
                  ? MessageType.values.byName(typeRaw)
                  : MessageType.text;

              if (type == MessageType.image) {
                final imageUrl = data['imageUrl'] as String? ?? '';
                final isLatestImage = doc.id == latestImageMessageId;
                final canApprove = isAdmin &&
                    isLatestImage &&
                    pendingKey != null &&
                    team != null;

                bubbles.add(ImageMessageBubble(
                  sender: senderRaw,
                  imageUrl: imageUrl,
                  isMe: isMe,
                  showApprovalActions: canApprove,
                  onApprove: canApprove
                      ? () => controller.approveCurrentPhoto(team)
                      : null,
                  onDeny: canApprove
                      ? () => controller.denyCurrentPhoto(team)
                      : null,
                ));
              } else {
                bubbles.add(MessageBubble(
                  sender: senderRaw,
                  text: data['text'] as String? ?? '',
                  isMe: isMe,
                ));
              }
            }

            return Expanded(
              child: ListView(
                reverse: true,
                padding: const EdgeInsets.symmetric(
                    horizontal: 10.0, vertical: 20.0),
                children: bubbles,
              ),
            );
          },
        );
      },
    );
  }
}
