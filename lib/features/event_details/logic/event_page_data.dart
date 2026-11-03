import 'package:teamxperience/model/team.dart';

/// What the event page shows besides the event itself.
class EventPageData {
  const EventPageData({
    this.team,
    required this.teamsCount,
    required this.organiserEventsCount,
    this.isAdmin = false,
  });

  /// The player's team for this event, or null.
  final Team? team;
  final int teamsCount;
  final int organiserEventsCount;
  final bool isAdmin;
}
