import 'package:teamxperience/features/game_intro/logic/game_door.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/features/home/logic/hero_from_providers.dart';
import 'package:teamxperience/features/play_tab/logic/play_tab_state.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/state_management/events_state_management.dart';
import 'package:teamxperience/state_management/user_registered_events.dart';

/// Keeps the Joacă tab's state in step with the player's events: it follows
/// the providers and re-reads the clock every 30 s (the enter-code window and
/// the game's end are time-based).
class PlayTabController extends ChangeNotifier {
  PlayTabController({
    required this.userEvents,
    required this.eventList,
    required this.navigator,
    required this.onBrowse,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    userEvents.addListener(_changed);
    eventList.addListener(_changed);
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _changed());
  }

  final UserEventsProvider userEvents;
  final EventList eventList;
  final NavigatorState navigator;

  /// Switches the shell to the Evenimente tab.
  final VoidCallback onBrowse;
  final DateTime Function() _clock;
  late final Timer _timer;

  PlayTabState get state =>
      playTabState(heroFromProviders(includeFinished: false, userEvents: userEvents, eventList: eventList, now: _clock()));

  void _changed() => notifyListeners();

  void continueGame(Event event, Team team) => GameDoor().open(navigator, event, team);

  void enterCode(Event event) => navigator.pushNamed(Routes.enterCodeScreen, arguments: event);

  void openEvent(Event event) =>
      navigator.pushNamed(Routes.eventDetails, arguments: {'event': event, 'isAdmin': false});

  @override
  void dispose() {
    _timer.cancel();
    userEvents.removeListener(_changed);
    eventList.removeListener(_changed);
    super.dispose();
  }
}
