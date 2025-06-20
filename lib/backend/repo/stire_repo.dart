import 'package:cloud_firestore/cloud_firestore.dart';

import '../../model/stire.dart';

class StireRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> getNewStireId() async {
    return _firestore.collection('stire').doc().id;
  }

  Future<void> createStire(Stire stire) async {
    var docRef = _firestore.collection('stire').doc(stire.id);
    await docRef.set(stire.toJson());
  }

  Future<List<Stire>> getAllStire() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('stire').get();

      List<Stire> stireList =
          snapshot.docs.map((doc) {
            return Stire.fromMap(doc.data() as Map<String, dynamic>);
          }).toList();

      return stireList;
    } catch (e, stacktrace) {
      print('Error fetching stire: $e');
      print('Stack trace: $stacktrace');
      throw Exception('Failed to fetch stire');
    }
  }
}
