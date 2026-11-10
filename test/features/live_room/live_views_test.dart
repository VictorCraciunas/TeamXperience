import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/photo_approval_status.dart';
import 'package:teamxperience/features/admin/home/logic/admin_event_stats.dart';
import 'package:teamxperience/features/live_room/logic/attention_queue.dart';
import 'package:teamxperience/features/live_room/logic/live_board.dart';
import 'package:teamxperience/features/live_room/logic/live_map_points.dart';
import 'package:teamxperience/features/live_room/logic/rating_summary.dart';
import 'package:teamxperience/features/live_room/widgets/board_view.dart';
import 'package:teamxperience/features/live_room/widgets/live_room_view.dart';
import 'package:teamxperience/features/live_room/widgets/team_sheet.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/mission.dart';
import 'package:teamxperience/model/photo_detail.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

final _now = DateTime(2026, 11, 14, 12);
DateTime _ago(int minutes) => _now.subtract(Duration(minutes: minutes));
const _long = 'Alexandru-Constantin și Prietenii de la Sibiu';

Team _team(
  String name, {
  bool started = true,
  int progress = 0,
  Map<int, DateTime>? solved,
  Map<String, int>? attempts,
  Map<String, PhotoApprovalStatus>? photos,
  Map<String, PhotoDetail>? details,
  String? unread,
}) =>
    Team(
      name: name,
      teamMembers: '',
      captainName: 'Ana',
      phoneNumber: '0722',
      captainEmail: '',
      hasStarted: started,
      missionProgress: progress,
      missionCompletedAt: solved,
      attempts: attempts,
      photoApprovals: photos,
      photoDetails: details,
      unreadText: unread,
    );

Event _event({String name = 'Moștenirea Cartografului'}) => Event(
      eventId: 'e',
      name: name,
      dateEvent: _now.subtract(const Duration(hours: 1, minutes: 42, seconds: 18)),
      missions: [for (var i = 0; i < 6; i++) Mission(id: 'm$i')],
    );

List<Team> _mockupTeams({String stuckName = 'Cometele', String photoName = 'Vulpile'}) => [
      _team(
        photoName,
        progress: 3,
        solved: {2: _ago(9)},
        photos: {'3_0_0': PhotoApprovalStatus.pending},
        details: {'3_0_0': PhotoDetail(status: PhotoApprovalStatus.pending, at: _ago(1))},
      ),
      _team(stuckName, progress: 1, solved: {0: _ago(25)}, attempts: {'1_0': 3}),
      _team('Lupii', progress: 3, solved: {2: _ago(5)}, unread: 'Ușa e închisă, ce facem?'),
      _team('Pisicile', started: false),
    ];

List<AttentionItem> _items(List<Team> teams) => attentionQueue(teams, missionCount: 6, now: _now, eventOver: false);

Widget _frame(Widget child, {ThemeData? theme, double width = 316, double textScale = 1}) => MediaQuery(
      data: MediaQueryData(size: Size(width, 700), textScaler: TextScaler.linear(textScale)),
      child: MaterialApp(
        theme: theme ?? AppTheme.light,
        home: Scaffold(body: child),
      ),
    );

class _Calls {
  final list = <String>[];
  void add(String s) => list.add(s);
}

Widget _room(List<Team> teams, _Calls calls, {Event? event, RatingSummary? ratings}) => LiveRoomView(
      event: event ?? _event(),
      ratings: ratings,
      stats: AdminEventStats.fromTeams(teams),
      items: _items(teams),
      map: const SizedBox.shrink(),
      clock: () => _now,
      isDeciding: (_) => false,
      onBoard: (f) => calls.add('board ${f.name}'),
      onAnnounce: () => calls.add('announce'),
      onViewPhoto: (i) => calls.add('view ${i.team.name}'),
      onReject: (i) => calls.add('reject ${i.team.name}'),
      onApprove: (i) => calls.add('approve ${i.team.name}'),
      onTeam: (t) => calls.add('team ${t.name}'),
      onChat: (t) => calls.add('chat ${t.name}'),
    );

Widget _board(List<Team> teams, _Calls calls, {bool canStop = true, BoardFilter filter = BoardFilter.all}) => BoardView(
      teamCount: teams.length,
      missionCount: 6,
      rows: boardRows(teams, missionCount: 6, now: _now, eventOver: false, filter: filter),
      filter: filter,
      now: _now,
      canStop: canStop,
      onFilter: (f) => calls.add('filter ${f.name}'),
      onTeam: (t) => calls.add('team ${t.name}'),
      onCall: (t) => calls.add('call ${t.name}'),
      onAnnounce: () => calls.add('announce'),
      onStop: () => calls.add('stop'),
    );

void _bigScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(632, 1800);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
}

