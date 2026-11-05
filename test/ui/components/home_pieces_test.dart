import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/event/countdown_boxes.dart';
import 'package:teamxperience/ui/components/event/event_mini_card.dart';
import 'package:teamxperience/ui/components/layout/mini_stat_card.dart';
import 'package:teamxperience/ui/components/misc/section_header.dart';
import 'package:teamxperience/ui/components/route/checkpoint_line.dart';
import 'package:teamxperience/ui/components/route/mission_progress_line.dart';
import 'package:teamxperience/ui/components/team/leaderboard_card.dart';
import 'package:teamxperience/ui/theme/app_colors.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

import '../pump_ui.dart';

/// The navy pieces are drawn on navy, as on the Home cards.
Widget _onNavy(Widget child) => ColoredBox(
      color: AppColors.light.navy,
      child: Padding(padding: const EdgeInsets.all(14), child: child),
    );

/// Every widget whose key starts with [prefix].
Finder _keyed(String prefix) => find.byWidgetPredicate((w) {
      final key = w.key;
      return key is ValueKey<String> && key.value.startsWith(prefix);
    });

const _rows = [
  LeaderboardRow(place: 1, name: 'Bufnițele', score: '5/6'),
  LeaderboardRow(place: 2, name: 'Vulpile · voi', score: '4/6', own: true),
  LeaderboardRow(place: 3, name: 'Lupii de Cetate', score: '4/6'),
];

