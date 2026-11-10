import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/puzzle.dart';
import 'package:teamxperience/model/team.dart';

/// How long a puzzle refuses answers once its attempts ran out.
const Duration puzzleLock = Duration(seconds: 60);

/// The line players read after a wrong answer when the organiser wrote none.
const String defaultWrongLine = 'Nu e corect. Mai încearcă.';

/// Attempts the team still has on puzzle [key]; null when the puzzle has no
/// limit.
int? attemptsLeft(Puzzle puzzle, Team team, String key) {
  final max = puzzle.maxAttempts;
  if (max == null) return null;
  final left = max - (team.attempts[key] ?? 0);
  return left < 0 ? 0 : left;
}

/// How long puzzle [key] still refuses answers; null when it does not.
Duration? lockLeft(Team team, String key, DateTime now) {
  final until = team.lockedUntil[key];
  if (until == null || !until.isAfter(now)) return null;
  return until.difference(now);
}

/// Whether the team may open the hint of puzzle [puzzleIndex] in mission
/// [mission]: the puzzle has one, and the mission's hints
/// ([Event.hintsPerMission]) are not used up on other puzzles. Re-opening a
/// hint already opened is free.
bool hintAvailable(Event event, Puzzle puzzle, Team team, int mission, int puzzleIndex) {
  if ((puzzle.indiciu ?? '').trim().isEmpty) return false;
  if (event.hintsPerMission <= 0) return false;
  if (team.hintsUsed[Team.puzzleKey(mission, puzzleIndex)] == true) return true;
  final prefix = '${mission}_';
  final used = team.hintsUsed.entries.where((e) => e.value && e.key.startsWith(prefix)).length;
  return used < event.hintsPerMission;
}

/// The organiser's line for a wrong answer, or the default one.
String wrongLine(Puzzle puzzle) {
  final line = puzzle.wrongAnswerMessage?.trim() ?? '';
  return line.isEmpty ? defaultWrongLine : line;
}

/// "Mai încercați în 0:45" (seconds rounded up).
String lockLine(Duration left) {
  final seconds = (left.inMilliseconds / 1000).ceil();
  final rest = (seconds % 60).toString().padLeft(2, '0');
  return 'Mai încercați în ${seconds ~/ 60}:$rest';
}
