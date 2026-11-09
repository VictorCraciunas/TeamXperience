import 'package:cloud_firestore/cloud_firestore.dart';

import '../../model/app_notification.dart';

/// A player's notification list, written by the Cloud Functions. The player
/// can only read their own and mark them read.
class NotificationRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _list(String uid) =>
      _firestore.collection('users').doc(uid).collection('notifications');

  /// The latest, newest first.
  Stream<List<AppNotification>> stream(String uid, {int limit = 50}) {
    return _list(uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => [for (final doc in snap.docs) AppNotification.fromMap(doc.id, doc.data())]);
  }

  Future<void> markRead(String uid, String id) => _list(uid).doc(id).update({'read': true});

  /// Marks these read in one write.
  Future<void> markAllRead(String uid, Iterable<String> ids) async {
    final batch = _firestore.batch();
    var any = false;
    for (final id in ids) {
      batch.update(_list(uid).doc(id), {'read': true});
      any = true;
    }
    if (any) await batch.commit();
  }
}
