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
}
