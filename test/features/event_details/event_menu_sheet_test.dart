import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/photo_approval_status.dart';
import 'package:teamxperience/features/event_details/logic/event_menu_action.dart';
import 'package:teamxperience/features/event_details/widgets/event_menu_sheet.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/model/team_member.dart';
import 'package:teamxperience/ui/ui.dart';

Team _team(String name, {int members = 3, String? unread, Map<String, PhotoApprovalStatus>? photos}) => Team(
      name: name,
      teamMembers: '',
      captainName: '',
      phoneNumber: '',
      captainEmail: '',
      members: [for (var i = 0; i < members; i++) TeamMember.fromName('Jucător $i')],
      unreadText: unread,
      photoApprovals: photos,
    );

final _event = Event(
  eventId: 'e1',
  name: 'Moștenirea Cartografului',
  dateEvent: DateTime(2026, 11, 21, 10),
);

/// Pumps a page with a button that opens the sheet; [picked] gets what it
/// resolved to.
Future<void> _pump(
  WidgetTester tester, {
  required Stream<List<Team>> teams,
  List<Team> initialTeams = const [],
  ThemeData? theme,
  Size size = const Size(390, 844),
  double textScale = 1,
  void Function(EventMenuAction?)? picked,
}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    theme: theme ?? AppTheme.light,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
      child: child ?? const SizedBox.shrink(),
    ),
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () async {
              final action = await showEventMenuSheet(context, event: _event, teams: teams, initialTeams: initialTeams);
              picked?.call(action);
            },
            child: const Text('open'),
          ),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the design copy, with the counts from the teams', (tester) async {
    final teams = [_team('A', unread: 'Salut'), _team('B', members: 4), _team('C', unread: 'Gata')];
    await _pump(tester, teams: Stream.value(teams));
    for (final text in [
      'Moștenirea Cartografului',
      'Camera live',
      'Harta, echipele, anunțuri, oprire',
      'Echipe înscrise',
      '3 echipe · 10 jucători',
      'Conversații',
      'Chat cu fiecare echipă',
      'Editează evenimentul',
      'Încearcă jocul ca jucător',
      'Duplică pentru o nouă dată',
      'Șterge evenimentul',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    expect(find.textContaining('3 echipe înscrise · '), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('the counts follow the stream while the sheet is open', (tester) async {
    final controller = StreamController<List<Team>>();
    addTearDown(controller.close);
    await _pump(tester, teams: controller.stream, initialTeams: [_team('A')]);
    expect(find.text('O echipă · 3 jucători'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    controller.add([_team('A'), _team('B', unread: 'Ajutor')]);
    // One pump delivers the event, the next builds it.
    await tester.pump();
    await tester.pump();
    expect(find.text('2 echipe · 6 jucători'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);

    // A photo waiting for a decision counts too, as in the conversations list.
    controller.add([_team('A', photos: {'0_0_0': PhotoApprovalStatus.pending}), _team('B', unread: 'Ajutor')]);
    await tester.pump();
    await tester.pump();
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('a row closes the sheet with its action', (tester) async {
    EventMenuAction? picked;
    await _pump(tester, teams: Stream.value(const []), picked: (a) => picked = a);
    await tester.tap(find.text('Duplică pentru o nouă dată'));
    await tester.pumpAndSettle();
    expect(picked, EventMenuAction.duplicate);
    expect(find.text('Camera live'), findsNothing);
  });

  for (final (name, theme) in [('light', AppTheme.light), ('dark', AppTheme.dark)]) {
    testWidgets('fits a small phone at text scale 2, scrolling to the last row ($name)', (tester) async {
      final teams = [for (var i = 0; i < 25; i++) _team('Echipa $i', unread: i.isEven ? 'x' : null)];
      await _pump(tester, teams: Stream.value(teams), theme: theme, size: const Size(320, 640), textScale: 2);
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(find.text('Șterge evenimentul'), 100, scrollable: find.byType(Scrollable).last);
      expect(find.text('Șterge evenimentul'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
