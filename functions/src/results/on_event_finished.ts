import {getFirestore} from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import {onDocumentUpdated} from "firebase-functions/v2/firestore";
import {onSchedule} from "firebase-functions/v2/scheduler";
import {applyResults, expiredEventIds} from "./apply_results";

/** A big event takes a while, and a stop that is cut off has no retry of its own. */
const TIMEOUT = 540;

/** "Oprește": the results right away. */
export const onEventStopped = onDocumentUpdated({document: "events/{eventId}", timeoutSeconds: TIMEOUT}, async (event) => {
  const before = event.data?.before.data();
  const after = event.data?.after.data();
  if (before?.isStopped === true || after?.isStopped !== true) return;
  await applyResults(getFirestore(), event.params.eventId);
});

/** Events nobody stopped: the results once their three hours ran out. */
export const closeExpiredEvents = onSchedule({schedule: "every 15 minutes", timeoutSeconds: TIMEOUT}, async () => {
  const db = getFirestore();
  for (const eventId of await expiredEventIds(db, new Date())) {
    try {
      await applyResults(db, eventId);
    } catch (error) {
      // The next run tries again; one bad event must not hold up the others.
      logger.error("Could not work out the results", {eventId, error: String(error)});
    }
  }
});
