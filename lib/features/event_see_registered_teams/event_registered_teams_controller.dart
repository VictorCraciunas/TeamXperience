import 'package:flutter/foundation.dart';
import 'package:teamxperience/features/live_room/controller/live_room_controller.dart' show CallResult, phoneUri;
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/service/team_service/team_service.dart';
import 'package:url_launcher/url_launcher.dart';

import 'logic/team_search.dart';
import 'logic/team_stats.dart';

/// The organiser's list of an event's teams: loading them, the search, the
/// one open card, removing a team and calling its captain. Dialogs,
/// snackbars and navigation stay in the screen.
class EventRegisteredTeamsController extends ChangeNotifier {
  EventRegisteredTeamsController(
    this.event, {
    Future<List<Team>> Function(String eventId)? load,
    Future<void> Function(String eventId, Team team)? delete,
    Future<bool> Function(Uri uri)? openPhone,
  })  : _load = load,
        _delete = delete,
        _openPhone = openPhone ?? launchUrl;

  final Event event;
  late final TeamService _teamService = TeamService();
  final Future<List<Team>> Function(String eventId)? _load;
  final Future<void> Function(String eventId, Team team)? _delete;
  final Future<bool> Function(Uri uri) _openPhone;

  List<Team> teams = [];
  bool isLoading = true;

  /// The teams could not be read.
  bool failed = false;

  /// What the organiser typed in "Caută echipa sau jucătorul".
  String search = '';

  /// The name of the open card; null when all are closed.
  String? _expanded;

  Future<void> loadTeams() async {
    isLoading = true;
    failed = false;
    notifyListeners();
    try {
      teams = await (_load ?? _teamService.getTeamsOrFail)(event.eventId);
    } catch (_) {
      failed = true;
    }
    isLoading = false;
    notifyListeners();
  }

  /// The teams the search finds, in the order they were read.
  List<Team> get visibleTeams => teams.where((t) => matchesSearch(t, search)).toList();

  /// Counted over every team, not only the ones the search shows.
  TeamStats get stats => teamStats(teams);

  void setSearch(String text) {
    if (text == search) return;
    search = text;
    notifyListeners();
  }

  bool isExpanded(Team team) => _expanded == team.name;

  /// Opens [team]'s card and closes any other; closes it when it is open.
  void toggle(Team team) {
    _expanded = isExpanded(team) ? null : team.name;
    notifyListeners();
  }

  /// Throws when the team could not be removed; the list stays as it was.
  Future<void> deleteTeam(Team team) async {
    await (_delete ?? _teamService.deleteTeam)(event.eventId, team);
    teams.removeWhere((t) => t.name == team.name);
    if (isExpanded(team)) _expanded = null;
    notifyListeners();
  }

  bool canCall(Team team) => phoneUri(team.phoneNumber) != null;

  /// Opens the phone on the number of [team]'s captain.
  Future<CallResult> callCaptain(Team team) async {
    final uri = phoneUri(team.phoneNumber);
    if (uri == null) return CallResult.noPhone;
    try {
      return await _openPhone(uri) ? CallResult.opened : CallResult.failed;
    } catch (_) {
      return CallResult.failed;
    }
  }
}
