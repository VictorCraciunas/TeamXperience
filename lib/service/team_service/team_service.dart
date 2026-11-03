import 'package:teamxperience/backend/repo/teamRepo.dart';
import 'package:teamxperience/backend/repo/user_repo.dart';
import 'package:teamxperience/enums/photo_approval_status.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/model/user.dart';

class TeamService {
  TeamRepo teamRepo = TeamRepo();
  UserRepo userRepo = UserRepo();

  Future<Team> addTeam(
    String name,
    String teamMembers,
    String captainName,
    String phoneNumber,
    String captainEmail,
    int numberOfMembers,
    AppUser user,
    Event event,
  ) async {
    List<String> users = [user.uid];
    Team team = Team(
      name: name,
      teamMembers: teamMembers,
      captainName: captainName,
      phoneNumber: phoneNumber,
      captainEmail: captainEmail,
      numberOfMembers: numberOfMembers,
      userIds: users,
    );
    await teamRepo.addTeam(team, event.eventId);
    await userRepo.addEventToUser(user.uid, event.eventId);

    return team;
  }

  Future<Team?> getUserTeamForEvent(String eventId, String userId) async {
    return teamRepo.getUserTeamForEvent(eventId, userId);
  }

  Future<void> updateMissionProgress(
    String eventId,
    String teamName,
    int progress,
  ) async {
    return teamRepo.updateMissionProgress(eventId, teamName, progress);
  }

  Future<void> updatePuzzleNumber(
    String eventId,
    String teamName,
    int puzzleNumber,
  ) async {
    return teamRepo.updatePuzzleNumber(eventId, teamName, puzzleNumber);
  }

  Future<void> startTeam(String eventId, String teamName) async {
    return teamRepo.startTeam(eventId, teamName);
  }

  Future<void> finishTeam(String eventId, String teamName) async {
    return teamRepo.finishTeam(eventId, teamName);
  }

  Future<List<Team>> getTeams(String eventId) async {
    return teamRepo.getAllTeamsForEvent(eventId);
  }

  Future<void> deleteTeam(String eventId, Team team) async {
    for (final userId in team.userIds) {
      await userRepo.removeEventFromUser(userId, eventId);
    }
    await teamRepo.deleteTeam(eventId, team.name);
  }

  Stream<List<Team>> getStreamTeams(String eventId) {
    return teamRepo.getStreamTeamsForEvent(eventId);
  }

  Stream<Team> getStreamTeam(String eventId, String teamName) {
    return teamRepo.getStreamTeam(eventId, teamName);
  }

  Future<void> setPhotoApproval(
    String eventId,
    String teamName,
    String key,
    PhotoApprovalStatus status,
  ) async {
    return teamRepo.setPhotoApproval(eventId, teamName, key, status);
  }

  Future<void> updateTeamDetails(String eventId, String oldTeamName, Team updatedTeam) async {
    await teamRepo.updateTeamDetails(eventId, oldTeamName, updatedTeam);
  }

  Future<void> updateTeamLocation(
    String eventId,
    String teamName,
    double latitude,
    double longitude,
  ) async {
    teamRepo.updateTeamLocation(eventId, teamName, latitude, longitude);
  }
}
