import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/event_details/logic/event_page_content.dart';
import 'package:teamxperience/features/event_details/widgets/logistics_row.dart';
import 'package:teamxperience/features/event_details/widgets/organiser_card.dart';

import '../../ui/pump_ui.dart';

void main() {
  testWidgets('the organiser card is as tall as in the mockup', (tester) async {
    await pumpUi(
      tester,
      Align(
        alignment: Alignment.topLeft,
        child: OrganiserCard(name: 'TX', eventsCount: 14, onMessage: () {}),
      ),
    );
    // 1 border + 10 padding, the 34 px circle, 10 + 1.
    expect(tester.getSize(find.byType(OrganiserCard)).height, closeTo(56, 0.5));
  });

  testWidgets('the message button still answers taps', (tester) async {
    var taps = 0;
    await pumpUi(tester, OrganiserCard(name: 'TX', eventsCount: 14, onMessage: () => taps++));
    await tester.tap(find.byIcon(TablerIcons.message_circle));
    expect(taps, 1);
  });

  testWidgets('a logistics row sits on the 15 px icon line', (tester) async {
    await pumpUi(
      tester,
      const Align(alignment: Alignment.topLeft, child: LogisticsRow(icon: TablerIcons.calendar, text: 'A')),
    );
    expect(tester.getSize(find.byType(LogisticsRow)).height, closeTo(15 * 1.45, 0.5));
  });

  test('secret missions read on their own when none is shown', () {
    expect(secretMissionsLine(3, alone: true), '3 misiuni secrete');
    expect(secretMissionsLine(1, alone: true), 'O misiune secretă');
    expect(secretMissionsLine(3), 'Încă 3 misiuni secrete');
  });
}
