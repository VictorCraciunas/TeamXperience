import 'package:cloud_firestore/cloud_firestore.dart';

/// One finished game in a player's "Amintiri" (`users/{uid}/memories/{eventId}`),
/// written by the end-of-event function (step 7c).
class Memory {
  const Memory({
    required this.eventId,
    required this.eventName,
    this.date,
    this.place,
    this.totalMinutes,
    this.photoUrls = const [],
  });

  final String eventId;
  final String eventName;
  final DateTime? date;

  /// The team's place (1 = winner); null when unknown.
  final int? place;

  /// How long the team played, in whole minutes.
  final int? totalMinutes;
  final List<String> photoUrls;

  static int? _whole(Object? value) => value is num && value == value.roundToDouble() ? value.toInt() : null;

  factory Memory.fromMap(String eventId, Map<String, dynamic> map) {
    final date = map['date'];
    final photos = map['photoUrls'];
    final name = map['eventName'];
    return Memory(
      eventId: eventId,
      eventName: name is String ? name : '',
      date: switch (date) {
        Timestamp() => date.toDate(),
        DateTime() => date,
        _ => null,
      },
      place: _whole(map['place']),
      totalMinutes: _whole(map['totalTime']),
      photoUrls: photos is List ? [for (final url in photos) if (url is String) url] : const [],
    );
  }
}
