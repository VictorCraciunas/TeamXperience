import 'package:teamxperience/utils/event_formats.dart';

import 'chat_row.dart';

String _two(int n) => n.toString().padLeft(2, '0');

bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

/// When a chat last moved: "acum", "acum 4 min", "10:42" today, "ieri",
/// "14 nov", or "30 dec 2025" in another year. Nothing without a time.
String chatTime(DateTime? at, DateTime now) {
  if (at == null) return '';
  final ago = now.difference(at);
  if (ago.inMinutes < 1) return 'acum';
  if (ago.inMinutes < 60 && _sameDay(at, now)) return 'acum ${ago.inMinutes} min';
  if (_sameDay(at, now)) return '${_two(at.hour)}:${_two(at.minute)}';
  if (_sameDay(at, DateTime(now.year, now.month, now.day - 1))) return 'ieri';
  if (at.year == now.year) return dayAndMonth(at);
  return '${dayAndMonth(at)} ${at.year}';
}

/// The line under a team's name. [photo]: it is about a photo to decide.
typedef ChatPreview = ({String text, bool photo});

/// A waiting photo first, then the last message ("Tu: …" for the
/// organiser's), "Niciun mesaj încă" for an empty chat. While the last
/// message is on its way, the unread mark's text or nothing.
ChatPreview chatPreview(ChatRow row) {
  final mission = row.pendingPhotoMission;
  if (mission != null) return (text: 'Poză de aprobat · misiunea $mission', photo: true);
  final last = row.last;
  if (last == null) {
    if (!row.lastLoaded) return (text: _oneLine(row.team.unreadText ?? ''), photo: false);
    return (text: 'Niciun mesaj încă', photo: false);
  }
  var text = _oneLine(last.text);
  if (text.isEmpty && last.isPhoto) text = 'Poză';
  return (text: last.fromOrganiser ? 'Tu: $text' : text, photo: false);
}

String _oneLine(String text) => text.replaceAll(RegExp(r'\s+'), ' ').trim();

/// "o echipă", "12 echipe", "20 de echipe".
String _teams(int n) {
  if (n == 1) return 'o echipă';
  final rest = n % 100;
  final de = n >= 20 && (rest == 0 || rest >= 20);
  return de ? '$n de echipe' : '$n echipe';
}

/// "Moștenirea Cartografului · 12 echipe", under the title.
String chatsHeaderLine(String? eventName, int teams) {
  final name = eventName?.trim() ?? '';
  return name.isEmpty ? _teams(teams) : '$name · ${_teams(teams)}';
}

String allChipLabel(int n) => 'Toate · $n';

String unreadChipLabel(int n) => 'Necitite · $n';
