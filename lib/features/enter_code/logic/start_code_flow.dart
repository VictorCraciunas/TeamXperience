import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';

import 'start_code_check.dart';

/// Checks the start code, finds the player's team and starts it, one tap at
/// a time.
class StartCodeFlow {
  StartCodeFlow({required this.findTeam, required this.startTeam});

  final Future<Team?> Function() findTeam;
  final Future<void> Function(Team team) startTeam;

  bool _running = false;

  /// The result and, when it is [StartCodeResult.ok], the team. Null while an
  /// earlier submit is still running. The start is written without waiting
  /// for the server, so a weak signal does not hold the team at the door.
  Future<(StartCodeResult, Team?)?> submit({
    required String input,
    required Event event,
    required DateTime now,
  }) async {
    if (_running) return null;
    _running = true;
    try {
      final check = checkStartCode(input: input, event: event, now: now);
      if (check != StartCodeResult.ok) return (check, null);

      final Team? team;
      try {
        team = await findTeam();
      } catch (e) {
        debugPrint('Start code: team lookup failed: $e');
        return (StartCodeResult.failed, null);
      }
      if (team == null) return (StartCodeResult.noTeam, null);

      unawaited(startTeam(team).catchError((Object e) => debugPrint('Start code: start failed: $e')));
      return (StartCodeResult.ok, team);
    } finally {
      _running = false;
    }
  }
}
