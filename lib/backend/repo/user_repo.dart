import 'confirmed_docs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../model/memory.dart';
import '../../model/user.dart';

/// The user could not be looked up (offline, a refused read, an unreadable
/// document). It says nothing about whether the user exists.
class UserLookupFailed implements Exception {
  const UserLookupFailed();

  @override
  String toString() => 'Nu am putut verifica contul. Încearcă din nou.';
}

class UserRepo{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUser(AppUser user) async{
    await _firestore.collection('users').doc(user.uid).set(user.toJson());
  }


  /// The user's own document, live (their XP, stats and badges change when a
  /// game ends); null while it does not exist.
  Stream<AppUser?> streamUser(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snap) {
      final data = snap.data();
      return data == null ? null : AppUser.fromFirestore(data);
    });
  }

  /// The user's latest finished games, newest first.
  Stream<List<Memory>> streamMemories(String uid, {int limit = 3}) {
    final query = _firestore
        .collection('users')
        .doc(uid)
        .collection('memories')
        .orderBy('date', descending: true)
        .limit(limit);
    return query.snapshots().asyncMap((snap) async {
      final docs = await confirmedDocs(query, snap);
      return [for (final doc in docs) Memory.fromMap(doc.id, doc.data())];
    });
  }

  /// The user with this email, or null only when there truly is none. A
  /// failed lookup throws [UserLookupFailed]: callers create a new user on
  /// null, and `saveUser` replaces the whole document.
  Future<AppUser?> findByEmail(String email) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = snapshot.docs.first;
        return AppUser.fromFirestore(doc.data() as Map<String, dynamic>);
      }
      // Offline, an empty answer from the local cache does not throw, and it
      // does not mean there is no such user.
      if (snapshot.metadata.isFromCache) throw const UserLookupFailed();
      return null;
    } catch (e) {
      print('Error finding user by email: $e');
      throw const UserLookupFailed();
    }
  }

  Future<void> addEventToUser(String userId, String eventId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'registeredEventIds': FieldValue.arrayUnion([eventId])
      });
    } catch (e) {
      print('Error adding event to user: $e');
      throw Exception('Failed to add event to user: $userId');
    }
  }

  Future<void> removeEventFromUser(String userId, String eventId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'registeredEventIds': FieldValue.arrayRemove([eventId])
      });
    } catch (e) {
      print('Error removing event from user: $e');
      throw Exception('Failed to remove event from user: $userId');
    }
  }

  Future<List<Map<String, dynamic>>> getRegisteredEventsFromUser(AppUser user) async {
    try {
      // If user has no registered events, return empty list
      if (user.registeredEventIds.isEmpty) {
        return [];
      }

      List<Map<String, dynamic>> registeredEvents = [];

      // Fetch each registered event
      for (String eventId in user.registeredEventIds) {
        try {
          DocumentSnapshot eventDoc = await _firestore.collection('events').doc(eventId).get();

          if (eventDoc.exists) {
            Map<String, dynamic> eventData = eventDoc.data() as Map<String, dynamic>;
            registeredEvents.add({
              'eventId': eventId,
              'eventData': eventData,
              'eventTitle': eventData['title'] ?? 'Unknown Event',
              'eventDate': eventData['date'],
            });
          }
        } catch (e) {
          print('Error fetching event $eventId: $e');
          // Continue with other events if one fails
        }
      }

      return registeredEvents;
    } catch (e, stacktrace) {
      print('Error fetching registered events from user object: $e');
      print('Stack trace: $stacktrace');
      throw Exception('Failed to fetch registered events for user: ${user.uid}');
    }
  }

  Future<void> updateFCMToken(String uid, String fcmToken) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'fcmToken': fcmToken,
      });
      print('FCM token updated for user: $uid');
    } catch (e) {
      print('Error updating FCM token: $e');
      throw e;
    }
  }

}