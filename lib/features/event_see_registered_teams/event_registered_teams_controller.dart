import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/service/team_service/team_service.dart';

class EventRegisteredTeamsController {
  final Event event;
  final TeamService _teamService = TeamService();

  List<Team> teams = [];
  bool isLoading = true;

  EventRegisteredTeamsController(this.event);

  Future<void> loadTeams() async {
    teams = await _teamService.getTeams(event.eventId);
    isLoading = false;
  }

  Future<void> deleteTeam(Team team) async {
    await _teamService.deleteTeam(event.eventId, team);
    teams.removeWhere((t) => t.name == team.name);
  }
}
