import 'package:teamxperience/model/app_notification.dart';
import 'package:teamxperience/utils/event_formats.dart';

/// The rows from today, and the rest. One with no time counts as earlier.
({List<AppNotification> today, List<AppNotification> earlier}) groupNotifications(
  List<AppNotification> items,
  DateTime now,
) {
  final today = <AppNotification>[];
  final earlier = <AppNotification>[];
  for (final item in items) {
    final at = item.createdAt;
    final same = at != null && at.year == now.year && at.month == now.month && at.day == now.day;
    (same ? today : earlier).add(item);
  }
  return (today: today, earlier: earlier);
}

/// "chiar acum", "acum 10 min", "acum 1 h" today, otherwise "7 nov".
String notificationTime(DateTime? at, DateTime now) {
  if (at == null) return '';
  final sameDay = at.year == now.year && at.month == now.month && at.day == now.day;
  if (!sameDay) return dayAndMonth(at);
  final ago = now.difference(at);
  if (ago.inMinutes < 1) return 'chiar acum';
  if (ago.inMinutes < 60) return 'acum ${ago.inMinutes} min';
  return 'acum ${ago.inHours} h';
}

/// Where tapping a notification goes.
sealed class NotificationTarget {
  const NotificationTarget();
}

class OpenChat extends NotificationTarget {
  const OpenChat(this.eventId, this.teamName);

  final String eventId;
  final String teamName;
}

class OpenMemory extends NotificationTarget {
  const OpenMemory(this.eventId);

  final String eventId;
}

class OpenEvent extends NotificationTarget {
  const OpenEvent(this.eventId);

  final String eventId;
}

class OpenTeams extends NotificationTarget {
  const OpenTeams();
}

class StayHere extends NotificationTarget {
  const StayHere();
}

NotificationTarget notificationTarget(AppNotification n, {required bool Function(String eventId) eventLoaded}) {
  final event = n.eventId;
  final team = n.teamName;
  return switch (n.kind) {
    NotificationKind.chat when event != null && team != null => OpenChat(event, team),
    NotificationKind.results when event != null => OpenMemory(event),
    NotificationKind.team || NotificationKind.announcement when event != null && eventLoaded(event) => OpenEvent(event),
    NotificationKind.team when event == null => const OpenTeams(),
    _ => const StayHere(),
  };
}
