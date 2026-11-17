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

  /// The player who wrote it (their uid and first name), set on every
  /// player's message since the chat redesign; null on older messages and on
  /// the organiser's. The rules make [senderUid] the writer's own uid.
  final String? senderUid;
  final String? senderName;

  Message({
    required this.sender,
    required this.text,
    required this.timestamp,
    this.type = MessageType.text,
    this.imageUrl,
    this.approvalKey,
    this.announcement = false,
    this.senderUid,
    this.senderName,
  });

  static String? _filled(Object? value) => value is String && value.trim().isNotEmpty ? value : null;

  factory Message.fromFirestore(Map<String, dynamic> data) {
    final raw = data['sender'] as String? ?? Role.USER.name;
    final sender = Role.values.byName(raw);
    final rawType = data['type'] as String?;
    final type = rawType != null
        ? MessageType.values.byName(rawType)
        : MessageType.text;
    final time = data['timestamp'];

    return Message(
      sender: sender,
      text: data['text'] as String? ?? '',
      timestamp: time is Timestamp ? time.toDate() : DateTime.now(),
      type: type,
      imageUrl: data['imageUrl'] as String?,
      approvalKey: data['approvalKey'] as String?,
      announcement: data['announcement'] == true,
      senderUid: _filled(data['senderUid']),
      senderName: _filled(data['senderName']),
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
      if (senderUid != null) 'senderUid': senderUid,
      if (senderName != null) 'senderName': senderName,
    };
  }
}
