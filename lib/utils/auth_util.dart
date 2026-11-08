import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:teamxperience/constants/routes.dart';

import '../backend/authentication/AuthenticationRepository.dart';
import '../backend/repo/user_repo.dart';
import '../enums/role.dart';
import '../model/user.dart';
import '../state_management/user_provider.dart';

class AuthUtil {
  final UserRepo userRepo;
  final AuthenticationRepository authenticationRepository;
  final UserProvider userProvider;

  AuthUtil(this.userRepo, this.authenticationRepository, this.userProvider);

  // -------- role based redirect -----------
  Future<void> checkUserAndRedirect(BuildContext context) async {

    User? currentUser = authenticationRepository.authUser;
    if (currentUser == null) {
      userProvider.clearUser();
      Navigator.pushNamedAndRemoveUntil(context, Routes.splash,(Route<dynamic> route) => false);
    } else {
      // User is logged in, fetch their data
      String email = currentUser.email!;
      AppUser? appUser;
      try {
        appUser = await userRepo.findByEmail(email);
      } on UserLookupFailed {
        appUser = null;
      }

      if(appUser != null){
        userProvider.setUser(appUser, currentUser);

        print("a merssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss");
        if (appUser.role == Role.ADMIN) {
          if (!context.mounted) return;
          Navigator.pushNamedAndRemoveUntil(context, Routes.adminHome,(Route<dynamic> route) => false);
        }
        else {
          if (!context.mounted) return;
          Navigator.pushNamedAndRemoveUntil(context, Routes.home,(Route<dynamic> route) => false);
        }
      }
      else{
        // No user to show (the lookup failed, or there is no document): back
        // to the start rather than staying on the loader for ever.
        userProvider.clearUser();
        if (!context.mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, Routes.splash, (Route<dynamic> route) => false);
      }
    }
  }
}