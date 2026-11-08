import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/service/team_service/team_service.dart';

class TeamChatsController{
  late Event event;
  List<Team> teams = [];
  bool isLoading = true;

  /// The teams could not be read.
  bool failed = false;
  final Future<List<Team>> Function(String eventId)? _load;

  TeamChatsController({required this.event, Future<List<Team>> Function(String eventId)? load}) : _load = load;

  Future<void> loadTeams() async {
    isLoading = true;
    failed = false;
    try {
      teams = await (_load ?? TeamService().getTeamsOrFail)(event.eventId);
    } catch (_) {
      failed = true;
    }
    isLoading = false;
  }

}