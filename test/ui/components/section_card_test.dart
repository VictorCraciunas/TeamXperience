import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/layout/section_card.dart';

import '../pump_ui.dart';

void main() {
  testWidgets('shows title, count badge and an action link that fires',
      (tester) async {
    var taps = 0;
    await pumpUi(
      tester,
      SectionCard(
        title: 'Înscrierile tale',
        count: 1,
        onAction: () => taps++,
        child: const Text('conținut'),
      ),
    );
    expect(find.text('Înscrierile tale'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('conținut'), findsOneWidget);
    await tester.tap(find.textContaining('Vezi toate'));
    expect(taps, 1);
  });

  testWidgets('uses a custom action label', (tester) async {
    await pumpUi(
      tester,
      SectionCard(
        title: 'Evenimente',
        actionLabel: 'Vezi evenimentele',
        onAction: () {},
        child: const SizedBox(),
      ),
    );
    expect(find.textContaining('Vezi evenimentele'), findsOneWidget);
  });

  testWidgets('hides the link when onAction is null', (tester) async {
    await pumpUi(
      tester,
      const SectionCard(title: 'Noutăți', child: SizedBox()),
    );
    expect(find.textContaining('Vezi toate'), findsNothing);
  });

  testWidgets('long title does not overflow at text scale 1.5', (tester) async {
    await pumpUi(
      tester,
      SectionCard(
        title: 'O secțiune cu un titlu foarte lung care nu încape pe un rând',
        count: 12,
        onAction: () {},
        child: const SizedBox(),
      ),
      textScale: 1.5,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('a count label replaces the numeric badge', (tester) async {
    await pumpUi(
      tester,
      const SectionCard(
        title: 'Pregătirea echipei',
        countLabel: '2 din 3',
        child: SizedBox(),
      ),
    );
    expect(find.text('2 din 3'), findsOneWidget);
  });
}
