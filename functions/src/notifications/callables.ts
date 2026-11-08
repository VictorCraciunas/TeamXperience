import {getFirestore} from "firebase-admin/firestore";
import {onCall} from "firebase-functions/v2/https";
import {callerOf} from "../teams/callables";
import {sendNotification as sendNotificationHandler} from "./send_notification";

export const sendNotification = onCall((request) =>
  sendNotificationHandler(getFirestore(), callerOf(request), request.data ?? {}));
