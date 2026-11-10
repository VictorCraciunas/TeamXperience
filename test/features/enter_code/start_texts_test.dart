import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/enter_code/logic/start_code_check.dart';
import 'package:teamxperience/features/enter_code/logic/start_texts.dart';
import 'package:teamxperience/model/event.dart';

void main() {
  final start = DateTime(2026, 11, 14, 10);
  Event event({bool stopped = false, String? place = 'Piața Mare', String? code = 'HARTA'}) => Event(
        eventId: 'e1',
        dateEvent: start,
        isStopped: stopped,
        punctDeStart: place,
        startCode: code,
      );

  group('enterPill', () {
    test('while the window is open: the minutes left', () {
      expect(enterPill(event(), DateTime(2026, 11, 14, 10, 18)), 'A început · 42 min să intri');
    });

    test('in the last seconds it still says 1 min', () {
      expect(enterPill(event(), DateTime(2026, 11, 14, 10, 59, 40)), 'A început · 1 min să intri');
    });

    test('before the start: when it starts', () {
      expect(enterPill(event(), DateTime(2026, 11, 14, 9, 30)), 'Începe la 10:00');
    });

    test('after the window, or stopped: closed', () {
      expect(enterPill(event(), DateTime(2026, 11, 14, 11, 1)), 'Intrarea s-a închis');
      expect(enterPill(event(stopped: true), DateTime(2026, 11, 14, 10, 18)), 'Intrarea s-a închis');
    });
  });

  test('codeHint', () {
    expect(codeHint(event()), 'Îl primești de la organizator la Piața Mare.');
    expect(codeHint(event(place: null)), 'Îl primești de la organizator.');
    expect(codeHint(event(place: ' ')), 'Îl primești de la organizator.');
  });

  test('startError', () {
    expect(startError(null), isNull);
    expect(startError(StartCodeResult.ok), isNull);
    expect(startError(StartCodeResult.wrong), 'Codul nu e corect. Verifică literele.');
    expect(startError(StartCodeResult.tooEarly), 'Jocul nu a început încă.');
    expect(startError(StartCodeResult.closed), 'Timpul pentru intrare s-a terminat.');
    expect(startError(StartCodeResult.noTeam), 'Nu găsim echipa ta la acest eveniment. Scrie-i organizatorului.');
    expect(startError(StartCodeResult.failed), 'Verifică internetul și încearcă din nou.');
  });

  test('hereLine', () {
    expect(hereLine(3, 4), '3 din 4 sunt aici');
    expect(hereLine(0, 4), '0 din 4 sunt aici');
  });

  test('codeLength: one box per character, spaces ignored; 5 without a code', () {
    expect(codeLength(event()), 5);
    expect(codeLength(event(code: 'har ta 7')), 6);
    expect(codeLength(event(code: null)), 5);
    expect(codeLength(event(code: '  ')), 5);
    expect(codeLength(event(code: 'HARTA-1')), 6);
    expect(codeLength(event(code: 'ȘARPE')), 5);
  });
}
