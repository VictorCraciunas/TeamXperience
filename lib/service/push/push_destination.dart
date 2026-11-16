import 'dart:convert';

/// Where tapping a push notification goes, worked out from its `data`.
sealed class PushDestination {
  const PushDestination();
}

/// The chat between the organiser and one team.
class PushChat extends PushDestination {
  const PushChat(this.eventId, this.teamName);

  final String eventId;

  /// The team's name when the push was sent; a player is found by their own
  /// team instead, since it may have been renamed since.
  final String teamName;
}

/// An event's page.
class PushEvent extends PushDestination {
  const PushEvent(this.eventId);

  final String eventId;
}

/// The page of a finished game.
class PushMemory extends PushDestination {
  const PushMemory(this.eventId);

  final String eventId;
}

/// The player's notification list.
class PushNotifications extends PushDestination {
  const PushNotifications();
}

/// Nothing to open: the app stays where it is.
class PushNowhere extends PushDestination {
  const PushNowhere();
}

String? _id(Object? value) => value is String && value.isNotEmpty ? value : null;

/// The push types: `chat_message` from the chat function, `admin_notification`
/// from an organiser's push, and the list's kinds (`announcement`, `chat`,
/// `team`, `results`) from the others. An organiser only follows chat pushes:
/// the notification list and the event pages they would open are the players'.
PushDestination pushDestination(Map<String, dynamic> data, {required bool isAdmin}) {
  final type = data['type'];
  final event = _id(data['eventId']);
  final team = _id(data['teamName']);
  final isChat = type == 'chat_message' || type == 'chat';
  if (isChat && event != null && team != null) return PushChat(event, team);
  if (isAdmin) return const PushNowhere();
  if (event == null || isChat) return const PushNotifications();
  if (type == 'results') return PushMemory(event);
  return PushEvent(event);
}

/// A push's data, as the payload of a notification the app shows itself.
String pushPayload(Map<String, dynamic> data) => jsonEncode(data);

/// The data back from [pushPayload]; empty when there is none or it is broken.
Map<String, dynamic> pushDataFromPayload(String? payload) {
  if (payload == null || payload.isEmpty) return const {};
  try {
    final decoded = jsonDecode(payload);
    return decoded is Map<String, dynamic> ? decoded : const {};
  } on FormatException {
    return const {};
  }
}
