import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../backend/repo/user_repo.dart';
import '../../constants/routes.dart';
import '../../enums/role.dart';
import '../../model/event.dart';
import '../../model/team.dart';
import '../../state_management/events_state_management.dart';
import '../../state_management/user_provider.dart';
import '../event_service/event_service.dart';
import '../team_service/team_service.dart';
import 'push_destination.dart';

const _lookup = Duration(seconds: 8);

/// Opens what a tapped push is about, above the screen the app is on. Anything
/// that cannot be found sends a player to their notification list, and leaves
/// an organiser where they are.
Future<void> openPush(GlobalKey<NavigatorState> key, Map<String, dynamic> data) async {
  final navigator = key.currentState;
  if (navigator == null) return;
  final users = navigator.context.read<UserProvider>();
  final user = users.currentUser;
  final account = FirebaseAuth.instance.currentUser;
  if (user == null || account == null) return;
  final uid = account.uid;
  final isAdmin = user.role == Role.ADMIN;
  final fallback = isAdmin ? const PushNowhere() : const PushNotifications();

  try {
    var target = pushDestination(data, isAdmin: isAdmin);
    Object? arguments;
    switch (target) {
      case PushChat(:final eventId, :final teamName):
        final team = await _team(eventId, teamName, uid, isAdmin: isAdmin);
        if (team == null) {
          target = fallback;
        } else {
          arguments = {'eventId': eventId, 'team': team};
        }
      case PushEvent(:final eventId):
        final event = await _event(navigator.context, eventId);
        if (event == null) {
          target = fallback;
        } else {
          arguments = {'event': event, 'isAdmin': false};
        }
      case PushMemory(:final eventId):
        final memory = await _quiet(UserRepo().getMemory(uid, eventId));
        if (memory == null) {
          target = fallback;
        } else {
          arguments = {'memory': memory};
        }
      case PushNotifications() || PushNowhere():
        break;
    }
    if (!navigator.mounted || FirebaseAuth.instance.currentUser?.uid != uid) return;
    final route = switch (target) {
      PushChat() => Routes.chatScreen,
      PushEvent() => Routes.eventDetails,
      PushMemory() => Routes.memory,
      PushNotifications() => Routes.notifications,
      PushNowhere() => null,
    };
    if (route != null) unawaited(navigator.pushNamed(route, arguments: arguments));
  } catch (_) {
    // The navigator went away: the app stays where it is.
  }
}

/// An organiser opens the team by the name in the push; a player opens their
/// own team, which keeps working after a rename.
Future<Team?> _team(String eventId, String teamName, String uid, {required bool isAdmin}) {
  final teams = TeamService();
  return _quiet(isAdmin ? teams.getTeam(eventId, teamName) : teams.getUserTeamForEvent(eventId, uid));
}

Future<Event?> _event(BuildContext context, String eventId) async {
  for (final event in context.read<EventList>().events) {
    if (event.eventId == eventId) return event;
  }
  return _quiet(EventService().streamEvent(eventId).first);
}

/// What [lookup] finds; null when it fails or takes too long (offline).
Future<T?> _quiet<T>(Future<T?> lookup) async {
  try {
    return await lookup.timeout(_lookup);
  } catch (_) {
    return null;
  }
}
