import {onDocumentCreated, onDocumentWritten} from "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";
import {initializeApp, getApps} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";
import {sendChatPush} from "./chat/chat_push";
import {claimTokens} from "./notifications/tokens";

// Initialize Firebase Admin SDK (only once)
if (getApps().length === 0) {
  initializeApp();
}

export {checkTeamName, createCrew, joinTeam, previewInvite, registerTeam, renameTeam} from "./teams/callables";
export {closeExpiredEvents, onEventStopped} from "./results/on_event_finished";
export {sendNotification} from "./notifications/callables";

// Send notification when a new chat message is created
export const onChatMessage = onDocumentCreated(
  "events/{eventId}/teams/{teamName}/messages/{messageId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      logger.warn("No data in chat message event");
      return;
    }
    const {eventId, teamName} = event.params;
    try {
      await sendChatPush(getFirestore(), eventId, teamName, snapshot.data());
    } catch (error) {
      logger.error("Error sending chat notification", {eventId, teamName, error: String(error)});
    }
  }
);

// A device's token saved on a user comes off any other account that still has
// it (the phone's previous account), so it only gets this user's pushes.
export const onUserTokens = onDocumentWritten("users/{uid}", async (event) => {
  try {
    await claimTokens(getFirestore(), event.params.uid, event.data?.before.data(), event.data?.after.data());
  } catch (error) {
    logger.warn("Could not claim the push tokens", {uid: event.params.uid, error: String(error)});
  }
});
