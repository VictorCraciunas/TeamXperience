import 'package:cloud_firestore/cloud_firestore.dart';

import '../enums/message_type.dart';
import '../enums/role.dart';

class Message {
  final Role sender;
  final String text;
  final DateTime timestamp;
  final MessageType type;
  final String? imageUrl;
  final String? approvalKey;

  /// Posted to every team by the organiser's "Anunț"; that sends its own push.
  final bool announcement;

  Message({
    required this.sender,
    required this.text,
    required this.timestamp,
    this.type = MessageType.text,
    this.imageUrl,
    this.approvalKey,
    this.announcement = false,
  });

  factory Message.fromFirestore(Map<String, dynamic> data) {
    final raw = data['sender'] as String? ?? Role.USER.name;
    final sender = Role.values.byName(raw);
    final rawType = data['type'] as String?;
    final type = rawType != null
        ? MessageType.values.byName(rawType)
        : MessageType.text;

    return Message(
      sender: sender,
      text: data['text'] as String? ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      type: type,
      imageUrl: data['imageUrl'] as String?,
      approvalKey: data['approvalKey'] as String?,
      announcement: data['announcement'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender': sender.name,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type.name,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (approvalKey != null) 'approvalKey': approvalKey,
      if (announcement) 'announcement': true,
    };
  }
}
