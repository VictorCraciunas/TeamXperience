import {getApps, initializeApp} from "firebase-admin/app";
import {Firestore, getFirestore} from "firebase-admin/firestore";

export const PROJECT = "demo-teamxperience";

/** The admin SDK on the emulator, as the functions see it. */
export function emulatorDb(): Firestore {
  if (getApps().length === 0) initializeApp({projectId: PROJECT});
  return getFirestore();
}

/** Empties the emulator's database. */
export async function clearDb(): Promise<void> {
  const host = process.env.FIRESTORE_EMULATOR_HOST;
  if (!host) throw new Error("Run this inside emulators:exec");
  const url = `http://${host}/emulator/v1/projects/${PROJECT}/databases/(default)/documents`;
  const response = await fetch(url, {method: "DELETE"});
  if (!response.ok) throw new Error(`Could not clear the emulator: ${response.status}`);
}

/** The `reason` a callable refused with, or the failure itself. */
export function reasonOf(error: unknown): unknown {
  const details = (error as {details?: {reason?: string}}).details;
  return details?.reason ?? error;
}
