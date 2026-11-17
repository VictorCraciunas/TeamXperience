import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamxperience/enums/message_type.dart';
import 'package:teamxperience/enums/role.dart';
import 'package:teamxperience/model/user.dart';

import '../backend/repo/messages_repo.dart';
import '../model/message.dart';

/// What a player's message says about who wrote it: their uid (the rules
/// check it is the writer's own) and first name. Empty values are left out.
({String? uid, String? name}) senderOf(AppUser user) {
  final uid = user.uid.trim();
  final first = user.firstName.trim();
  final full = '${user.firstName} ${user.lastName}'.trim();
  final name = first.isNotEmpty ? first : full;
  return (uid: uid.isEmpty ? null : uid, name: name.isEmpty ? null : name);
}

class MessageService{
  MessageRepo repo = MessageRepo();

  Future<void> sendMessage(String eventId, String teamName, String text ,AppUser user)async{
    Message message;
    if (user.role == Role.ADMIN){
      message = Message(sender: Role.ADMIN, text: text,timestamp: DateTime.now());
      await repo.sendMessage(message, eventId, teamName);
    }
    else{
      final from = senderOf(user);
      message = Message(
        sender: Role.USER,
        text: text,
        timestamp: DateTime.now(),
        senderUid: from.uid,
        senderName: from.name,
      );
      await repo.sendPlayerMessage(message, eventId, teamName);
    }
  }

  /// The organiser's announcement, into the chat of every team in [teamNames].
  Future<void> announce(String eventId, List<String> teamNames, String text) {
    final message = Message(sender: Role.ADMIN, text: text, timestamp: DateTime.now(), announcement: true);
    return repo.sendToTeams(message, eventId, teamNames);
  }

  /// A picture in the team's chat: a photo puzzle's (with its [approvalKey],
  /// waiting for the organiser) or one sent from the chat's photo button
  /// (without a key, with [text] as the push's words).
  Future<void> sendImageMessage(
    String eventId,
    String teamName,
    String imageUrl,
    AppUser user, {
    String? approvalKey,
    String text = 'Fotografie încărcată pentru aprobare',
  }) async {
    final isAdmin = user.role == Role.ADMIN;
    final from = isAdmin ? (uid: null, name: null) : senderOf(user);
    final message = Message(
      sender: isAdmin ? Role.ADMIN : Role.USER,
      text: text,
      timestamp: DateTime.now(),
      type: MessageType.image,
      imageUrl: imageUrl,
      approvalKey: approvalKey,
      senderUid: from.uid,
      senderName: from.name,
    );
    // A player's chat photo marks the chat unread like a text does; a puzzle
    // photo doesn't, since its pending approval already flags the team.
    if (!isAdmin && approvalKey == null) {
      await repo.sendPlayerMessage(message, eventId, teamName);
    } else {
      await repo.sendMessage(message, eventId, teamName);
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>  getMessages(String eventId, String teamId) {
    return repo.getMessages(eventId, teamId);
  }

  /// Only the team chat's messages written after [since] (the newest 100),
  /// for the floating chat button.
  Stream<QuerySnapshot<Map<String, dynamic>>> getMessagesAfter(String eventId, String teamName, DateTime since) {
    return repo.getMessagesAfter(eventId, teamName, since);
  }

}
