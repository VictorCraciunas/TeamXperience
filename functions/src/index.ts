import {onDocumentCreated} from "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";
import {initializeApp, getApps} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";
import {getMessaging} from "firebase-admin/messaging";
import {sendsPush} from "./chat/sends_push";
import {addToInboxes, chatInboxItem} from "./notifications/inbox";

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
    try {
      const snapshot = event.data;
      if (!snapshot) {
        logger.warn("No data in chat message event");
        return;
      }

      const messageData = snapshot.data();
      if (!sendsPush(messageData)) return;
      const {eventId, teamName} = event.params;
      const senderRole = messageData.sender; // "ADMIN" or "USER"
      const messageText = messageData.text;

      logger.info("New chat message", {
        eventId,
        teamName,
        senderRole,
        structuredData: true,
      });

      const db = getFirestore();
      const tokens: string[] = [];

      if (senderRole === "ADMIN") {
        // Admin sent the message — notify all team members
        const teamDoc = await db
          .collection("events")
          .doc(eventId)
          .collection("teams")
          .doc(teamName)
          .get();

        if (!teamDoc.exists) {
          logger.warn("Team document not found", {eventId, teamName});
          return;
        }

        const teamData = teamDoc.data();
        const userIds: string[] = teamData?.userIds ?? [];
        // Kept in each player's list, whether or not their phone gets the push.
        await addToInboxes(db, userIds, chatInboxItem(eventId, teamName, messageText));

        if (userIds.length === 0) {
          logger.info("No users in team, skipping notification");
          return;
        }

        // Fetch FCM tokens for team members
        // Firestore 'in' queries support max 30 items per batch
        for (let i = 0; i < userIds.length; i += 30) {
          const batch = userIds.slice(i, i + 30);
          const usersSnapshot = await db
            .collection("users")
            .where("uid", "in", batch)
            .get();

          usersSnapshot.forEach((doc) => {
            const fcmToken = doc.data().fcmToken;
            if (fcmToken && fcmToken.trim() !== "") {
              tokens.push(fcmToken);
            }
          });
        }
      } else {
        // User sent the message — notify all admins
        const adminsSnapshot = await db
          .collection("users")
          .where("role", "==", "ADMIN")
          .get();

        adminsSnapshot.forEach((doc) => {
          const fcmToken = doc.data().fcmToken;
          if (fcmToken && fcmToken.trim() !== "") {
            tokens.push(fcmToken);
          }
        });
      }

      if (tokens.length === 0) {
        logger.info("No valid FCM tokens found for notification");
        return;
      }

      // Send the notification
      const words = typeof messageText === "string" ? messageText : "";
      const truncatedText =
        words.length > 100
          ? words.substring(0, 100) + "..."
          : words;

      const notificationTitle =
        senderRole === "ADMIN"
          ? `Mesaj nou de la Admin`
          : `Mesaj nou de la echipa ${teamName}`;

      const multicastMessage = {
        notification: {
          title: notificationTitle,
          body: truncatedText,
        },
        data: {
          type: "chat_message",
          eventId: eventId,
          teamName: teamName,
        },
        android: {
          priority: "high" as const,
          notification: {
            channelId: "chat_notifications",
          },
        },
        tokens: tokens,
      };

      const result = await getMessaging().sendEachForMulticast(
        multicastMessage
      );

      logger.info("Chat notification sent", {
        totalTokens: tokens.length,
        successCount: result.successCount,
        failureCount: result.failureCount,
        structuredData: true,
      });
    } catch (error) {
      logger.error("Error sending chat notification", {
        error: error,
        structuredData: true,
      });
    }
  }
);

