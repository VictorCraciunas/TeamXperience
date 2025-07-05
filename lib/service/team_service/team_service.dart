import 'package:firebase_auth/firebase_auth.dart';
import 'package:teamxperience/backend/repo/teamRepo.dart';
import 'package:teamxperience/backend/repo/user_repo.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/model/user.dart';

class TeamService{
  TeamRepo teamRepo = TeamRepo();
  UserRepo userRepo = UserRepo();

  Team addTeam(String name, String teamMembers, String captainName, String phoneNumber, String captainEmail, AppUser user, Event event){
    List<String> users = [user.uid];
    Team team = Team(name: name, teamMembers: teamMembers, captainName: captainName, phoneNumber: phoneNumber, captainEmail: captainEmail, userIds: users);
    teamRepo.addTeam(team,event.eventId);
    userRepo.addEventToUser(user.uid, event.eventId);
    return team;
  }
}