import 'package:cloud_firestore/cloud_firestore.dart';

/// What a notification is about: its icon and where a tap goes.
enum NotificationKind { announcement, chat, team, results, other }

/// One entry in a player's list (`users/{uid}/notifications/{id}`), written by
/// the Cloud Functions; the player can only mark it read.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    this.createdAt,
    required this.read,
    this.eventId,
    this.teamName,
  });

  final String id;
  final NotificationKind kind;
  final String title;
  final String body;
  final DateTime? createdAt;
  final bool read;
  final String? eventId;
  final String? teamName;

  static String _text(Object? value) => value is String ? value : '';

  static String? _id(Object? value) => value is String && value.isNotEmpty ? value : null;

  /// Whatever old, new or bad data it holds: an unknown kind is [NotificationKind.other],
  /// and a missing `read` counts as read, so it never shows a dot it can't clear.
  factory AppNotification.fromMap(String id, Map<String, dynamic> map) {
    final kind = map['kind'];
    final at = map['createdAt'];
    return AppNotification(
      id: id,
      kind: NotificationKind.values.firstWhere((k) => k.name == kind && k != NotificationKind.other, orElse: () => NotificationKind.other),
      title: _text(map['title']),
      body: _text(map['body']),
      createdAt: switch (at) {
        Timestamp() => at.toDate(),
        DateTime() => at,
        _ => null,
      },
      read: map['read'] != false,
      eventId: _id(map['eventId']),
      teamName: _id(map['teamName']),
    );
  }
}
