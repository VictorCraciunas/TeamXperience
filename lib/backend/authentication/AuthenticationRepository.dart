import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get authUser => _auth.currentUser;

  ///Register with email and password
  Future<UserCredential> register(String email, String password) async {
    try {
      // Create user in Firebase Authentication
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('The account already exists for that email.');
      }
      throw Exception('An error occurred during registration: ${e.message}');
    } catch (e) {
      // Optionally, handle unexpected errors more broadly
      throw Exception('Unexpected error during registration: $e');
    }
  }

  ///Login
  Future<UserCredential> loginWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Wrong password provided for that user.');
      } else if (e.code == 'invalid-email') {
        throw Exception('The email address is not valid.');
      } else if (e.code == 'user-disabled') {
        throw Exception('This user has been disabled.');
      } else if (e.code == 'too-many-requests') {
        throw Exception('Too many requests. Try again later.');
      } else if (e.code == 'operation-not-allowed') {
        throw Exception('Signing in with email and password is not enabled.');
      }
      throw Exception('An error occurred during login   : ${e.message}');
    } catch (e) {
      throw Exception('An undefined Error happened.');
    }
  }
  /// Login with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Trigger the Google authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Sign in aborted by user.');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google [UserCredential]
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw Exception('Google sign-in failed: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error during Google sign-in: $e');
    }
  }

  Future<void> logout() async {
    // If the current user signed in with Google, sign out from Google first:
    try {
      // Check the list of linked providers for “google.com”
      final providers = _auth.currentUser?.providerData
          .map((info) => info.providerId)
          .toList() ??
          [];
      if (providers.contains(GoogleAuthProvider.PROVIDER_ID)) {
        await _googleSignIn.signOut();
      }
    } catch (e) {
      // ignore errors from Google sign-out
    }

    // Finally sign out from Firebase
    await _auth.signOut();
  }


}
