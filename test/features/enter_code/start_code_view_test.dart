import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/dev/sample_event.dart';
import 'package:teamxperience/features/enter_code/logic/start_code_check.dart';
import 'package:teamxperience/features/enter_code/widgets/start_code_view.dart';
import 'package:teamxperience/features/enter_code/widgets/start_photo_card.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/ui/components/misc/avatar_stack.dart';
import 'package:teamxperience/ui/theme/app_colors.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

final _now = DateTime(2026, 11, 14, 10, 18);

Event _event() => sampleEvent()..startCode = 'HARTA';

Team _team({bool started = false}) => Team(
      name: 'Vulpile',
      teamMembers: '',
      captainName: 'Victor',
      phoneNumber: '',
      captainEmail: '',
      numberOfMembers: 4,
      hasStarted: started,
      members: sampleMembers,
      presence: {for (final m in sampleMembers.take(3)) m.uid: _now.subtract(const Duration(seconds: 30))},
    );

class _Log {
  final calls = <String>[];
}

Future<_Log> _pump(
  WidgetTester tester, {
  Team? team,
  bool noTeam = false,
  StartCodeResult? result,
  bool started = false,
  DateTime? now,
  double width = 390,
  double textScale = 1,
  double keyboard = 0,
  ThemeData? theme,
  Widget? photoCard,
}) async {
  final log = _Log();
  tester.view.physicalSize = Size(width * 3, 760 * 3);
  tester.view.devicePixelRatio = 3;
  tester.view.viewInsets = FakeViewPadding(bottom: keyboard * 3);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    theme: theme ?? AppTheme.light,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
      child: child ?? const SizedBox.shrink(),
    ),
    home: Scaffold(
      body: StartCodeView(
        event: _event(),
        now: now ?? _now,
        team: noTeam ? null : (team ?? _team(started: started)),
        codeLength: 5,
        code: 'HARTI',
        result: result,
        started: started,
        busy: false,
        onCode: (c) => log.calls.add('code:$c'),
        onSubmit: () => log.calls.add('submit'),
        onClose: () => log.calls.add('close'),
        onChat: noTeam ? null : () => log.calls.add('chat'),
        photoCard: photoCard,
      ),
    ),
  ));
  return log;
}

