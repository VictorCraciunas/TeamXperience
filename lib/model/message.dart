import 'package:cloud_firestore/cloud_firestore.dart';

import '../enums/role.dart';

class Message {
  final Role sender;
  final String text;
  final DateTime timestamp;

  Message({required this.sender, required this.text, required this.timestamp});

  factory Message.fromFirestore(Map<String, dynamic> data) {
    final raw = data['sender'] as String? ?? Role.USER.name;
    final sender = Role.values.byName(raw);

    return Message(
      sender: sender,
      text: data['text'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender': sender.name,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}