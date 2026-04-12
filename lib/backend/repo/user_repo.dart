import 'package:cloud_firestore/cloud_firestore.dart';

import '../../model/user.dart';

class UserRepo{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUser(AppUser user) async{
    await _firestore.collection('users').doc(user.uid).set(user.toJson());
  }


  Future<AppUser?> findByEmail(String email) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = snapshot.docs.first;
        return AppUser.fromFirestore(doc.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      print('Error finding user by email: $e');
      return null;
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