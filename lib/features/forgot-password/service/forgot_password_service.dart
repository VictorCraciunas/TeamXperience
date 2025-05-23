import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordService{
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> sendLink(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }
}