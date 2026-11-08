import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/service/team_service/team_service.dart';

/// Everything a puzzle screen saves about its team, in one place, so an
/// organiser's walk-through can save nothing at all.
abstract class PuzzleWrites {
  Future<void> addWrongAttempt(String key);
  Future<void> lockPuzzle(String key, DateTime until);
  Future<void> markHintUsed(String key);
  Future<void> updatePuzzleNumber(int puzzle);
  Future<void> updateMissionProgress(int progress, {int? completedMission});
  Future<void> finishTeam();

  /// The team as other phones change it.
  Stream<Team> watchTeam();
}

/// The organiser's walk-through: nothing leaves the phone.
class NoPuzzleWrites implements PuzzleWrites {
  const NoPuzzleWrites();

  @override
  Future<void> addWrongAttempt(String key) async {}
  @override
  Future<void> lockPuzzle(String key, DateTime until) async {}
  @override
  Future<void> markHintUsed(String key) async {}
  @override
  Future<void> updatePuzzleNumber(int puzzle) async {}
  @override
  Future<void> updateMissionProgress(int progress, {int? completedMission}) async {}
  @override
  Future<void> finishTeam() async {}
  @override
  Stream<Team> watchTeam() => const Stream.empty();
}

/// A real game: saved on the team's document.
class TeamPuzzleWrites implements PuzzleWrites {
  TeamPuzzleWrites(this.eventId, this.teamName) : _service = TeamService();

  final String eventId;
  final String teamName;
  final TeamService _service;

  @override
  Future<void> addWrongAttempt(String key) => _service.addWrongAttempt(eventId, teamName, key);
  @override
  Future<void> lockPuzzle(String key, DateTime until) => _service.lockPuzzle(eventId, teamName, key, until);
  @override
  Future<void> markHintUsed(String key) => _service.markHintUsed(eventId, teamName, key);
  @override
  Future<void> updatePuzzleNumber(int puzzle) => _service.updatePuzzleNumber(eventId, teamName, puzzle);
  @override
  Future<void> updateMissionProgress(int progress, {int? completedMission}) =>
      _service.updateMissionProgress(eventId, teamName, progress, completedMission: completedMission);
  @override
  Future<void> finishTeam() => _service.finishTeam(eventId, teamName, completed: true);
  @override
  Stream<Team> watchTeam() => _service.getStreamTeam(eventId, teamName);
}

/// Which writes a puzzle screen uses.
PuzzleWrites puzzleWritesFor(String eventId, String teamName, {required bool preview}) =>
    preview ? const NoPuzzleWrites() : TeamPuzzleWrites(eventId, teamName);
