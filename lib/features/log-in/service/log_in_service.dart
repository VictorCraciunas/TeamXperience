import 'package:firebase_auth/firebase_auth.dart';
import 'package:teamxperience/service/FCMService.dart';

import '../../../backend/authentication/AuthenticationRepository.dart';
import '../../../backend/repo/user_repo.dart';
import '../../../model/user.dart';

class LogInService {
  AuthenticationRepository authenticationRepository =
  AuthenticationRepository();
  UserRepo userRepo = UserRepo();

  Future<void> logIn(String email, String password) async {
    await authenticationRepository.loginWithEmailAndPassword(email, password);


    User? currentUser = authenticationRepository.authUser;
    if (currentUser != null) await FCMService.saveTokenAsking(currentUser.uid);
  }

  Future<void> logInGoogle() async {
    UserCredential userCredential =
    await authenticationRepository.signInWithGoogle();
    final profile = userCredential.additionalUserInfo?.profile;

    final firstName = profile?['given_name'];
    final lastName = profile?['family_name'];

    if (await userRepo.findByEmail(userCredential.user!.email!) == null) {
      String? token = await FCMService.getFCMToken();

      //save the user into database
      AppUser appUser = AppUser(
          email: userCredential.user!.email!,
          firstName: firstName,
          lastName: lastName,
          uid: userCredential.user!.uid,
          fcmToken: token  ?? ""
      );
      await userRepo.saveUser(appUser);
    }else{
      final user = userCredential.user;
      if (user != null) await FCMService.saveTokenAsking(user.uid);
    }
  }
}
