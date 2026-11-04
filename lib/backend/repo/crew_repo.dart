import 'package:cloud_firestore/cloud_firestore.dart';

import '../../model/crew.dart';

class CrewRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// The crews the user belongs to, by name. Crews are written by Cloud
  /// Functions; the app only reads them.
  Stream<List<Crew>> streamUserCrews(String uid) {
    return _firestore
        .collection('crews')
        .where('memberUids', arrayContains: uid)
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Crew.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }
}
