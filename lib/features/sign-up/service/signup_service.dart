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

    String? token = await FCMService.getFCMToken();

    //save the user into database
    AppUser appUser = AppUser(
        email: normalizedEmail,
        firstName: firstName,
        lastName: lastName,
        uid: userCredential.user!.uid,
        fcmToken: token  ?? ""

    );
    userRepo.saveUser(appUser);
  }

  Future<void> signInGoogle() async {
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
      userRepo.saveUser(appUser);
    }
  }
}
