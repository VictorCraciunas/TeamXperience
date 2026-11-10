import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamxperience/model/season_standing.dart';

class SeasonRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// A season's top crews, most points first. Written only by the results
  /// function.
  Stream<List<SeasonStanding>> streamStandings(String seasonId, {int limit = 10}) {
    return _firestore
        .collection('seasons')
        .doc(seasonId)
        .collection('standings')
        .orderBy('points', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => [for (final doc in snap.docs) SeasonStanding.fromMap(doc.id, doc.data())]);
  }
}
