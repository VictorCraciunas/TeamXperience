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
