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
}
