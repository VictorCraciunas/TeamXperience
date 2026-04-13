import {onRequest} from "firebase-functions/v2/https";
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

