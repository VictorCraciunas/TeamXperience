import 'package:cloud_firestore/cloud_firestore.dart';

import '../../model/event.dart';

class EventRepo{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> getNewEventId() async {
    return _firestore.collection('events').doc().id;
  }

  Future<void> createEvent(Event event) async {
    var docRef = _firestore.collection('events').doc(event.eventId);
    await docRef.set(event.toJson());
  }


  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
    } catch (e, stacktrace) {
      print('Error deleting event: $e');
      print('Stack trace: $stacktrace');
      throw Exception('Failed to delete event with ID: $eventId');
    }
  }

  Future<List<Event>> getAllEvents() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('events').get();

      List<Event> events = snapshot.docs.map((doc) {
        return Event.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      return events;
    } catch (e,stacktrace) {
      print('Error fetching events: $e');
      print('Stack trace: $stacktrace');
      throw Exception('Failed to fetch events');
    }
  }

}
