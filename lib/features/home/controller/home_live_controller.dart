import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/service/leaderboard.dart';

/// The live part of Home: streams every team of the game being played and
/// keeps them ranked for the leaderboard and "Echipa ta".
class HomeLiveController extends ChangeNotifier {
  HomeLiveController({required Stream<List<Team>> Function(String eventId) teams}) : _teams = teams;

  final Stream<List<Team>> Function(String eventId) _teams;
  StreamSubscription<List<Team>>? _subscription;
  String? _eventId;
  int _missionCount = 0;
  List<RankedTeam> _ranked = const [];
  String? _board;

  /// The teams in leaderboard order; empty before data or after an error.
  List<RankedTeam> get ranked => _ranked;

  /// Follows [event]'s teams; null stops. Watching the same event again
  /// keeps the stream.
  void watch(Event? event) {
    final id = event?.eventId;
    if (id == _eventId) return;
    _subscription?.cancel();
    _subscription = null;
    _eventId = id;
    _missionCount = event?.nrMissions ?? 0;
    _ranked = const [];
    _board = null;
    if (id == null) {
      notifyListeners();
      return;
    }
    _subscription = _teams(id).listen(
      (teams) {
        // Team docs change on every location fix; only what Home shows
        // (the order, progress, mission times, presence) is worth a rebuild.
        final ranked = rankTeams(teams, missionCount: _missionCount);
        final board = _boardOf(ranked);
        if (board == _board) return;
        _board = board;
        _ranked = ranked;
        notifyListeners();
      },
      onError: (Object _) {
        _ranked = const [];
        _board = null;
        notifyListeners();
      },
    );
  }

  static String _boardOf(List<RankedTeam> ranked) => [
        for (final r in ranked)
          [
            r.team.name,
            r.team.missionProgress,
            r.team.hasFinished,
            r.mission,
            for (final e in r.team.missionCompletedAt.entries) '${e.key}@${e.value.millisecondsSinceEpoch}',
            for (final e in r.team.presence.entries) '${e.key}@${e.value.millisecondsSinceEpoch}',
          ].join('|'),
      ].join(';');

  /// The player's own team as the stream last sent it.
  Team? own(String teamName) => _ranked.where((r) => r.team.name == teamName).firstOrNull?.team;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
