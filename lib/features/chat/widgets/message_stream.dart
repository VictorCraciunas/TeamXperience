import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/enums/role.dart';
import '../../../state_management/user_provider.dart';
import 'message_bubble.dart';

class MessagesStream extends StatelessWidget {
  final Stream<QuerySnapshot<Map<String, dynamic>>> messageSteam;

  const MessagesStream({super.key, required this.messageSteam});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: messageSteam,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }

        final messages = snapshot.data!.docs.reversed;
        List<MessageBubble> messageBubbles = [];

        for (var message in messages) {
          final messageData = message.data();
          final messageText = messageData['text'];
          final messageSender = messageData['sender'];

          final user = Provider.of<UserProvider>(context, listen: false).currentUser;

          final messageBubble = MessageBubble(
            sender: messageSender,
            text: messageText,
            isMe: user!.role == Role.values.byName(messageSender),
          );
          messageBubbles.add(messageBubble);
        }

        return Expanded(
          child: ListView(
            reverse: true,
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}