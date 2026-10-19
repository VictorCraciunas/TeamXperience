import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/event/event_row.dart';

import '../pump_ui.dart';

void main() {
  testWidgets('shows the date block, title and subtitle', (tester) async {
    await pumpUi(
      tester,
      const EventRow(
        title: 'Xtreme Highschool Challenge 2026',
        subtitle: 'Sibiu, zona centrală',
        dayLabel: '22',
        monthLabel: 'OCT',
      ),
    );
    expect(find.text('22'), findsOneWidget);
    expect(find.text('OCT'), findsOneWidget);
    expect(find.text('Xtreme Highschool Challenge 2026'), findsOneWidget);
    expect(find.text('Sibiu, zona centrală'), findsOneWidget);
  });

  testWidgets('fires onTap', (tester) async {
    var taps = 0;
    await pumpUi(
      tester,
      EventRow(
        title: 'Eveniment',
        subtitle: 'Sibiu',
        dayLabel: '02',
        monthLabel: 'DEC',
        onTap: () => taps++,
      ),
    );
    await tester.tap(find.byType(EventRow));
    expect(taps, 1);
  });

  testWidgets('shows a trailing widget when given', (tester) async {
    await pumpUi(
      tester,
      const EventRow(
        title: 'Eveniment',
        subtitle: 'Sibiu',
        dayLabel: '02',
        monthLabel: 'DEC',
        trailing: Text('9 echipe'),
      ),
    );
    expect(find.text('9 echipe'), findsOneWidget);
  });

  testWidgets('a very long title does not overflow at text scale 1.5', (tester) async {
    await pumpUi(
      tester,
      const EventRow(
        title: 'Un eveniment cu un titlu extrem de lung care nu are cum să încapă pe un singur rând',
        subtitle: 'O locație cu un nume lung, undeva departe de centru',
        dayLabel: '02',
        monthLabel: 'DEC',
        trailing: Text('12 echipe'),
      ),
      textScale: 1.5,
    );
    expect(tester.takeException(), isNull);
  });
}
