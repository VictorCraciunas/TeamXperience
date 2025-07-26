import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/service/team_service/team_service.dart';

class TeamChatsController{
  late Event event;
  late List<Team> teams;
  TeamService teamService = TeamService();

  TeamChatsController({required this.event}) {
    loadTeams();
  }

  // Async method to load teams
  Future<void> loadTeams() async {
    teams = await teamService.getTeams(event.eventId);
  }

}