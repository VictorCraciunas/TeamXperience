import 'package:cloud_firestore/cloud_firestore.dart';

/// The devices pushes go to: `pushTokens/{token}` = `{uid, updatedAt}`, the
/// token as the id, so a phone belongs to the account last signed in on it.
/// The rules let only that account read or delete it, so nobody learns
/// another account's token; the functions read it to send.
class PushTokenRepo {
  PushTokenRepo({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _device(String token) => _firestore.collection('pushTokens').doc(token);

  /// This device now belongs to [uid] (a sign-in on it overwrites whoever had it).
  Future<void> save(String token, String uid) {
    return _device(token).set({'uid': uid, 'updatedAt': FieldValue.serverTimestamp()});
  }

  /// At sign-out: the device no longer gets this account's pushes. The rules
  /// refuse it when the device is someone else's.
  Future<void> delete(String token) => _device(token).delete();
}
