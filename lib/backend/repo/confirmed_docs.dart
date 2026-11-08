import 'package:cloud_firestore/cloud_firestore.dart';

/// The documents of a live [snapshot]. Offline with nothing cached Firestore
/// answers with an empty list instead of an error, and that does not mean there
/// is nothing: such an answer is checked on the server, which throws when it
/// cannot be reached, so the stream reports a failure and carries on.
Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> confirmedDocs(
  Query<Map<String, dynamic>> query,
  QuerySnapshot<Map<String, dynamic>> snapshot,
) async {
  if (snapshot.docs.isNotEmpty || !snapshot.metadata.isFromCache) return snapshot.docs;
  final fresh = await query.get(const GetOptions(source: Source.server));
  return fresh.docs;
}
