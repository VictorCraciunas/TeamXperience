import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../backend/authentication/AuthenticationRepository.dart';
import '../../../backend/repo/user_repo.dart';
import '../../../model/user.dart';

class SignUpService {
  AuthenticationRepository authenticationRepository =
      AuthenticationRepository();
  UserRepo userRepo = UserRepo();

  Future<void> register(String email, String password, BuildContext context) async {

    UserCredential userCredential = await authenticationRepository.register(email, password);

    //save the user into database
    AppUser appUser =
        AppUser(email: email, uid: userCredential.user!.uid);
    userRepo.saveUser(appUser);
  }

  Future<void> logInGoogle() async {
    UserCredential userCredential =
        await authenticationRepository.signInWithGoogle();
    if (await userRepo.findByEmail(userCredential.user!.email!) == null) {

      //save the user into database
      AppUser appUser = AppUser(
          email: userCredential.user!.email!,
          uid: userCredential.user!.uid);
      userRepo.saveUser(appUser);
    }
  }
}
