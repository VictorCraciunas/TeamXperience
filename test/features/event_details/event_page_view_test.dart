import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/dev/sample_event.dart';
import 'package:teamxperience/features/event_details/logic/event_page_data.dart';
import 'package:teamxperience/features/event_details/logic/signup_bar_state.dart';
import 'package:teamxperience/features/event_details/widgets/event_page_view.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/mission.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/ui/ui.dart';

final _now = DateTime(2026, 11, 7, 18);

Team _team() => Team(
      name: 'Vulpile',
      teamMembers: '',
      captainName: 'Victor',
      phoneNumber: '',
      captainEmail: '',
      numberOfMembers: 4,
    );

Future<void> _pump(
  WidgetTester tester, {
  Event? event,
  EventPageData data = const EventPageData(teamsCount: 12, organiserEventsCount: 14),
  void Function(SignupAction)? onAction,
  VoidCallback? onOpenMap,
  ThemeData? theme,
  double width = 390,
  double textScale = 1,
}) async {
  tester.view.physicalSize = Size(width * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final e = event ?? sampleEvent();
  await tester.pumpWidget(MaterialApp(
    theme: theme ?? AppTheme.light,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
      child: child ?? const SizedBox.shrink(),
    ),
    home: EventPageView(
      event: e,
      data: data,
      now: _now,
      onBack: () {},
      onShare: () {},
      onOpenMap: onOpenMap ?? (e.hasStartPin ? () {} : null),
      onSignupAction: onAction ?? (_) {},
    ),
  ));
}

Future<void> _see(WidgetTester tester, String text) =>
    tester.scrollUntilVisible(find.text(text), 200, scrollable: find.byType(Scrollable).first);

void main() {
  testWidgets('shows the mockup copy from top to bottom', (tester) async {
    await _pump(tester);
    for (final text in ['Înscrieri deschise · încă 5 zile', 'Moștenirea Cartografului', 'Sibiu · Orașul de Sus', '4,5 km · 6 misiuni', 'Piața Mare', 'Turnul Sfatului', 'Hartă', '14', 'nov · 10:00', '2 h', '●●○', 'Medie', '12']) {
      expect(find.text(text), findsWidgets, reason: text);
    }
    for (final text in ['Scara Pasajului', 'Încă 4 misiuni secrete', 'Coduri', 'Fotografii', 'Locuri pe hartă', 'Echipe de 2–6', 'Sâmbătă 14 nov · 10:00 · fii acolo la 9:45', 'Înscrieri până pe 12 nov', 'Telefon încărcat, încălțări comode', 'TX', '14 evenimente organizate']) {
      await _see(tester, text);
      expect(find.text(text), findsOneWidget, reason: text);
    }
    expect(find.text('Mai sunt 5 zile'), findsOneWidget);
    expect(find.text('12 echipe înscrise'), findsOneWidget);
    expect(find.textContaining('Piața Mare, lângă fântână', findRichText: true), findsOneWidget);
  });

  testWidgets('the register button asks for the register action', (tester) async {
    SignupAction? asked;
    await _pump(tester, onAction: (a) => asked = a);
    await tester.tap(find.text('Înscrie echipa'));
    expect(asked, SignupAction.register);
  });

  testWidgets('with a team the bar leads to the team', (tester) async {
    SignupAction? asked;
    await _pump(tester, data: EventPageData(team: _team(), teamsCount: 12, organiserEventsCount: 14), onAction: (a) => asked = a);
    await tester.tap(find.text('Echipa ta'));
    expect(asked, SignupAction.teamDetails);
  });

  testWidgets('a long story folds and unfolds', (tester) async {
    final e = sampleEvent()..story = List.filled(30, 'O poveste lungă despre o hartă veche.').join(' ');
    await _pump(tester, event: e);
    await _see(tester, 'Citește tot');
    await tester.tap(find.text('Citește tot'));
    await tester.pump();
    expect(find.text('Mai puțin'), findsOneWidget);
  });

  testWidgets('a short story has no read-more link', (tester) async {
    // The test font is far wider than Poppins, so the mockup story would wrap past 3 lines here.
    await _pump(tester, event: sampleEvent()..story = 'O hartă veche.');
    expect(find.text('Citește tot'), findsNothing);
  });

  testWidgets('an event with no missions has no mission section', (tester) async {
    await _pump(tester, event: sampleEvent()..missions = []);
    await _see(tester, 'Logistică');
    expect(find.text('Ce vă așteaptă'), findsNothing);
  });

  testWidgets('only secret missions show only the secret row', (tester) async {
    final e = sampleEvent()..missions = [Mission(id: '0', title: 'A'), Mission(id: '1')];
    await _pump(tester, event: e);
    await _see(tester, 'Încă 2 misiuni secrete');
    expect(find.text('A'), findsNothing);
  });

  testWidgets('no start pin, no map chip', (tester) async {
    await _pump(tester, event: sampleEvent()..startLatitude = null);
    expect(find.text('Hartă'), findsNothing);
  });

  testWidgets('an event saved before this step still reads', (tester) async {
    final old = Event(
      eventId: 'old',
      name: 'Vechi',
      location: 'Sibiu',
      dateEvent: DateTime(2026, 11, 14, 10),
      dificultate: 'Medie',
      lungimeTraseu: '4.5 km',
      durata: '2 ore',
      missions: [for (var i = 0; i < 6; i++) Mission(id: '$i')],
    );
    await _pump(tester, event: old);
    expect(find.text('●●○'), findsOneWidget);
    expect(find.text('4,5 km · 6 misiuni'), findsOneWidget);
    expect(find.text('2 h'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a long name on a narrow phone with large text does not overflow', (tester) async {
    final e = sampleEvent()..name = 'Moștenirea Cartografului și misterul celor șapte hărți pierdute din Orașul de Jos';
    await _pump(tester, event: e, width: 320, textScale: 1.3);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders in the dark theme', (tester) async {
    await _pump(tester, theme: AppTheme.dark);
    expect(tester.takeException(), isNull);
  });

  testWidgets('admins get their actions and no bar', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: EventPageView(
        event: sampleEvent(),
        data: const EventPageData(teamsCount: 12, organiserEventsCount: 14, isAdmin: true),
        now: _now,
        onBack: () {},
        onShare: () {},
        onSignupAction: (_) {},
        showHeroButtons: false,
        adminActions: const [Text('Vezi echipele înscrise')],
      ),
    ));
    await _see(tester, 'Vezi echipele înscrise');
    expect(find.text('Înscrie echipa'), findsNothing);
  });
}
