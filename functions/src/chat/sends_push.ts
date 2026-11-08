/** "Anunț" sends its own push, so its chat copies must not send another. */
export function sendsPush(message: {announcement?: unknown}): boolean {
  return message.announcement !== true;
}
