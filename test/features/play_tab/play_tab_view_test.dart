import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/play_tab/logic/play_tab_state.dart';
import 'package:teamxperience/features/play_tab/widgets/play_tab_view.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';

import '../../ui/pump_ui.dart';

final _event = Event(eventId: 'e', name: 'Moștenirea Cartografului', dateEvent: DateTime(2026, 11, 14, 10));
final _team = Team(name: 'Vulpile', teamMembers: '', captainName: 'V', phoneNumber: '', captainEmail: '', numberOfMembers: 4);

void main() {
  late List<String> calls;
  setUp(() => calls = []);

  Future<void> pump(WidgetTester tester, PlayTabState state, {double width = 360, double textScale = 1}) => pumpUi(
        tester,
        PlayTabView(
          state: state,
          onContinue: (e, t) => calls.add('continue'),
          onEnterCode: (e) => calls.add('code'),
          onOpenEvent: (e) => calls.add('open'),
          onBrowse: () => calls.add('browse'),
        ),
        width: width,
        textScale: textScale,
      );

  testWidgets('live: continue the game', (tester) async {
    await pump(tester, PlayLive(_event, _team));
    expect(find.text('Moștenirea Cartografului'), findsOneWidget);
    expect(find.text('Echipa Vulpile e în joc'), findsOneWidget);
    await tester.tap(find.text('Continuă jocul'));
    expect(calls, ['continue']);
  });

  testWidgets('first hour: enter the code', (tester) async {
    await pump(tester, PlayEnterCode(_event, 42));
    expect(find.text('42 min să intri'), findsOneWidget);
    await tester.tap(find.text('Introdu codul'));
    expect(calls, ['code']);
  });

  testWidgets('next game: open the event', (tester) async {
    await pump(tester, PlayNext(_event, const Duration(days: 3)));
    expect(find.text('Următorul tău joc'), findsOneWidget);
    expect(find.text('Sâmbătă 14 nov · 10:00 · fii acolo la 9:45'), findsOneWidget);
    await tester.tap(find.text('Vezi evenimentul'));
    expect(calls, ['open']);
  });

  testWidgets('nothing planned: browse the events', (tester) async {
    await pump(tester, const PlayNone());
    expect(find.text('Nu ai niciun joc programat.'), findsOneWidget);
    await tester.tap(find.text('Vezi evenimentele'));
    expect(calls, ['browse']);
  });

  testWidgets('fits a 320 px phone at 1.3x text', (tester) async {
    for (final s in [PlayLive(_event, _team), PlayEnterCode(_event, 42), PlayNext(_event, const Duration(days: 3)), const PlayNone()]) {
      await pump(tester, s, width: 320, textScale: 1.3);
      expect(tester.takeException(), isNull);
    }
  });
}
