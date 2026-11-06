import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:teamxperience/features/event_game/logic/route_texts.dart';
import 'package:teamxperience/features/finish/logic/finish_recap.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/service/leaderboard.dart';

/// Holds the finish screen: the team (kept fresh), its place among every
/// team, and the player's rating. The streams and the save are passed in.
class FinishController extends ChangeNotifier {
  FinishController({
    required this.event,
    required Team team,
    required Stream<List<Team>> teams,
    required Stream<Team> teamStream,
    required Future<void> Function(int stars) saveRating,
    DateTime Function()? clock,
  })  : _team = team,
        _saveRating = saveRating,
        _clock = clock ?? DateTime.now {
    _teamsWatch = teams.listen(_onTeams, onError: (Object _) {});
    _teamWatch = teamStream.listen(_onTeam, onError: (Object _) {});
  }

  final Event event;
  final Future<void> Function(int stars) _saveRating;
  final DateTime Function() _clock;
  StreamSubscription<List<Team>>? _teamsWatch;
  StreamSubscription<Team>? _teamWatch;
  bool _disposed = false;

  Team _team;
  Team get team => _team;

  ({int place, int teams})? _place;

  /// The team's place among every team; null until they arrive.
  ({int place, int teams})? get place => _place;

  List<RankedTeam> _ranked = const [];
  List<RankedTeam> get ranked => _ranked;

  int? _rating;
  int? get rating => _rating;

  void _changed() {
    if (!_disposed) notifyListeners();
  }

  void _onTeams(List<Team> teams) {
    _ranked = rankTeams(teams, missionCount: event.missions.length);
    _place = placeOf(teams, _team.name, event.missions.length);
    _changed();
  }

  void _onTeam(Team fresh) {
    _team = fresh;
    _changed();
  }

  /// How long the team played, as of now.
  Duration get timePlayed => playedTime(event, _team, _clock());

  /// What "Distribuie" shares.
  String get shareText => shareLine(event, _team, _place, timePlayed, _team.distanceMeters);

  /// Saves the player's rating; the stars stay chosen here even if the save
  /// fails (it is only feedback).
  Future<void> rate(int stars) async {
    _rating = stars;
    _changed();
    try {
      await _saveRating(stars);
    } catch (_) {}
  }

  @override
  void dispose() {
    _disposed = true;
    _teamsWatch?.cancel();
    _teamWatch?.cancel();
    super.dispose();
  }
}

