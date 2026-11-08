import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/ui/components/event/format_remaining.dart';

import 'attention_queue.dart';
import 'live_board.dart';
import 'live_status.dart';

/// "12 echipe", "O echipă", "20 de echipe".
String _count(int n, String one, String many) {
  if (n == 1) return one;
  final rest = n % 100;
  final de = n >= 20 && (rest == 0 || rest >= 20);
  return de ? '$n de $many' : '$n $many';
}

/// "25 min", "1 h 5 min".
String _minutes(int minutes) {
  if (minutes < 60) return '$minutes min';
  final rest = minutes % 60;
  return rest == 0 ? '${minutes ~/ 60} h' : '${minutes ~/ 60} h $rest min';
}

/// What the header says after the event's name: how long is left or how long
/// until the start.
String liveHeaderLine(Event event, DateTime now) {
  if (event.isStopped) return 'Oprit';
  final start = event.dateEvent;
  if (start == null) return '';
  if (eventEnded(event, now)) return 'Încheiat';
  if (now.isBefore(start)) {
    final left = start.difference(now);
    if (left.inDays >= 1) return 'Începe în ${_count(left.inDays, 'o zi', 'zile')}';
    if (left.inMinutes < 1) return 'Începe acum';
    return 'Începe în ${_minutes(left.inMinutes)}';
  }
  return '${formatRemaining(start.add(Event.maxDuration).difference(now))} rămase';
}

/// "12 echipe · 6 misiuni".
String boardHeaderLine(int teams, int missions) =>
    '${_count(teams, 'O echipă', 'echipe')} · ${_count(missions, 'O misiune', 'misiuni')}';

/// The line under a team's name on the board.
String boardStatusText(BoardRow row, DateTime now) {
  final since = row.since;
  return switch (row.state) {
    LiveState.notStarted => 'n-au introdus codul',
    LiveState.waitingPhoto => 'poză în așteptare',
    LiveState.finished => 'au terminat',
    LiveState.stopped => 'oprită',
    LiveState.stuck when since != null => 'blocați ${_minutes(now.difference(since).inMinutes)}',
    _ when since == null => 'în joc',
    _ => now.difference(since).inMinutes < 1 ? 'acum' : 'acum ${_minutes(now.difference(since).inMinutes)}',
  };
}

String _wrongLine(int wrong) => wrong == 1 ? 'o încercare greșită' : '$wrong încercări greșite';

/// "Cometele stau de 25 min", or "Cometele: 3 încercări greșite".
String stuckTitle(StuckAttention item) {
  final minutes = item.minutes;
  if (minutes == null) return '${item.team.name}: ${_wrongLine(item.wrong)}';
  return '${item.team.name} stau de ${_minutes(minutes)}';
}

/// "Misiunea 2 · 3 încercări greșite".
String stuckSubtitle(StuckAttention item) {
  final mission = 'Misiunea ${item.mission}';
  if (item.minutes == null || item.wrong == 0) return mission;
  return '$mission · ${_wrongLine(item.wrong)}';
}

/// The letter on a team's pin. By rune, not code unit: a name may start with
/// an emoji.
String teamInitial(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return '?';
  return String.fromCharCode(trimmed.runes.first).toUpperCase();
}