void main() {
  group('MiniStatCard', () {
    testWidgets('value 14 w500 over an 11 px muted label', (tester) async {
      await pumpUi(tester, const SizedBox(width: 100, child: MiniStatCard(value: '3', label: 'jocuri')));
      final value = tester.widget<Text>(find.text('3')).style;
      expect((value?.fontSize, value?.fontWeight), (14, FontWeight.w500));
      final label = tester.widget<Text>(find.text('jocuri')).style;
      expect((label?.fontSize, label?.color), (11, AppColors.light.muted));
    });

    testWidgets('with progress: an accent value over a 4 px bar filled to the progress', (tester) async {
      await pumpUi(tester, const SizedBox(width: 120, child: MiniStatCard(value: 'Explorator', progress: 0.6, accent: true)));
      expect(tester.widget<Text>(find.text('Explorator')).style?.color, AppColors.light.accent);
      final track = tester.getSize(find.byKey(const ValueKey('stat-track')));
      final fill = tester.getSize(find.byKey(const ValueKey('stat-fill')));
      expect(track.height, 4);
      expect(fill.width, closeTo(track.width * 0.6, 0.5));
    });
  });

  group('CountdownBoxes', () {
    testWidgets('days, hours and minutes, unpadded, 17 w500', (tester) async {
      await pumpUi(tester, _onNavy(const CountdownBoxes(left: Duration(days: 3, hours: 14, minutes: 22))));
      for (final t in ['3', '14', '22', 'zile', 'ore', 'min']) {
        expect(find.text(t), findsOneWidget);
      }
      final style = tester.widget<Text>(find.text('14')).style;
      expect((style?.fontSize, style?.fontWeight), (17, FontWeight.w500));
    });

    testWidgets('a past time shows zeros', (tester) async {
      await pumpUi(tester, _onNavy(const CountdownBoxes(left: Duration(minutes: -3))));
      expect(find.text('0'), findsNWidgets(3));
    });
  });

  group('CheckpointLine', () {
    testWidgets('two done of three: two checks, one empty ring, the labels', (tester) async {
      await pumpUi(
        tester,
        _onNavy(const CheckpointLine(labels: ['Înscriși', 'Echipă completă', 'Cod de start'], done: 2)),
      );
      expect(find.byIcon(TablerIcons.check), findsNWidgets(2));
      expect(find.byKey(const ValueKey('checkpoint-open-2')), findsOneWidget);
      expect(tester.getSize(find.byKey(const ValueKey('checkpoint-open-2'))), const Size(18, 18));
      expect(find.text('Cod de start'), findsOneWidget);
    });
  });

  group('MissionProgressLine', () {
    testWidgets('three done: three dots, the current mission numbered in a 22 px circle, then the flag', (tester) async {
      await pumpUi(tester, _onNavy(const MissionProgressLine(total: 6, done: 3)));
      expect(find.text('4'), findsOneWidget);
      expect(tester.getSize(find.byKey(const ValueKey('mission-current'))), const Size(22, 22));
      expect(_keyed('mission-done-'), findsNWidgets(3));
      expect(_keyed('mission-open-'), findsNWidgets(2));
      expect(find.byIcon(TablerIcons.flag), findsOneWidget);
    });

    testWidgets('without missions only the flag', (tester) async {
      await pumpUi(tester, _onNavy(const MissionProgressLine(total: 0, done: 0)));
      expect(find.byIcon(TablerIcons.flag), findsOneWidget);
      expect(find.byKey(const ValueKey('mission-current')), findsNothing);
      expect(_keyed('mission-done-'), findsNothing);
    });

    testWidgets('all done: dots only, no current circle', (tester) async {
      await pumpUi(tester, _onNavy(const MissionProgressLine(total: 6, done: 6)));
      expect(_keyed('mission-done-'), findsNWidgets(6));
      expect(find.byKey(const ValueKey('mission-current')), findsNothing);
    });
  });

  group('LeaderboardCard', () {
    testWidgets('the rows, the own one filled with the active pill colour and its score in accent', (tester) async {
      await pumpUi(tester, const LeaderboardCard(rows: _rows));
      expect(find.text('Bufnițele'), findsOneWidget);
      final own = tester.widget<Container>(find.byKey(const ValueKey('leader-row-2')));
      expect((own.decoration as BoxDecoration?)?.color ?? own.color, AppColors.light.navActivePill);
      expect(tester.widget<Text>(find.text('Vulpile · voi')).style?.fontWeight, FontWeight.w500);
      final score = tester.widget<Text>(find.text('4/6').first).style;
      expect(score?.color, AppColors.light.accent);
      expect(tester.widget<Text>(find.text('5/6')).style?.color, AppColors.light.muted);
    });
  });

  group('EventMiniCard', () {
    testWidgets('176 wide (150 inside, as the CSS content box) with a 70 px strip, the date pill, the title and facts', (tester) async {
      var taps = 0;
      await pumpUi(
        tester,
        Align(
          alignment: Alignment.topLeft,
          child: EventMiniCard(
            title: 'Protocolul Cerber',
            date: '21 nov',
            facts: '3,2 km · 1 h 30',
            onTap: () => taps++,
          ),
        ),
      );
      expect(tester.getSize(find.byType(EventMiniCard)).width, 176);
      expect(tester.getSize(find.byKey(const ValueKey('mini-strip'))).width, 162);
      expect(tester.getSize(find.byKey(const ValueKey('mini-strip'))).height, 70);
      expect(find.text('21 nov'), findsOneWidget);
      expect(find.text('3,2 km · 1 h 30'), findsOneWidget);
      await tester.tap(find.text('Protocolul Cerber'));
      expect(taps, 1);
    });
  });

  testWidgets('SectionHeader(top: 16) puts its dot 16 below the top', (tester) async {
    await pumpUi(tester, const SectionHeader(title: 'Evenimente noi', top: 16));
    final top = tester.getTopLeft(find.byType(SectionHeader)).dy;
    final dot = tester.getRect(find.byKey(const ValueKey('hd-dot')));
    final title = tester.getRect(find.text('Evenimente noi'));
    expect(title.top - top, 16);
    expect(dot.center.dy, closeTo(title.center.dy, 0.5));
  });

  testWidgets('the live card colour token', (tester) async {
    expect(AppColors.light.liveCard, const Color(0xFF0C092A));
    expect(AppColors.dark.liveCard, const Color(0xFF1B1446));
  });

  for (final theme in [AppTheme.light, AppTheme.dark]) {
    testWidgets('everything fits 320 px at 1.3x text (${theme.brightness.name})', (tester) async {
      await pumpUi(
        tester,
        Column(children: [
          const Row(children: [
            Expanded(flex: 10, child: MiniStatCard(value: '3', label: 'jocuri')),
            SizedBox(width: 6),
            Expanded(flex: 10, child: MiniStatCard(value: '12,4 km', label: 'pe jos')),
            SizedBox(width: 6),
            Expanded(flex: 13, child: MiniStatCard(value: 'Explorator', progress: 0.6, accent: true)),
          ]),
          _onNavy(const CountdownBoxes(left: Duration(days: 3, hours: 14, minutes: 22))),
          _onNavy(const CheckpointLine(labels: ['Înscriși', 'Echipă completă', 'Cod de start'], done: 2)),
          _onNavy(const MissionProgressLine(total: 6, done: 3)),
          const LeaderboardCard(rows: _rows),
          SizedBox(
            height: 160,
            child: EventMiniCard(title: 'Protocolul Cerber', date: '21 nov', facts: '3,2 km · 1 h 30', onTap: () {}),
          ),
        ]),
        width: 320,
        textScale: 1.3,
        theme: theme,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
