import 'package:teamxperience/backend/repo/season_repo.dart';
import 'package:teamxperience/model/season_standing.dart';
import 'package:teamxperience/backend/functions/team_functions.dart';
import 'package:teamxperience/backend/repo/crew_repo.dart';
import 'package:teamxperience/backend/repo/teamRepo.dart';
import 'package:teamxperience/backend/repo/user_repo.dart';
import 'package:teamxperience/enums/photo_approval_status.dart';
import 'package:teamxperience/model/crew.dart';
import 'package:teamxperience/enums/team_photo_slot.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/service/team_service/invite_preview.dart';
import 'package:teamxperience/service/team_service/register_result.dart';
import 'package:teamxperience/service/team_service/team_errors.dart';
import 'package:teamxperience/utils/invite_code.dart';

class TeamService {
  TeamService({TeamFunctions? functions, CrewRepo? crews})
    : _functions = functions ?? TeamFunctions(),
      _crews = crews ?? CrewRepo();

  TeamRepo teamRepo = TeamRepo();
  UserRepo userRepo = UserRepo();
  final TeamFunctions _functions;
  final CrewRepo _crews;

  /// Registers a team for an event. When [crewId] is given the team is made
  /// from that crew; otherwise a new crew is made. Throws
  /// `FirebaseFunctionsException`; read it with `TeamError.fromException`.
  Future<RegisterResult> registerTeam({
    required String eventId,
    required String name,
    required int size,
    required String phone,
    required bool rulesAccepted,
    required bool photoConsent,
    String? crewId,
  }) async {
    final data = await _functions.registerTeam(
      eventId: eventId,
      name: name,
      size: size,
      phone: phone,
      rulesAccepted: rulesAccepted,
      photoConsent: photoConsent,
      crewId: crewId,
    );
    return RegisterResult.fromMap(data);
  }

  /// Whether no other team of the event has this name. Null when the check
  /// could not reach the server.
  Future<bool?> isTeamNameFree(String eventId, String name) async {
    try {
      final data = await _functions.checkTeamName(eventId: eventId, name: name);
      return data['free'] as bool? ?? false;
    } catch (e) {
      if (TeamError.fromException(e) == TeamError.network) return null;
      rethrow;
    }
  }

  Future<InvitePreview> previewInvite(String code) async {
    final data = await _functions.previewInvite(code: normaliseCode(code));
    return InvitePreview.fromMap(data);
  }

  /// Joins the crew behind [code]. Returns the ids of the events whose team
  /// the player entered.
  Future<List<String>> joinTeam(String code) async {
    final data = await _functions.joinTeam(code: normaliseCode(code));
    final eventIds = data['eventIds'] as List<dynamic>? ?? [];
    return eventIds.map((id) => id.toString()).toList();
  }

  Future<({String crewId, String inviteCode})> createCrew(String name) async {
    final data = await _functions.createCrew(name: name);
    return (
      crewId: data['crewId'] as String? ?? '',
      inviteCode: data['inviteCode'] as String? ?? '',
    );
  }

  Stream<List<Crew>> streamUserCrews(String uid) => _crews.streamUserCrews(uid);

  /// The invite code of a crew the player is in.
  Future<String?> crewInviteCode(String crewId) => _crews.inviteCode(crewId);

  /// A season's top crews, most points first.
  Stream<List<SeasonStanding>> streamStandings(String seasonId) => SeasonRepo().streamStandings(seasonId);

  Future<Team?> getUserTeamForEvent(String eventId, String userId) async {
    return teamRepo.getUserTeamForEvent(eventId, userId);
  }

  Future<void> updateMissionProgress(
    String eventId,
    String teamName,
    int progress, {
    int? completedMission,
  }) async {
    return teamRepo.updateMissionProgress(eventId, teamName, progress, completedMission: completedMission);
  }

  /// Marks the player as seen playing now; the live Home counts who is here.
  Future<void> markPresent(String eventId, String teamName, String uid) {
    return teamRepo.markPresent(eventId, teamName, uid);
  }

  /// One wrong answer on puzzle [key] (`Team.puzzleKey`), as an increment.
  Future<void> addWrongAttempt(String eventId, String teamName, String key) {
    return teamRepo.addWrongAttempt(eventId, teamName, key);
  }

  /// Pauses answers on puzzle [key] until [until]; its count starts over.
  Future<void> lockPuzzle(String eventId, String teamName, String key, DateTime until) {
    return teamRepo.lockPuzzle(eventId, teamName, key, until);
  }

  Future<void> markHintUsed(String eventId, String teamName, String key) {
    return teamRepo.markHintUsed(eventId, teamName, key);
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

  /// Marks the team finished; [completed] when its last mission was solved
  /// (stamps `finishedAt` once).
  Future<void> finishTeam(String eventId, String teamName, {required bool completed}) async {
    return teamRepo.finishTeam(eventId, teamName, completed: completed);
  }

  Future<void> addWalked(String eventId, String teamName, String uid, double meters) {
    return teamRepo.addWalked(eventId, teamName, uid, meters);
  }

  Future<void> saveRating(String eventId, String uid, {required String teamName, required int rating}) {
    return teamRepo.saveRating(eventId, uid, teamName: teamName, rating: rating);
  }

  /// The teams for a screen that lists them; throws when they cannot be read,
  /// also offline with nothing cached.
  Future<List<Team>> getTeamsOrFail(String eventId) => teamRepo.getTeamsOrFail(eventId);

  Future<List<Team>> getTeams(String eventId) async {
    return teamRepo.getAllTeamsForEvent(eventId);
  }

  /// How many teams are registered for [eventId].
  Future<int> countTeams(String eventId) => teamRepo.countTeams(eventId);

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

  /// The organiser has read the team's messages.
  Future<void> clearUnread(String eventId, String teamName) => teamRepo.clearUnread(eventId, teamName);

  /// Sets one photo try's status, with the organiser's [reason] for a
  /// rejection and the picture's [url] when it is sent; the time is the
  /// server's.
  Future<void> setPhotoApproval(
    String eventId,
    String teamName,
    String key,
    PhotoApprovalStatus status, {
    String? reason,
    String? url,
  }) async {
    return teamRepo.setPhotoApproval(eventId, teamName, key, status, reason: reason, url: url);
  }

  /// Saves the team's start or final photo; a retake replaces it.
  Future<void> setTeamPhoto(String eventId, String teamName, TeamPhotoSlot slot, String url, String uid) {
    return teamRepo.setTeamPhoto(eventId, teamName, slot, url, uid);
  }

  /// Changes the captain's phone on the team, and nothing else.
  Future<void> updateTeamPhone(
    String eventId,
    String teamName,
    String phone,
  ) async {
    await teamRepo.updateTeamPhone(eventId, teamName, phone);
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
