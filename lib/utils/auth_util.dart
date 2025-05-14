import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../backend/authentication/AuthenticationRepository.dart';
import '../backend/repo/user_repo.dart';
import '../enums/role.dart';
import '../model/user.dart';

class AuthUtil {
  final UserRepo userRepo;
  final AuthenticationRepository authenticationRepository;
  AuthUtil(this.userRepo, this.authenticationRepository);

  Future<void> checkUserAndRedirect(BuildContext context) async {
    User? currentUser = authenticationRepository.getCurrentUser();
    if (currentUser == null) {
      Navigator.pushReplacementNamed(context, '/register_screen');
    } else {
      // User is logged in, fetch their data
      String email = currentUser.email!;
      AppUser? appUser = await userRepo.findByEmail(email);

      if(appUser != null){
        if (appUser.role == Role.ADMIN) {
          if (!context.mounted) return;
          Navigator.pushReplacementNamed(context, '/create_event');
      }
        else {
          print("$appUser.role");
          if (!context.mounted) return;
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    }
  }
}