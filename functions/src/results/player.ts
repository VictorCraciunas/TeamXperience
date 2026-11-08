import {bucharestTime, MAX_DURATION_MS} from "../teams/shared";

/** A team as the results need it, with plain dates. */
export interface TeamFacts {
  name: string;
  crewId?: string;
  userIds: string[];
  numberOfMembers: number;
  missionProgress: number;
  startedAt: Date | null;
  finishedAt: Date | null;
  /** Mission index to when it was solved. */
  missionTimes: Map<number, Date>;
  hintsUsed: number;
  /** The team's walk: the longest of its phones'. */
  walkedMeters: number;
  /** Approved pictures, in the order of their keys; a try may have no url. */
  approvedPhotos: (string | null)[];
}

export interface Stats {
  games: number;
  distanceMeters: number;
  missions: number;
  podiums: number;
}

export interface Previous {
  xp: number;
  stats: Stats;
  badges: string[];
}

export interface EventFacts {
  name: string;
  date: Date;
  missionCount: number;
}

export const XP_GAME = 100;
export const XP_MISSION = 20;
export const XP_NO_HINTS = 50;
export const XP_BADGE = 50;
const FIVE_MINUTES = 5 * 60 * 1000;
const NIGHT_FROM_HOUR = 20;

const LEVELS: [string, number][] = [["Începător", 0], ["Explorator", 500], ["Cartograf", 1000], ["Legendă", 2500]];

/** The same steps as `home_texts.dart`. */
export function levelName(xp: number): string {
  let name = LEVELS[0][0];
  for (const [level, from] of LEVELS) if (xp >= from) name = level;
  return name;
}

export function isCompleted(team: Pick<TeamFacts, "missionProgress">, missionCount: number): boolean {
  return missionCount > 0 && team.missionProgress >= missionCount;
}

export function lastMissionAt(team: Pick<TeamFacts, "missionTimes">): Date | null {
  let latest: Date | null = null;
  for (const at of team.missionTimes.values()) if (latest === null || at > latest) latest = at;
  return latest;
}

/** A mission solved within five minutes of the one before, or of the start. */
function hasFastMission(team: TeamFacts): boolean {
  const sorted = [...team.missionTimes.entries()].sort((a, b) => a[0] - b[0]);
  let previous = team.startedAt;
  for (const [, at] of sorted) {
    if (previous !== null && at.getTime() - previous.getTime() < FIVE_MINUTES) return true;
    previous = at;
  }
  return false;
}

/** The last thing the team did ended at night, in Romania. */
function endedAtNight(team: TeamFacts): boolean {
  const last = team.finishedAt ?? lastMissionAt(team);
  if (last === null) return false;
  return bucharestTime(last).hour >= NIGHT_FROM_HOUR;
}

/** Minutes played: to the finish, else the last mission, at most the game's three hours. */
function minutesPlayed(team: TeamFacts, event: EventFacts): number {
  const start = team.startedAt ?? event.date;
  const end = team.finishedAt ?? lastMissionAt(team);
  if (end === null) return 0;
  const played = Math.min(end.getTime() - start.getTime(), MAX_DURATION_MS);
  return Math.max(0, Math.round(played / 60000));
}

export interface PlayerResult {
  xp: number;
  level: string;
  stats: Stats;
  badges: string[];
  memory: {eventName: string; date: Date; place: number; totalTime: number; photoUrls: string[]};
}

/** What one game does to one player. */
export function playerResult(team: TeamFacts, place: number, event: EventFacts, previous: Previous): PlayerResult {
  const completed = isCompleted(team, event.missionCount);
  const solved = Math.min(team.missionProgress, event.missionCount);
  const noHints = completed && team.hintsUsed === 0;

  const stats: Stats = {
    games: previous.stats.games + 1,
    distanceMeters: previous.stats.distanceMeters + team.walkedMeters,
    missions: previous.stats.missions + solved,
    podiums: previous.stats.podiums + (place <= 3 ? 1 : 0),
  };

  const earned: Record<string, boolean> = {
    firstGame: completed,
    games5: stats.games >= 5,
    km10: stats.distanceMeters >= 10000,
    km50: stats.distanceMeters >= 50000,
    noHints,
    night: endedAtNight(team),
    winner: completed && place === 1,
    podium3: stats.podiums >= 3,
    photo: team.approvedPhotos.length > 0,
    fast: hasFastMission(team),
    missions50: stats.missions >= 50,
    crew: team.numberOfMembers > 0 && team.userIds.length >= team.numberOfMembers,
  };
  const fresh = Object.keys(earned).filter((id) => earned[id] && !previous.badges.includes(id));

  const xp = previous.xp +
    (completed ? XP_GAME : 0) +
    solved * XP_MISSION +
    (noHints ? XP_NO_HINTS : 0) +
    fresh.length * XP_BADGE;

  return {
    xp,
    level: levelName(xp),
    stats,
    badges: [...previous.badges, ...fresh],
    memory: {
      eventName: event.name,
      date: event.date,
      place,
      totalTime: minutesPlayed(team, event),
      photoUrls: team.approvedPhotos.filter((url): url is string => url !== null),
    },
  };
}
