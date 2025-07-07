import 'package:teamxperience/backend/repo/teamRepo.dart';
import 'package:teamxperience/backend/repo/user_repo.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/model/user.dart';

class TeamService{
  TeamRepo teamRepo = TeamRepo();
  UserRepo userRepo = UserRepo();

  Future<Team> addTeam(
      String name,
      String teamMembers,
      String captainName,
      String phoneNumber,
      String captainEmail,
      AppUser user,
      Event event
      ) async {
    List<String> users = [user.uid];
    Team team = Team(
        name: name,
        teamMembers: teamMembers,
        captainName: captainName,
        phoneNumber: phoneNumber,
        captainEmail: captainEmail,
        userIds: users
    );
    await teamRepo.addTeam(team, event.eventId);
    await userRepo.addEventToUser(user.uid, event.eventId);

    return team;
  }
}