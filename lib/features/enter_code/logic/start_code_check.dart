import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/utils/fold_letters.dart';

/// What happens when a team types the start code. [noTeam] and [failed] come
/// from the team lookup after the code itself was right.
enum StartCodeResult { ok, wrong, tooEarly, closed, noTeam, failed }

/// The code as plain lower-case letters and digits: capitals, spaces,
/// diacritics and punctuation do not matter, so "Har ti" matches "HARTI" and
/// "SARPE1" matches "ȘARPE-1" (the code boxes take only letters and digits).
String normaliseCode(String code) => foldLetters(code).toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '');

/// Whether [input] lets a team into [event] at [now]. Teams can enter from
/// the start until the event's [Event.enterWindow] after it, the last minute included.
StartCodeResult checkStartCode({
  required String input,
  required Event event,
  required DateTime now,
}) {
  final start = event.dateEvent;
  if (start == null || event.isStopped) return StartCodeResult.closed;
  if (now.isBefore(start)) return StartCodeResult.tooEarly;
  if (now.isAfter(start.add(event.enterWindow))) return StartCodeResult.closed;

  final code = normaliseCode(event.startCode ?? '');
  if (code.isEmpty || normaliseCode(input) != code) return StartCodeResult.wrong;
  return StartCodeResult.ok;
}
