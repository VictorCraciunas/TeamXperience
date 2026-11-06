import 'dart:math' as math;

/// What to write when this phone solves mission [missionIndex] while the team
/// doc says [storedProgress] missions are solved: the progress never goes
/// back, and the mission is stamped as solved only by the first phone.
({int progress, int? stamp}) solvedMission(int missionIndex, int storedProgress) => (
      progress: math.max(storedProgress, missionIndex + 1),
      stamp: storedProgress <= missionIndex ? missionIndex : null,
    );

/// The team's progress as this phone should hold it after a fresh copy of
/// the team doc: the furthest of the two, comparing the mission first and
/// the puzzle only within the same mission (a new mission starts at 0).
({int mission, int puzzle}) mergeProgress({
  required int mission,
  required int puzzle,
  required int freshMission,
  required int freshPuzzle,
}) {
  if (freshMission > mission) return (mission: freshMission, puzzle: freshPuzzle);
  if (freshMission < mission) return (mission: mission, puzzle: puzzle);
  return (mission: mission, puzzle: math.max(puzzle, freshPuzzle));
}

/// The puzzle number to write after puzzle [selected]: on the team's current
/// mission never below [storedPuzzleNumber] (a teammate may be further on).
int nextPuzzleNumber(int selected, int storedPuzzleNumber, {required bool sameMission}) =>
    sameMission ? math.max(selected + 1, storedPuzzleNumber) : selected + 1;
