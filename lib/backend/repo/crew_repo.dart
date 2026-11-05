import 'package:cloud_firestore/cloud_firestore.dart';

import '../../model/crew.dart';

class CrewRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// The crews the user belongs to, sorted by name. Crews are written by Cloud
  /// Functions; the app only reads them.
  Stream<List<Crew>> streamUserCrews(String uid) {
    return _firestore
        .collection('crews')
        .where('memberUids', arrayContains: uid)
        .snapshots()
        .map(
          (snapshot) => sortCrews(
            snapshot.docs
                .map((doc) => Crew.fromMap(doc.id, doc.data()))
                .toList(),
          ),
        );
  }
}

/// [crews] by name, ignoring case, in a new list. Sorted here because
/// `arrayContains` with `orderBy` would need a composite index.
List<Crew> sortCrews(List<Crew> crews) {
  final sorted = [...crews];
  sorted.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return sorted;
}
