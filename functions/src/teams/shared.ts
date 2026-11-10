import {DocumentData, Firestore, Timestamp} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";

export type Reason =
  | "notSignedIn"
  | "eventNotFound"
  | "enrolmentClosed"
  | "eventFull"
  | "nameTaken"
  | "nameInvalid"
  | "sizeInvalid"
  | "alreadyInTeam"
  | "crewAlreadyRegistered"
  | "notCaptain"
  | "codeUnknown"
  | "teamFull"
  | "alreadyMember"
  | "rulesNotAccepted"
  | "notOrganiser"
  | "notificationInvalid"
  | "noRecipients"
  | "teamNotFound"
  | "gameStarted";

/** The error the app maps to text; `extra` carries e.g. the team's name. */
export function refuse(reason: Reason, extra: Record<string, unknown> = {}): HttpsError {
  const code = reason === "notSignedIn" ? "unauthenticated"
    : reason === "notOrganiser" ? "permission-denied"
    : "failed-precondition";
  return new HttpsError(code, reason, {reason, ...extra});
}

export interface Member {
  uid: string;
  displayName: string;
  initials: string;
}

/** What is known about a user from their document. */
export function memberOf(uid: string, user: DocumentData | undefined): Member {
  const first = String(user?.firstName ?? "").trim();
  const last = String(user?.lastName ?? "").trim();
  const initial = (word: string) => (word ? Array.from(word)[0].toUpperCase() : "");
  return {
    uid,
    displayName: `${first} ${last}`.trim(),
    initials: `${initial(first)}${initial(last)}`,
  };
}

/** How long a game lasts when the event has no duration (older events). */
export const DEFAULT_PLAY_MS = 3 * 60 * 60 * 1000;

/** How long the game lasts: the event's duration in minutes, else three hours. */
export function playTimeMs(event: DocumentData | undefined): number {
  const minutes = event?.durationMinutes;
  return typeof minutes === "number" && minutes > 0 ? minutes * 60000 : DEFAULT_PLAY_MS;
}

export function toDate(value: unknown): Date | null {
  return value instanceof Timestamp ? value.toDate() : null;
}

/** Stopped, or its duration has passed since the start. */
export function eventIsOver(event: DocumentData, now: Date): boolean {
  if (event.isStopped === true) return true;
  const start = toDate(event.dateEvent);
  return start !== null && now.getTime() > start.getTime() + playTimeMs(event);
}

/** Hour, minute and second of [date] in Romania, whatever the server's zone. */
const MONTHS = ["ian", "feb", "mar", "apr", "mai", "iun", "iul", "aug", "sep", "oct", "nov", "dec"];

/** "14 nov": the day in Romania. */
export function shortDate(date: Date): string {
  const {day, month} = bucharestTime(date);
  return `${day} ${MONTHS[month - 1]}`;
}

export function bucharestTime(date: Date): {year: number; month: number; day: number; hour: number; minute: number; second: number} {
  const parts = new Intl.DateTimeFormat("en-GB", {
    timeZone: "Europe/Bucharest",
    hourCycle: "h23",
    year: "numeric",
    month: "numeric",
    day: "numeric",
    hour: "numeric",
    minute: "numeric",
    second: "numeric",
  }).formatToParts(date);
  const part = (type: string) => Number(parts.find((p) => p.type === type)?.value ?? 0);
  return {
    year: part("year"),
    month: part("month"),
    day: part("day"),
    hour: part("hour"),
    minute: part("minute"),
    second: part("second"),
  };
}

/**
 * Whether teams can sign up at [now], as `enrolment_window.dart` decides it: a
 * deadline set to midnight (a date only) lasts to the end of that day.
 */
export function enrolmentOpen(event: DocumentData, now: Date): boolean {
  const opens = toDate(event.dateStartEnrollment);
  if (opens !== null && now < opens) return false;
  const start = toDate(event.dateEvent);
  if (start !== null && now >= start) return false;
  const deadline = toDate(event.dateDeadlineEnrollment);
  if (deadline === null) return true;
  const local = bucharestTime(deadline);
  const midnight = local.hour === 0 && local.minute === 0 && local.second === 0;
  const closes = midnight ? new Date(deadline.getTime() + 24 * 60 * 60 * 1000 - 1000) : deadline;
  return now <= closes;
}

export const teamsOf = (db: Firestore, eventId: string) =>
  db.collection("events").doc(eventId).collection("teams");

/** A crew's link to one of its teams. */
export interface CrewTeam {
  eventId: string;
  teamName: string;
}

export function crewTeams(crew: DocumentData): CrewTeam[] {
  return Array.isArray(crew.teams) ? crew.teams : [];
}
