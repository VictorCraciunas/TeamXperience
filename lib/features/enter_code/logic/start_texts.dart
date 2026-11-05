import 'package:teamxperience/features/event_details/logic/enrolment_window.dart';
import 'package:teamxperience/model/event.dart';

import 'start_code_check.dart';

/// The pill at the top of the start screen: "A început · 42 min să intri"
/// while the code can be typed, "Începe la 10:00" before the start,
/// "Intrarea s-a închis" after the window or once the event is stopped.
String enterPill(Event event, DateTime now) {
  final start = event.dateEvent;
  if (start == null || event.isStopped) return 'Intrarea s-a închis';
  if (now.isBefore(start)) {
    return 'Începe la ${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
  }
  if (!inEnterWindow(event, now)) return 'Intrarea s-a închis';
  final left = enterMinutesLeft(event, now);
  return 'A început · ${left < 1 ? 1 : left} min să intri';
}

/// "Îl primești de la organizator la Piața Mare."
String codeHint(Event event) {
  final place = event.punctDeStart?.trim() ?? '';
  return place.isEmpty ? 'Îl primești de la organizator.' : 'Îl primești de la organizator la $place.';
}

/// The line under the code boxes for a refused code; null when there is
/// nothing to say.
String? startError(StartCodeResult? result) => switch (result) {
      null || StartCodeResult.ok => null,
      StartCodeResult.wrong => 'Codul nu e corect. Verifică literele.',
      StartCodeResult.tooEarly => 'Jocul nu a început încă.',
      StartCodeResult.closed => 'Timpul pentru intrare s-a terminat.',
      StartCodeResult.noTeam => 'Nu găsim echipa ta la acest eveniment. Scrie-i organizatorului.',
      StartCodeResult.failed => 'Verifică internetul și încearcă din nou.',
    };

/// "3 din 4 sunt aici".
String hereLine(int here, int size) => '$here din $size sunt aici';

/// One box per character of the start code (spaces ignored); 5 when the
/// event has no code.
int codeLength(Event event) {
  final length = normaliseCode(event.startCode ?? '').length;
  return length == 0 ? 5 : length;
}
