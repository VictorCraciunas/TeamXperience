import 'package:teamxperience/model/event.dart';

/// What happens when a team types the start code.
enum StartCodeResult { ok, wrong, tooEarly, closed }

/// The code without any spaces and in lower case, so "Har ti" matches "HARTI".
String normaliseCode(String code) => code.replaceAll(RegExp(r'\s'), '').toLowerCase();

/// Whether [input] lets a team into [event] at [now]. Teams can enter from
/// the start until [Event.enterWindow] after it, the last minute included.
StartCodeResult checkStartCode({
  required String input,
  required Event event,
  required DateTime now,
}) {
  final start = event.dateEvent;
  if (start == null || event.isStopped) return StartCodeResult.closed;
  if (now.isBefore(start)) return StartCodeResult.tooEarly;
  if (now.isAfter(start.add(Event.enterWindow))) return StartCodeResult.closed;

  final code = normaliseCode(event.startCode ?? '');
  if (code.isEmpty || normaliseCode(input) != code) return StartCodeResult.wrong;
  return StartCodeResult.ok;
}
