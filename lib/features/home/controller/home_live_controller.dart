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
    if (id == null) {
      notifyListeners();
      return;
    }
    _subscription = _teams(id).listen(
      (teams) {
        _ranked = rankTeams(teams, missionCount: _missionCount);
        notifyListeners();
      },
      onError: (Object _) {
        _ranked = const [];
        notifyListeners();
      },
    );
  }

  /// The player's own team as the stream last sent it.
  Team? own(String teamName) => _ranked.where((r) => r.team.name == teamName).firstOrNull?.team;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
