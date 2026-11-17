import 'package:teamxperience/enums/message_type.dart';
import 'package:teamxperience/enums/photo_approval_status.dart';
import 'package:teamxperience/enums/role.dart';
import 'package:teamxperience/model/message.dart';
import 'package:teamxperience/model/team.dart';

import 'bubble_position.dart';
import 'chat_texts.dart';

/// One message as read from the chat, with its document id.
class ChatMessageDoc {
  const ChatMessageDoc(this.id, this.message);

  final String id;
  final Message message;
}

/// The round picture beside a message from someone else: a player's
/// initials, or the organiser's "TX".
class ChatAvatar {
  const ChatAvatar.initials(String this.initials);
  const ChatAvatar.organiser() : initials = null;

  /// Null for the organiser.
  final String? initials;

  bool get isOrganiser => initials == null;

  @override
  bool operator ==(Object other) => other is ChatAvatar && other.initials == initials;

  @override
  int get hashCode => initials.hashCode;

  @override
  String toString() => 'ChatAvatar(${initials ?? 'TX'})';
}

/// One line of the chat, in order from the oldest.
sealed class ChatEntry {
  const ChatEntry(this.key);

  /// Unique in the chat (the widget's key).
  final String key;
}

/// "Astăzi", "Ieri", "14 nov 2026".
class ChatDayEntry extends ChatEntry {
  const ChatDayEntry(this.label) : super('day-$label');

  final String label;
}

/// "Au rezolvat misiunea 3 · 10:40" (organiser) / "Ați rezolvat…" (player).
class ChatGameEventEntry extends ChatEntry {
  const ChatGameEventEntry(super.key, this.text);

  final String text;
}

/// The organiser's "Anunț", sent to every team.
class ChatAnnouncementEntry extends ChatEntry {
  const ChatAnnouncementEntry(super.key, {required this.title, required this.text});

  /// "Anunț pentru toate echipele · 10:30".
  final String title;
  final String text;
}

/// A text bubble. In a run from one sender the [name] is on the first, the
/// [avatar] and [footer] on the last.
class ChatTextEntry extends ChatEntry {
  const ChatTextEntry(
    super.key, {
    required this.text,
    required this.mine,
    required this.position,
    this.name,
    this.avatar,
    this.footer,
  });

  final String text;

  /// On the right, in the accent colour.
  final bool mine;
  final BubblePosition position;

  /// Above the bubble ("Ana · căpitan", "Organizator"); null when not shown.
  final String? name;

  /// Beside the bubble; null when not shown (a left bubble keeps its place).
  final ChatAvatar? avatar;

  /// Under the bubble ("10:48", "Tu · 10:46"); null when not shown.
  final String? footer;
}

/// A picture in a bubble: a player's view of a photo puzzle (with its
/// status pill), a chat photo, or the organiser's own.
class ChatPhotoEntry extends ChatEntry {
  const ChatPhotoEntry(
    super.key, {
    required this.imageUrl,
    required this.mine,
    required this.line,
    this.name,
    this.avatar,
    this.status,
    this.reason,
  });

  final String imageUrl;
  final bool mine;

  /// Under the picture: "Misiunea 3 · 10:53", or the time.
  final String line;
  final String? name;
  final ChatAvatar? avatar;

  /// A photo puzzle's state; null for a chat photo.
  final PhotoApprovalStatus? status;

  /// The organiser's reason, for a rejected photo.
  final String? reason;

  String? get statusLabel {
    final s = status;
    return s == null ? null : photoStatusLabel(s);
  }
}

/// The organiser's card for a team's photo puzzle: who sent it, where, its
/// state and, while it waits, Respinge / Aprobă.
class ChatPhotoReviewEntry extends ChatEntry {
  const ChatPhotoReviewEntry(
    super.key, {
    required this.imageUrl,
    required this.approvalKey,
    required this.title,
    required this.line,
    required this.initials,
    this.status,
    this.reason,
  });

  final String imageUrl;
  final String approvalKey;

  /// "Mihai a trimis poza".
  final String title;

  /// "Misiunea 3 · Puzzle 2 · 10:52".
  final String line;
  final String initials;

  /// Null while the team's document has not said yet.
  final PhotoApprovalStatus? status;
  final String? reason;

  bool get canDecide => status == PhotoApprovalStatus.pending;

  String? get statusLabel {
    final s = status;
    return s == null ? null : photoStatusLabel(s);
  }
}

const _months = ['ian', 'feb', 'mar', 'apr', 'mai', 'iun', 'iul', 'aug', 'sep', 'oct', 'nov', 'dec'];

/// "Astăzi", "Ieri", else "14 nov 2026".
String chatDayLabel(DateTime date, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(date.year, date.month, date.day);
  final diff = today.difference(day).inHours ~/ 24;
  if (diff == 0) return 'Astăzi';
  if (diff == 1) return 'Ieri';
  return '${date.day} ${_months[date.month - 1]} ${date.year}';
}

/// A message or a solved mission, before they become entries.
class _Item {
  _Item.message(ChatMessageDoc this.doc)
      : at = doc.message.timestamp,
        mission = null;
  _Item.mission(int this.mission, this.at) : doc = null;

