import 'package:flutter/widgets.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';

import 'intro_seen_store.dart';

/// Every player way into a game: the intro letter the first time on this
/// device, then the game itself.
class GameDoor {
  GameDoor({IntroSeenStore? store}) : _store = store ?? IntroSeenStore();

  final IntroSeenStore _store;

  /// Opens the intro or the game. With [replace] the page that opened the
  /// door (the start screen) goes, so back does not lead to it.
  Future<void> open(NavigatorState navigator, Event event, Team team, {bool replace = false}) async {
    final seen = await _store.seen(event.eventId, team.name);
    final route = seen ? Routes.eventGame : Routes.gameIntro;
    final arguments = {'event': event, 'team': team};
    if (replace) {
      navigator.pushReplacementNamed(route, arguments: arguments);
    } else {
      navigator.pushNamed(route, arguments: arguments);
    }
  }

  /// "Spre prima misiune": remembers the letter was read and puts the game
  /// in the intro's place.
  Future<void> leaveIntro(NavigatorState navigator, Event event, Team team) async {
    await _store.markSeen(event.eventId, team.name);
    navigator.pushReplacementNamed(Routes.eventGame, arguments: {'event': event, 'team': team});
  }
}
