import 'package:flutter/widgets.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/features/game_intro/logic/game_door.dart';
import 'package:teamxperience/features/play_tab/widgets/play_popup_actions.dart';
import 'package:teamxperience/model/user.dart';

/// The Joacă pop-up's buttons, sent to the same screens Home opens.
PlayPopupActions playPopupRoutes({
  required NavigatorState navigator,
  required AppUser? Function() user,
  required VoidCallback browseAll,
}) =>
    PlayPopupActions(
      openEvent: (event) => navigator.pushNamed(Routes.eventDetails, arguments: {'event': event, 'isAdmin': false}),
      openTeam: (event) => navigator.pushNamed(Routes.registerTeamDetails, arguments: {'event': event, 'user': user()}),
      enterCode: (event) => navigator.pushNamed(Routes.enterCodeScreen, arguments: event),
      continueGame: (event, team) => GameDoor().open(navigator, event, team),
      openChat: (event, team) =>
          navigator.pushNamed(Routes.chatScreen, arguments: {'eventId': event.eventId, 'team': team}),
      browseAll: browseAll,
    );