  final ChatMessageDoc? doc;
  final int? mission;
  final DateTime at;
}

/// The chat as lines: the [messages] (oldest first) and the team's solved
/// missions merged by time, a day line wherever the day changes, and runs of
/// text from one sender grouped. [organiserView] is the organiser's chat
/// (their messages on the right); otherwise the player [myUid]'s.
List<ChatEntry> chatTimeline({
  required List<ChatMessageDoc> messages,
  required Team team,
  required bool organiserView,
  required String myUid,
  required DateTime now,
}) {
  final items = <_Item>[
    for (final doc in messages) _Item.message(doc),
    for (final solved in team.missionCompletedAt.entries) _Item.mission(solved.key, solved.value),
  ];
  // Stable: two things at the same time keep the order they came in.
  final indexed = items.asMap().entries.toList()
    ..sort((a, b) {
      final byTime = a.value.at.compareTo(b.value.at);
      return byTime != 0 ? byTime : a.key.compareTo(b.key);
    });
  final ordered = [for (final e in indexed) e.value];

  bool isMine(Message m) {
    if (organiserView) return m.sender == Role.ADMIN;
    final uid = m.senderUid;
    return m.sender == Role.USER && uid != null && uid == myUid;
  }

  ChatAvatar avatarOf(Message m) =>
      m.sender == Role.ADMIN ? const ChatAvatar.organiser() : ChatAvatar.initials(senderInitials(m, team));

  String authorOf(Message m) => isMine(m) ? 'me' : (m.sender == Role.ADMIN ? 'admin' : 'u:${m.senderUid ?? ''}');

  bool isText(_Item item) {
    final m = item.doc?.message;
    return m != null && !m.announcement && m.type != MessageType.image;
  }

  final entries = <ChatEntry>[];
  String? lastDay;
  for (var i = 0; i < ordered.length; i++) {
    final item = ordered[i];
    final day = chatDayLabel(item.at, now);
    if (day != lastDay) {
      entries.add(ChatDayEntry(day));
      lastDay = day;
    }
    final time = clockTime(item.at);

    final mission = item.mission;
    final doc = item.doc;
    if (mission != null || doc == null) {
      final verb = organiserView ? 'Au rezolvat' : 'Ați rezolvat';
      entries.add(ChatGameEventEntry('mission-$mission', '$verb misiunea ${(mission ?? 0) + 1} · $time'));
      continue;
    }

    final m = doc.message;
    final mine = isMine(m);
    if (m.announcement) {
      entries.add(ChatAnnouncementEntry(doc.id, title: 'Anunț pentru toate echipele · $time', text: m.text));
      continue;
    }

    if (m.type == MessageType.image) {
      final key = m.approvalKey;
      final status = key == null ? null : team.photoApprovals[key];
      final rawReason = key == null ? null : team.photoDetails[key]?.reason?.trim();
      final reason = rawReason == null || rawReason.isEmpty ? null : rawReason;
      final place = photoPlace(key);
      if (organiserView && key != null && m.sender == Role.USER) {
        final who = m.senderName?.trim() ?? '';
        entries.add(ChatPhotoReviewEntry(
          doc.id,
          imageUrl: m.imageUrl ?? '',
          approvalKey: key,
          title: '${who.isEmpty ? unsignedSender : who} a trimis poza',
          line: place == null ? time : 'Misiunea ${place.mission} · Puzzle ${place.puzzle} · $time',
          initials: senderInitials(m, team),
          status: status,
          reason: reason,
        ));
        continue;
      }
      entries.add(ChatPhotoEntry(
        doc.id,
        imageUrl: m.imageUrl ?? '',
        mine: mine,
        line: place == null || key == null ? time : 'Misiunea ${place.mission} · $time',
        name: mine ? null : senderLabel(m, team, organiserView: organiserView),
        avatar: mine ? null : avatarOf(m),
        status: status,
        reason: status == PhotoApprovalStatus.denied ? reason : null,
      ));
      continue;
    }

    // A text: grouped with the texts of the same sender right around it.
    bool sameRun(int j) {
      if (j < 0 || j >= ordered.length) return false;
      final other = ordered[j];
      final om = other.doc?.message;
      return om != null &&
          isText(other) &&
          authorOf(om) == authorOf(m) &&
          chatDayLabel(other.at, now) == day;
    }

    final joinsPrevious = sameRun(i - 1);
    final joinsNext = sameRun(i + 1);
    final position = switch ((joinsPrevious, joinsNext)) {
      (false, false) => BubblePosition.single,
      (false, true) => BubblePosition.first,
      (true, true) => BubblePosition.middle,
      (true, false) => BubblePosition.last,
    };
    entries.add(ChatTextEntry(
      doc.id,
      text: m.text,
      mine: mine,
      position: position,
      name: mine || joinsPrevious ? null : senderLabel(m, team, organiserView: organiserView),
      avatar: mine || joinsNext ? null : avatarOf(m),
      footer: joinsNext ? null : (mine && !organiserView ? 'Tu · $time' : time),
    ));
  }
  return entries;
}
