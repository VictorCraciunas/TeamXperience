import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamxperience/model/message.dart';

class MessageRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(
    Message message,
    String eventId,
    String teamName,
  ) async {
    await _firestore
        .collection('events')
        .doc(eventId)
        .collection("teams")
        .doc(teamName)
        .collection("messages")
        .add(message.toJson());
  }

  DocumentReference<Map<String, dynamic>> _team(String eventId, String teamName) =>
      _firestore.collection('events').doc(eventId).collection('teams').doc(teamName);

  /// A player's text, and the mark that tells the organiser's live room there
  /// is something to read. Two writes on purpose: a mark that cannot be saved
  /// must never take the message with it.
  Future<void> sendPlayerMessage(Message message, String eventId, String teamName) {
    final team = _team(eventId, teamName);
    final sent = team.collection('messages').add(message.toJson());
    team.update({
      'unreadByAdmin': {'text': message.text, 'at': FieldValue.serverTimestamp()},
    }).catchError((Object _) {});
    return sent;
  }

  /// One message to each of [teamNames], all or none.
  Future<void> sendToTeams(Message message, String eventId, List<String> teamNames) {
    final batch = _firestore.batch();
    for (final name in teamNames) {
      batch.set(_team(eventId, name).collection('messages').doc(), message.toJson());
    }
    return batch.commit();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(String eventId, String teamId) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('teams')
        .doc(teamId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
