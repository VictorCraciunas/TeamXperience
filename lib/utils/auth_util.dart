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
  /// Loads the user and opens their home, or the start when signed out.
  /// The page changes only once [after] is done (the start-up logo), while
  /// the user loads in the meantime.
  Future<void> checkUserAndRedirect(BuildContext context, {Future<void>? after}) async {
    final route = await _startRoute();
    await after;
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, route, (Route<dynamic> route) => false);
  }

  /// Where the app opens: the role's home, or the start without a user.
  Future<String> _startRoute() async {
    User? currentUser = authenticationRepository.authUser;
    if (currentUser == null) {
      userProvider.clearUser();
      return Routes.splash;
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

        return appUser.role == Role.ADMIN ? Routes.adminHome : Routes.home;
      }
      else{
        // No user to show (the lookup failed, or there is no document): back
        // to the start rather than staying on the loader for ever.
        userProvider.clearUser();
        return Routes.splash;
      }
    }
  }
}