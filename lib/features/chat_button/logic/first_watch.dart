import '../service/chat_seen_store.dart';
import 'chat_key.dart';

/// The chat's seen time on this phone. A chat watched for the first time is
/// read up to [now], so its old history does not light the button.
Future<DateTime> seenOrStart(ChatSeenStore store, ChatKey chat, DateTime now) async {
  final seen = await store.read(chat);
  if (seen != null) return seen;
  await store.write(chat, now);
  return now;
}