void main() {
  group('LiveRoomView', () {
    testWidgets('the players stars: average, count and breakdown, no overflow', (tester) async {
      _bigScreen(tester);
      await tester.pumpWidget(_frame(_room(_mockupTeams(), _Calls(), ratings: ratingSummary(const [5, 5, 5, 4, 3])), textScale: 1.3));
      expect(find.text('Părerea jucătorilor'), findsOneWidget);
      expect(find.text('4,4'), findsOneWidget);
      expect(find.text('din 5 note'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('no stars: the section is hidden, or says nobody rated', (tester) async {
      _bigScreen(tester);
      await tester.pumpWidget(_frame(_room(_mockupTeams(), _Calls())));
      expect(find.text('Părerea jucătorilor'), findsNothing);
      await tester.pumpWidget(_frame(_room(_mockupTeams(), _Calls(), ratings: ratingSummary(const []))));
      expect(find.text('Nimeni nu a dat încă o notă.'), findsOneWidget);
    });

    testWidgets('the mockup: the header, the counts, the queue and its count', (tester) async {
      _bigScreen(tester);
      await tester.pumpWidget(_frame(_room(_mockupTeams(), _Calls())));
      for (final text in [
        'Moștenirea Cartografului',
        'în joc',
        'au terminat',
        'neporniți',
        'Necesită atenție',
        'Poză de aprobat',
        'Vulpile · misiunea 4',
        'Cometele stau de 25 min',
        'Misiunea 2 · 3 încercări greșite',
        'Mesaj nou de la Lupii',
        '„Ușa e închisă, ce facem?”',
      ]) {
        expect(find.text(text), findsOneWidget, reason: text);
      }
      expect(find.textContaining('1:17:42 rămase'), findsOneWidget);
      expect(find.text('3'), findsWidgets);
    });

    testWidgets('every action calls back with its team', (tester) async {
      _bigScreen(tester);
      final calls = _Calls();
      await tester.pumpWidget(_frame(_room(_mockupTeams(), calls)));
      await tester.tap(find.byIcon(TablerIcons.x));
      await tester.tap(find.byIcon(TablerIcons.check));
      await tester.tap(find.text('Cometele stau de 25 min'));
      await tester.tap(find.bySemanticsLabel('Scrie echipei'));
      await tester.tap(find.text('Mesaj nou de la Lupii'));
      await tester.tap(find.byIcon(TablerIcons.speakerphone));
      await tester.tap(find.byIcon(TablerIcons.list_numbers));
      await tester.tap(find.text('neporniți'));
      expect(calls.list, [
        'reject Vulpile',
        'approve Vulpile',
        'team Cometele',
        'chat Cometele',
        'chat Lupii',
        'announce',
        'board all',
        'board notStarted',
      ]);
    });

    testWidgets('a decision on its way rests both buttons', (tester) async {
      _bigScreen(tester);
      final calls = _Calls();
      final teams = _mockupTeams();
      await tester.pumpWidget(_frame(LiveRoomView(
        event: _event(),
        stats: AdminEventStats.fromTeams(teams),
        items: _items(teams),
        map: const SizedBox.shrink(),
        clock: () => _now,
        isDeciding: (_) => true,
        onBoard: (_) {},
        onAnnounce: () {},
        onViewPhoto: (_) {},
        onReject: (i) => calls.add('reject'),
        onApprove: (i) => calls.add('approve'),
        onTeam: (_) {},
        onChat: (_) {},
      )));
      await tester.tap(find.byIcon(TablerIcons.check));
      expect(calls.list, isEmpty);
    });

    testWidgets('a failed first read is not "nothing to do"', (tester) async {
      _bigScreen(tester);
      await tester.pumpWidget(_frame(LiveRoomView(
        event: _event(),
        stats: AdminEventStats.fromTeams(const []),
        items: const [],
        map: const SizedBox.shrink(),
        failed: true,
        clock: () => _now,
        isDeciding: (_) => false,
        onBoard: (_) {},
        onAnnounce: () {},
        onViewPhoto: (_) {},
        onReject: (_) {},
        onApprove: (_) {},
        onTeam: (_) {},
        onChat: (_) {},
      )));
      expect(find.text('Nu am putut încărca echipele.'), findsOneWidget);
      expect(find.text('Nimic de rezolvat acum.'), findsNothing);
      expect(find.text('în joc'), findsNothing);
    });

    testWidgets('nothing to do says so', (tester) async {
      _bigScreen(tester);
      await tester.pumpWidget(_frame(_room(const [], _Calls())));
      expect(find.text('Nimic de rezolvat acum.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    for (final theme in [AppTheme.light, AppTheme.dark]) {
      testWidgets('fits 320 px at 1.3x text (${theme.brightness.name})', (tester) async {
        await tester.pumpWidget(_frame(
          _room(_mockupTeams(stuckName: _long, photoName: _long), _Calls(), event: _event(name: _long)),
          theme: theme,
          width: 320,
          textScale: 1.3,
        ));
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('BoardView', () {
    testWidgets('the mockup: header, filters, statuses', (tester) async {
      _bigScreen(tester);
      await tester.pumpWidget(_frame(_board(_mockupTeams(), _Calls())));
      for (final text in [
        'Progresul echipelor',
        '4 echipe · 6 misiuni',
        'Toate',
        'Blocate',
        'Neporniți',
        'poză în așteptare',
        'blocați 25 min',
        'acum 5 min',
        'n-au introdus codul',
        'Sună căpitanul',
        'Anunț',
        'Oprește',
      ]) {
        expect(find.textContaining(text), findsOneWidget, reason: text);
      }
    });

    testWidgets('filters, rows, the call and the buttons call back', (tester) async {
      _bigScreen(tester);
      final calls = _Calls();
      await tester.pumpWidget(_frame(_board(_mockupTeams(), calls)));
      await tester.tap(find.text('Blocate'));
      await tester.tap(find.text('Lupii'));
      await tester.tap(find.text('Sună căpitanul'));
      await tester.tap(find.text('Anunț'));
      await tester.tap(find.text('Oprește'));
      expect(calls.list, ['filter stuck', 'team Lupii', 'call Pisicile', 'announce', 'stop']);
    });

    testWidgets('an announcement on its way rests the button', (tester) async {
      _bigScreen(tester);
      final calls = _Calls();
      final teams = _mockupTeams();
      await tester.pumpWidget(_frame(BoardView(
        teamCount: teams.length,
        missionCount: 6,
        rows: boardRows(teams, missionCount: 6, now: _now, eventOver: false),
        filter: BoardFilter.all,
        now: _now,
        canStop: true,
        announcing: true,
        onFilter: (_) {},
        onTeam: (_) {},
        onCall: (_) {},
        onAnnounce: () => calls.add('announce'),
        onStop: () {},
      )));
      await tester.tap(find.text('Se trimite...'));
      expect(calls.list, isEmpty);
    });

    testWidgets('no stop when it cannot be stopped', (tester) async {
      await tester.pumpWidget(_frame(_board(_mockupTeams(), _Calls(), canStop: false)));
      expect(find.text('Oprește'), findsNothing);
      expect(find.text('Anunț'), findsOneWidget);
    });

    testWidgets('a failed first read says so, not "no teams"', (tester) async {
      await tester.pumpWidget(_frame(BoardView(
        teamCount: 0,
        missionCount: 6,
        rows: const [],
        filter: BoardFilter.all,
        now: _now,
        canStop: false,
        failed: true,
        onFilter: (_) {},
        onTeam: (_) {},
        onCall: (_) {},
        onAnnounce: () {},
        onStop: () {},
      )));
      expect(find.text('Nu am putut încărca echipele.'), findsOneWidget);
      expect(find.text('Nu e nicio echipă înscrisă.'), findsNothing);
    });

    testWidgets('an empty filter and an empty event say so', (tester) async {
      await tester.pumpWidget(_frame(_board([_team('A')], _Calls(), filter: BoardFilter.stuck)));
      expect(find.text('Nicio echipă aici.'), findsOneWidget);
      await tester.pumpWidget(_frame(_board(const [], _Calls())));
      expect(find.text('Nu e nicio echipă înscrisă.'), findsOneWidget);
    });

    for (final theme in [AppTheme.light, AppTheme.dark]) {
      testWidgets('fits 320 px at 1.3x text (${theme.brightness.name})', (tester) async {
        await tester.pumpWidget(_frame(
          _board(_mockupTeams(stuckName: _long, photoName: _long), _Calls()),
          theme: theme,
          width: 320,
          textScale: 1.3,
        ));
        expect(tester.takeException(), isNull);
      });
    }
  });

  testWidgets('the team sheet closes, then acts', (tester) async {
    final calls = _Calls();
    await tester.pumpWidget(_frame(Builder(
      builder: (context) => TextButton(
        onPressed: () => showTeamSheet(
          context,
          team: _team('Lupii'),
          tone: PinTone.playing,
          status: 'acum 2 min',
          onCall: () => calls.add('call'),
          onMessage: () => calls.add('message'),
        ),
        child: const Text('deschide'),
      ),
    )));
    await tester.tap(find.text('deschide'));
    await tester.pumpAndSettle();
    expect(find.text('Lupii'), findsOneWidget);
    expect(find.text('Ana · acum 2 min'), findsOneWidget);
    await tester.tap(find.text('Sună căpitanul'));
    await tester.pumpAndSettle();
    expect(find.text('Lupii'), findsNothing);
    expect(calls.list, ['call']);
  });
}
