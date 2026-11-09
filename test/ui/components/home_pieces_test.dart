import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/event/countdown_boxes.dart';
import 'package:teamxperience/ui/components/layout/mini_stat_card.dart';
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
  group('CountdownBoxes', () {
    testWidgets('days, hours and minutes, unpadded, 19 w500', (tester) async {
      await pumpUi(tester, _onNavy(const CountdownBoxes(left: Duration(days: 3, hours: 14, minutes: 22))));
      for (final t in ['3', '14', '22', 'zile', 'ore', 'min']) {
        expect(find.text(t), findsOneWidget);
      }
      final style = tester.widget<Text>(find.text('14')).style;
      expect((style?.fontSize, style?.fontWeight), (19, FontWeight.w500));
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
    testWidgets('three done: three dots, the current mission numbered, then the flag', (tester) async {
      await pumpUi(tester, _onNavy(const MissionProgressLine(total: 6, done: 3)));
      expect(find.text('4'), findsOneWidget);
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
    testWidgets('shows the rows', (tester) async {
      await pumpUi(tester, const LeaderboardCard(rows: _rows));
      expect(find.text('Bufnițele'), findsOneWidget);
    });
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
        ]),
        width: 320,
        textScale: 1.3,
        theme: theme,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
