import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/register_team/widgets/crew_choice.dart';
import 'package:teamxperience/features/register_team/widgets/edit_toggle.dart';
import 'package:teamxperience/model/crew.dart';

import '../../ui/pump_ui.dart';

const _crew = Crew(
  id: 'c1',
  name: 'Vulpile Argintii din Sibiu',
  captainUid: 'u1',
  memberUids: ['u1'],
  members: [],
  inviteCode: 'VLP482',
);

void main() {
  testWidgets('no toggle for a new team', (tester) async {
    await pumpUi(tester, CrewChoice(crews: const [_crew], chosen: null, onChoose: (_) {}, editing: false, onToggleEdit: () {}));
    expect(find.byType(EditToggle), findsNothing);
  });

  testWidgets('a chosen team: Editează then Anulează, easy to tap, fits at 320 wide and 1.3x text', (tester) async {
    var taps = 0;
    Widget choice(bool editing) =>
        CrewChoice(crews: const [_crew], chosen: _crew, onChoose: (_) {}, editing: editing, onToggleEdit: () => taps++);

    await pumpUi(tester, choice(false), width: 320, textScale: 1.3);
    expect(tester.takeException(), isNull);
    expect(find.text('Editează'), findsOneWidget);
    expect(tester.getSize(find.byType(EditToggle)).height, greaterThanOrEqualTo(44));
    await tester.tap(find.text('Editează'));
    expect(taps, 1);

    await pumpUi(tester, choice(true), width: 320, textScale: 1.3);
    expect(find.text('Anulează'), findsOneWidget);
  });
}
