import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamxperience/enums/message_type.dart';
import 'package:teamxperience/enums/role.dart';
import 'package:teamxperience/model/user.dart';

import '../backend/repo/messages_repo.dart';
import '../model/message.dart';

class MessageService{
  MessageRepo repo = MessageRepo();

  Future<void> sendMessage(String eventId, String teamName, String text ,AppUser user)async{
    Message message;
    if (user.role == Role.ADMIN){
      message = Message(sender: Role.ADMIN, text: text,timestamp: DateTime.now());
    }
    else{
      message = Message(sender: Role.USER, text: text, timestamp: DateTime.now());
    }
    repo.sendMessage(message, eventId, teamName);
  }

  Future<void> sendImageMessage(
    String eventId,
    String teamName,
    String imageUrl,
    AppUser user, {
    String? approvalKey,
  }) async {
    final message = Message(
      sender: user.role == Role.ADMIN ? Role.ADMIN : Role.USER,
      text: 'Fotografie încărcată pentru aprobare',
      timestamp: DateTime.now(),
      type: MessageType.image,
      imageUrl: imageUrl,
      approvalKey: approvalKey,
    );
    await repo.sendMessage(message, eventId, teamName);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>  getMessages(String eventId, String teamId) {
    return repo.getMessages(eventId, teamId);
  }

}
