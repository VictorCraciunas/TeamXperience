import 'package:firebase_auth/firebase_auth.dart';

import '../../../backend/authentication/AuthenticationRepository.dart';
import '../../../backend/repo/user_repo.dart';
import '../../../model/user.dart';

class LogInService {
  AuthenticationRepository authenticationRepository =
      AuthenticationRepository();
  UserRepo userRepo = UserRepo();

  Future<void> logIn(String email, String password) async {
    await authenticationRepository.loginWithEmailAndPassword(email, password);
  }

  Future<void> logInGoogle() async {
    UserCredential userCredential =
    await authenticationRepository.signInWithGoogle();
    final profile = userCredential.additionalUserInfo?.profile;

    final firstName = profile?['given_name'];
    final lastName = profile?['family_name'];

    if (await userRepo.findByEmail(userCredential.user!.email!) == null) {
      //save the user into database
      AppUser appUser = AppUser(
        email: userCredential.user!.email!,
        firstName: firstName,
        lastName: lastName,
        uid: userCredential.user!.uid,
      );
      await userRepo.saveUser(appUser);
    }
  }
}
