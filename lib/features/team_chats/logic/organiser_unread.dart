import 'package:teamxperience/enums/photo_approval_status.dart';
import 'package:teamxperience/model/team.dart';

/// The team's puzzle photos waiting for the organiser's decision.
Iterable<MapEntry<String, PhotoApprovalStatus>> pendingPhotos(Team team) =>
    team.photoApprovals.entries.where((e) => e.value == PhotoApprovalStatus.pending);

/// What the organiser has to look at in a team's chat: the messages they
/// have not read (at least one with an unread text, none without one) plus
/// the photos waiting for a decision. The conversations list's red count and
/// the event sheet's Conversații badge both read this.
int organiserUnread(Team team) {
  final count = team.unreadCount;
  final messages = team.unreadText == null ? 0 : (count < 1 ? 1 : count);
  return messages + pendingPhotos(team).length;
}

/// Whether the team's chat waits for the organiser.
bool needsOrganiser(Team team) => organiserUnread(team) > 0;
