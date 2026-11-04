import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/backend/authentication/AuthenticationRepository.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/state_management/events_state_management.dart';
import 'package:teamxperience/state_management/news_state_management.dart';

class ProfileController {
  ProfileController(this.context);

  final BuildContext context;
  final AuthenticationRepository _authRepo = AuthenticationRepository();

  void openTeams() => Navigator.pushNamed(context, Routes.teams);

  void logout() {
    context.read<EventList>().clear();
    context.read<NewsList>().clear();
    _authRepo.logout();
    Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.splash,
      (Route<dynamic> route) => false,
    );
  }
}