void main() {
  testWidgets('mockup 05: the pill, the header, five boxes, the team', (tester) async {
    await _pump(tester);
    expect(find.text('A început · 42 min să intri'), findsOneWidget);
    expect(find.text('Moștenirea Cartografului'), findsOneWidget);
    expect(find.text('Introdu codul de start'), findsOneWidget);
    expect(find.text('Îl primești de la organizator la Piața Mare.'), findsOneWidget);
    for (var i = 0; i < 5; i++) {
      expect(find.byKey(ValueKey('code-box-$i')), findsOneWidget);
    }
    expect(find.text('Nu contează literele mari sau mici.'), findsOneWidget);
    expect(find.text('Echipa Vulpile'), findsOneWidget);
    expect(find.text('3 din 4 sunt aici'), findsOneWidget);
    final stack = tester.widget<AvatarStack>(find.byType(AvatarStack));
    expect(stack.initials, ['VC', 'AM', 'IR']);
    expect((stack.total, stack.gap), (4, 6.0));
    expect(find.text('Pornește jocul'), findsOneWidget);
    expect(find.text('Nu ai codul? Scrie-i organizatorului'), findsOneWidget);
  });

  group('the optional team photo', () {
    testWidgets('sits above the start button, which still works', (tester) async {
      final log = await _pump(tester, photoCard: StartPhotoCard(busy: true, onTake: () {}));
      expect(find.text('Poza echipei'), findsOneWidget);
      expect(find.text('Opțional. O găsiți la Amintiri.'), findsOneWidget);
      expect(
        tester.getBottomLeft(find.text('Poza echipei')).dy,
        lessThan(tester.getTopLeft(find.text('Pornește jocul')).dy),
      );
      await tester.tap(find.text('Pornește jocul'));
      expect(log.calls, ['submit']);
    });

    testWidgets('tapping asks for a photo', (tester) async {
      var taps = 0;
      await _pump(tester, photoCard: StartPhotoCard(busy: false, onTake: () => taps++));
      await tester.tap(find.text('Fă poza'));
      expect(taps, 1);
    });

    testWidgets('with a photo it offers a retake, and shows a failure', (tester) async {
      await _pump(
        tester,
        photoCard: StartPhotoCard(photoUrl: 'a', busy: false, error: 'Poza nu s-a trimis. Încearcă din nou.', onTake: () {}),
      );
      expect(find.text('Refă poza'), findsOneWidget);
      expect(find.text('Poza nu s-a trimis. Încearcă din nou.'), findsOneWidget);
    });

    testWidgets('fits 320 px at 1.3x text with the card', (tester) async {
      await _pump(
        tester,
        width: 320,
        textScale: 1.3,
        photoCard: StartPhotoCard(error: 'Poza nu s-a trimis. Încearcă din nou.', busy: false, onTake: () {}),
      );
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('a wrong code: the red line and red boxes', (tester) async {
    await _pump(tester, result: StartCodeResult.wrong);
    expect(find.text('Codul nu e corect. Verifică literele.'), findsOneWidget);
    final box = tester
        .widget<DecoratedBox>(find.descendant(of: find.byKey(const ValueKey('code-box-0')), matching: find.byType(DecoratedBox)).first)
        .decoration as BoxDecoration;
    expect((box.border as Border).top.color, AppColors.light.dangerOnNavy);
  });

  testWidgets('another refusal shows its line, the boxes stay calm', (tester) async {
    await _pump(tester, result: StartCodeResult.noTeam);
    expect(find.text('Nu găsim echipa ta la acest eveniment. Scrie-i organizatorului.'), findsOneWidget);
    final box = tester
        .widget<DecoratedBox>(find.descendant(of: find.byKey(const ValueKey('code-box-0')), matching: find.byType(DecoratedBox)).first)
        .decoration as BoxDecoration;
    expect((box.border as Border).top.color, isNot(AppColors.light.dangerOnNavy));
  });

  testWidgets('the button, the chat link and the close cross call back', (tester) async {
    final log = await _pump(tester);
    await tester.tap(find.text('Pornește jocul'));
    await tester.tap(find.text('Nu ai codul? Scrie-i organizatorului'));
    await tester.tap(find.byIcon(TablerIcons.x));
    expect(log.calls, ['submit', 'chat', 'close']);
  });

  testWidgets('once the team started: no boxes, "Intră în joc"', (tester) async {
    await _pump(tester, started: true);
    expect(find.byKey(const ValueKey('code-box-0')), findsNothing);
    expect(find.text('Intră în joc'), findsOneWidget);
    expect(find.text('Pornește jocul'), findsNothing);
  });

  testWidgets('no team: no team card and no chat link', (tester) async {
    await _pump(tester, noTeam: true);
    expect(find.text('Echipa Vulpile'), findsNothing);
    expect(find.text('Nu ai codul? Scrie-i organizatorului'), findsNothing);
  });

  testWidgets('after the window the pill says the entry is closed', (tester) async {
    await _pump(tester, now: _now.add(const Duration(minutes: 43)));
    expect(find.text('Intrarea s-a închis'), findsOneWidget);
  });

  for (final theme in [AppTheme.light, AppTheme.dark]) {
    testWidgets('fits 320 px at 1.3x text with the keyboard up (${theme.brightness.name})', (tester) async {
      await _pump(tester, width: 320, textScale: 1.3, keyboard: 300, result: StartCodeResult.noTeam, theme: theme);
      expect(tester.takeException(), isNull);
    });
  }
}
