import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/event_details/logic/event_page_content.dart';
import 'package:teamxperience/features/event_details/widgets/organiser_card.dart';

import '../../ui/pump_ui.dart';

void main() {
  testWidgets('the message button still answers taps', (tester) async {
    var taps = 0;
    await pumpUi(tester, OrganiserCard(name: 'TX', eventsCount: 14, onMessage: () => taps++));
    await tester.tap(find.byIcon(TablerIcons.message_circle));
    expect(taps, 1);
  });

  test('secret missions read on their own when none is shown', () {
    expect(secretMissionsLine(3, alone: true), '3 misiuni secrete');
    expect(secretMissionsLine(1, alone: true), 'O misiune secretă');
    expect(secretMissionsLine(3), 'Încă 3 misiuni secrete');
  });
}
