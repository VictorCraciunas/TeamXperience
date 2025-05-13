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

}