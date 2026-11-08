import {getFirestore} from "firebase-admin/firestore";
import {CallableRequest, onCall} from "firebase-functions/v2/https";
import {checkTeamName as checkTeamNameHandler} from "./check_team_name";
import {createCrew as createCrewHandler} from "./create_crew";
import {joinTeam as joinTeamHandler} from "./join_team";
import {previewInvite as previewInviteHandler} from "./preview_invite";
import {registerTeam as registerTeamHandler} from "./register_team";
import {refuse} from "./shared";

/** The caller's uid; a signed-out call is refused. */
export function callerOf(request: Pick<CallableRequest, "auth">): string {
  const uid = request.auth?.uid;
  if (!uid) throw refuse("notSignedIn");
  return uid;
}

export const checkTeamName = onCall((request) =>
  checkTeamNameHandler(getFirestore(), callerOf(request), request.data ?? {}));

export const createCrew = onCall((request) =>
  createCrewHandler(getFirestore(), callerOf(request), request.data ?? {}));

export const registerTeam = onCall((request) =>
  registerTeamHandler(getFirestore(), callerOf(request), request.data ?? {}));

export const previewInvite = onCall((request) =>
  previewInviteHandler(getFirestore(), callerOf(request), request.data ?? {}));

export const joinTeam = onCall((request) =>
  joinTeamHandler(getFirestore(), callerOf(request), request.data ?? {}));
