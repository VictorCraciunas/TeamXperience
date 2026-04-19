import 'package:cloud_firestore/cloud_firestore.dart';

import '../enums/message_type.dart';
import '../enums/role.dart';

class Message {
  final Role sender;
  final String text;
  final DateTime timestamp;
  final MessageType type;
  final String? imageUrl;

  Message({
    required this.sender,
    required this.text,
    required this.timestamp,
    this.type = MessageType.text,
    this.imageUrl,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender': sender.name,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type.name,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }
}
