import 'package:teamxperience/enums/photo_approval_status.dart';
import 'package:teamxperience/model/team.dart';

import 'live_status.dart';

/// One thing that needs the organiser now.
sealed class AttentionItem {
  const AttentionItem({required this.team, required this.at});

  final Team team;

  /// When it began; orders the queue, newest first.
  final DateTime at;
}

/// A photo waiting for a decision.
class PhotoAttention extends AttentionItem {
  const PhotoAttention({required super.team, required super.at, required this.key, this.url, required this.mission});

  /// The try's key in `Team.photoApprovals`.
  final String key;
  final String? url;

  /// 1 for the first mission.
  final int mission;
}

/// A team stuck for [minutes], or with too many wrong answers ([minutes] null).
class StuckAttention extends AttentionItem {
  const StuckAttention({required super.team, required super.at, this.minutes, required this.mission, required this.wrong});

  final int? minutes;

  /// 1 for the first mission.
  final int mission;

  /// Wrong answers on the puzzle the team is on.
  final int wrong;
}

/// A message the organiser has not read.
class MessageAttention extends AttentionItem {
  const MessageAttention({required super.team, required super.at, required this.text});

  final String text;
}

/// Everything that needs the organiser, newest first, ties by team name. A
/// time the server has not set yet counts as now.
List<AttentionItem> attentionQueue(
  List<Team> teams, {
  required int missionCount,
  required DateTime now,
  required bool eventOver,
}) {
  final items = <AttentionItem>[];
  for (final team in teams) {
    items.addAll(_photos(team, now));
    final stuck = _stuck(team, missionCount: missionCount, now: now, eventOver: eventOver);
    if (stuck != null) items.add(stuck);
    final text = team.unreadText;
    if (text != null) items.add(MessageAttention(team: team, at: team.unreadAt ?? now, text: text));
  }
  items.sort((a, b) {
    final byTime = b.at.compareTo(a.at);
    return byTime != 0 ? byTime : a.team.name.compareTo(b.team.name);
  });
  return items;
}

Iterable<PhotoAttention> _photos(Team team, DateTime now) sync* {
  for (final entry in team.photoApprovals.entries) {
    if (entry.value != PhotoApprovalStatus.pending) continue;
    final detail = team.photoDetails[entry.key];
    final mission = int.tryParse(entry.key.split('_').first) ?? team.missionProgress;
    yield PhotoAttention(team: team, at: detail?.at ?? now, key: entry.key, url: detail?.url, mission: mission + 1);
  }
}

StuckAttention? _stuck(Team team, {required int missionCount, required DateTime now, required bool eventOver}) {
  if (eventOver) return null;
  final state = liveStateOf(team, missionCount: missionCount, now: now, eventOver: eventOver);
  if (state != LiveState.playing && state != LiveState.stuck) return null;
  final wrong = wrongOnCurrent(team);
  final stuck = state == LiveState.stuck;
  if (!stuck && wrong < wrongLimit) return null;
  final last = lastActivity(team);
  return StuckAttention(
    team: team,
    at: last == null ? now : (stuck ? last.add(stuckAfter) : last),
    minutes: stuck && last != null ? now.difference(last).inMinutes : null,
    mission: team.missionProgress + 1,
    wrong: wrong,
  );
}
