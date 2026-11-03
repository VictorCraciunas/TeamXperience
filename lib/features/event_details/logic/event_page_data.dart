import 'package:teamxperience/model/team.dart';

/// What the event page shows besides the event itself.
class EventPageData {
  const EventPageData({
    this.team,
    required this.teamsCount,
    required this.organiserEventsCount,
    this.isAdmin = false,
    this.teamLoading = false,
  });

  /// The player's team for this event, or null.
  final Team? team;
  final int teamsCount;
  final int organiserEventsCount;
  final bool isAdmin;

  /// True while a registered player's team is still being looked up.
  final bool teamLoading;
}
