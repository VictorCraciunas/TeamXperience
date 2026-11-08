import {isCompleted, lastMissionAt, TeamFacts} from "./player";

/** Earlier first; a missing time after a present one; 0 when equal or both missing. */
function earlierFirst(a: Date | null, b: Date | null): number {
  if (a !== null && b !== null) return a.getTime() - b.getTime();
  if (a !== null || b !== null) return a !== null ? -1 : 1;
  return 0;
}

/**
 * The same order as `lib/service/leaderboard.dart`: teams that solved every
 * mission first (the earlier finish ahead), then more missions solved, then
 * whoever solved their last mission earlier, then by name.
 */
export function rankTeams<T extends TeamFacts>(teams: T[], missionCount: number): T[] {
  return [...teams].sort((a, b) => {
    const doneA = isCompleted(a, missionCount);
    const doneB = isCompleted(b, missionCount);
    if (doneA !== doneB) return doneA ? -1 : 1;
    if (doneA) {
      const byFinish = earlierFirst(a.finishedAt ?? lastMissionAt(a), b.finishedAt ?? lastMissionAt(b));
      if (byFinish !== 0) return byFinish;
    }
    const byProgress = b.missionProgress - a.missionProgress;
    if (byProgress !== 0) return byProgress;
    const byTime = earlierFirst(lastMissionAt(a), lastMissionAt(b));
    if (byTime !== 0) return byTime;
    return a.name < b.name ? -1 : a.name > b.name ? 1 : 0;
  });
}
