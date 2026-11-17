import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../backend/authentication/AuthenticationRepository.dart';
import '../../../backend/repo/user_repo.dart';
import '../../../model/user.dart';
import '../../../service/FCMService.dart';

class SignUpService {
  AuthenticationRepository authenticationRepository =
  AuthenticationRepository();
  UserRepo userRepo = UserRepo();

  Future<void> register(
      String email,
      String firstName,
      String lastName,
      password,
      BuildContext context,
      ) async {
    UserCredential userCredential = await authenticationRepository.register(
      email,
      password,
    );
    String normalizedEmail = userCredential.user!.email!.toLowerCase();

    //save the user into database (no push token: those go to pushTokens)
    AppUser appUser = AppUser(
        email: normalizedEmail,
        firstName: firstName,
        lastName: lastName,
        uid: userCredential.user!.uid,
        fcmToken: ""

    );
    userRepo.saveUser(appUser);
    await FCMService.saveTokenAsking(appUser.uid);
  }

  Future<void> signInGoogle() async {
    UserCredential userCredential =
    await authenticationRepository.signInWithGoogle();
    final profile = userCredential.additionalUserInfo?.profile;

    final firstName = profile?['given_name'];
    final lastName = profile?['family_name'];

    if (await userRepo.findByEmail(userCredential.user!.email!) == null) {
      //save the user into database (no push token: those go to pushTokens)
      AppUser appUser = AppUser(
          email: userCredential.user!.email!,
          firstName: firstName,
          lastName: lastName,
          uid: userCredential.user!.uid,
          fcmToken: ""
      );
      userRepo.saveUser(appUser);
    }
    // A new account or one signing in again from here: this device is saved.
    final user = userCredential.user;
    if (user != null) await FCMService.saveTokenAsking(user.uid);
  }
}
