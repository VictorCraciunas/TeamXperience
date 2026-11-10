import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/service/team_service/team_service.dart';

class EventRegisteredTeamsController {
  final Event event;
  late final TeamService _teamService = TeamService();
  final Future<List<Team>> Function(String eventId)? _load;

  List<Team> teams = [];
  bool isLoading = true;

  /// The teams could not be read.
  bool failed = false;

  EventRegisteredTeamsController(this.event, {Future<List<Team>> Function(String eventId)? load}) : _load = load;

  Future<void> loadTeams() async {
    isLoading = true;
    failed = false;
    try {
      teams = await (_load ?? _teamService.getTeamsOrFail)(event.eventId);
    } catch (_) {
      failed = true;
    }
    isLoading = false;
  }

  Future<void> deleteTeam(Team team) async {
    await _teamService.deleteTeam(event.eventId, team);
    teams.removeWhere((t) => t.name == team.name);
  }
}
