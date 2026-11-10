/** "Anunț" sends its own push, so its chat copies must not send another; a
 * message moved with a renamed team was pushed when first sent. */
export function sendsPush(message: {announcement?: unknown; moved?: unknown}): boolean {
  return message.announcement !== true && message.moved !== true;
}
