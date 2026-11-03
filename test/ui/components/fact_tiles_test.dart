import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/event/date_fact_tile.dart';
import 'package:teamxperience/ui/components/event/difficulty_dots.dart';
import 'package:teamxperience/ui/components/event/fact_row.dart';
import 'package:teamxperience/ui/components/event/fact_tile.dart';

import '../pump_ui.dart';

Widget _row() => const FactRow(
      date: DateFactTile(day: '14', detail: 'nov · 10:00'),
      facts: [
        FactTile(icon: TablerIcons.clock, value: '2 h', label: 'durată'),
        FactTile(leading: DifficultyDots(level: 2), value: 'Medie', label: 'dificultate'),
        FactTile(icon: TablerIcons.users, value: '12', label: 'echipe'),
      ],
    );

void main() {
  testWidgets('difficulty dots fill up to the level', (tester) async {
    await pumpUi(tester, const DifficultyDots(level: 2));
    expect(find.text('●●○'), findsOneWidget);
  });

  testWidgets('difficulty dots clamp the level', (tester) async {
    await pumpUi(tester, const Column(children: [DifficultyDots(level: 5), DifficultyDots(level: -1)]));
    expect(find.text('●●●'), findsOneWidget);
    expect(find.text('○○○'), findsOneWidget);
  });

  testWidgets('a fact tile shows its value and label', (tester) async {
    await pumpUi(tester, const FactTile(icon: TablerIcons.clock, value: '2 h', label: 'durată'));
    expect(find.text('2 h'), findsOneWidget);
    expect(find.text('durată'), findsOneWidget);
    expect(find.byIcon(TablerIcons.clock), findsOneWidget);
  });

  testWidgets('the date tile in a fact row is 62 wide', (tester) async {
    await pumpUi(tester, _row());
    expect(tester.getSize(find.byType(DateFactTile)).width, 62);
    expect(find.text('nov · 10:00'), findsOneWidget);
  });

  testWidgets('a fact row fits a narrow phone with large text', (tester) async {
    await pumpUi(tester, _row(), width: 320, textScale: 1.3);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an icon tile has the mockup height and value position', (tester) async {
    await pumpUi(
      tester,
      const Align(
        alignment: Alignment.topLeft,
        child: SizedBox(width: 80, child: FactTile(icon: TablerIcons.clock, value: 'A', label: 'B')),
      ),
    );
    // 1 border + 6 padding, icon line 15 x 1.45, value 12 x 1.45, label 11 x 1.45.
    final top = tester.getTopLeft(find.byType(FactTile)).dy;
    expect(tester.getSize(find.byType(FactTile)).height, closeTo(7 + 21.75 + 17.4 + 15.95 + 7, 0.5));
    expect(tester.getTopLeft(find.text('A')).dy - top, closeTo(7 + 21.75, 0.5));
  });

  testWidgets('the date tile starts its text 6 from the top', (tester) async {
    await pumpUi(tester, _row());
    final top = tester.getTopLeft(find.byType(DateFactTile)).dy;
    expect(tester.getTopLeft(find.text('14')).dy - top, closeTo(6, 0.05));
  });
}
