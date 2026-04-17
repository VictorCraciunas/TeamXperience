import {onRequest} from "firebase-functions/v2/https";
import {onDocumentCreated} from "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";
import {initializeApp, getApps} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";
import {getMessaging} from "firebase-admin/messaging";

// Initialize Firebase Admin SDK (only once)
if (getApps().length === 0) {
  initializeApp();
}

// Simple test function to verify endpoint works
export const testEndpoint = onRequest((request, response) => {
  logger.info("Test endpoint called!", {structuredData: true});
  response.send({
    success: true,
    message: "Hello from Firebase Cloud Functions!",
    timestamp: new Date().toISOString(),
    method: request.method
  });
});

// Send notification to all users with valid FCM tokens
export const sendNotification = onRequest(async (request, response) => {
  try {
    // Only allow POST requests
    if (request.method !== 'POST') {
      response.status(405).send({
        success: false,
        error: 'Method not allowed. Use POST.'
      });
      return;
    }

    // Extract title, description and optional eventId from request body
    const { title, description, eventId } = request.body;

    // Validate required fields
    if (!title || !description) {
      response.status(400).send({
        success: false,
        error: 'Missing required fields: title and description'
      });
      return;
    }

    logger.info("Sending notification", {
      title,
      description,
      eventId: eventId ?? null,
      structuredData: true
    });

    // Get users from Firestore — scoped to event registrants if eventId is provided
    const db = getFirestore();
    const usersRef = db.collection('users');
    const usersSnapshot = eventId
      ? await usersRef.where('registeredEventIds', 'array-contains', eventId).get()
      : await usersRef.get();

    if (usersSnapshot.empty) {
      response.status(404).send({
        success: false,
        error: 'No users found in database'
      });
      return;
    }

    // Extract valid FCM tokens
    const tokens: string[] = [];
    const userCount = usersSnapshot.size;

    usersSnapshot.forEach((doc: any) => {
      const userData = doc.data();
      if (userData.fcmToken && userData.fcmToken.trim() !== '') {
        tokens.push(userData.fcmToken);
      }
    });

    if (tokens.length === 0) {
      response.status(404).send({
        success: false,
        error: 'No users with valid FCM tokens found'
      });
      return;
    }

    // Prepare the notification payload
    const message = {
      notification: {
        title: title,
        body: description,
      },
      data: {
        title: title,
        body: description,
        timestamp: new Date().toISOString(),
        type: 'admin_notification'
      }
    };

    // Send notification to all tokens
    // Note: sendEachForMulticast is better for handling individual token failures
    const multicastMessage = {
      ...message,
      tokens: tokens
    };

    const response_result = await getMessaging().sendEachForMulticast(multicastMessage);

    // Log results
    logger.info("Notification sending completed", {
      totalUsers: userCount,
      tokensFound: tokens.length,
      successCount: response_result.successCount,
      failureCount: response_result.failureCount,
      structuredData: true
    });

    // Handle failed tokens (optional: remove invalid tokens from database)
    if (response_result.failureCount > 0) {
      const failedTokens: string[] = [];
      response_result.responses.forEach((resp: any, idx: number) => {
        if (!resp.success) {
          failedTokens.push(tokens[idx]);
          logger.warn("Failed to send to token", {
            token: tokens[idx],
            error: resp.error?.message,
            structuredData: true
          });
        }
      });

      // Optionally, you can remove invalid tokens from the database here
      // This is recommended for production to keep your token list clean
    }

    // Send success response
    response.status(200).send({
      success: true,
      message: 'Notifications sent successfully',
      data: {
        totalUsers: userCount,
        validTokens: tokens.length,
        successfulSends: response_result.successCount,
        failedSends: response_result.failureCount,
        timestamp: new Date().toISOString()
      }
    });

  } catch (error) {
    logger.error("Error sending notification", {
      error: error,
      structuredData: true
    });

    response.status(500).send({
      success: false,
      error: 'Internal server error while sending notification',
      details: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

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
      const truncatedText =
        messageText.length > 100
          ? messageText.substring(0, 100) + "..."
          : messageText;

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

