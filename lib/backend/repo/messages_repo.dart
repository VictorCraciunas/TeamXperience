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
      'unreadByAdmin.text': message.text,
      'unreadByAdmin.at': FieldValue.serverTimestamp(),
      'unreadByAdmin.count': FieldValue.increment(1),
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

  /// The newest [limit] messages of a team's chat written after [since],
  /// newest first: what the player's floating chat button needs to count
  /// unread organiser messages without reading the whole history. One range
  /// filter and the order on the same field, so Firestore's automatic
  /// single-field index serves it (no composite index).
  Stream<QuerySnapshot<Map<String, dynamic>>> getMessagesAfter(
    String eventId,
    String teamName,
    DateTime since, {
    int limit = 100,
  }) {
    return _team(eventId, teamName)
        .collection('messages')
        .where('timestamp', isGreaterThan: Timestamp.fromDate(since))
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots();
  }
}
