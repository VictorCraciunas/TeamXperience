import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/mission_list/mission_card.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/mission_list/mission_text_fields.dart';
import 'package:teamxperience/model/mission.dart';

import '../../../ui/pump_ui.dart';

void main() {
  testWidgets('shows what the mission has', (tester) async {
    await pumpUi(
      tester,
      MissionTextFields(
        mission: Mission(id: '0', title: 'Scara Pasajului', teaser: 'Numără treptele.', isTeaserPublic: true),
        onChanged: ({title, teaser, isTeaserPublic}) {},
      ),
    );
    expect(find.text('Scara Pasajului'), findsOneWidget);
    expect(find.text('Numără treptele.'), findsOneWidget);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
  });

  testWidgets('typing and switching report the change', (tester) async {
    final titles = <String?>[];
    final publics = <bool?>[];
    await pumpUi(
      tester,
      MissionTextFields(
        mission: Mission(id: '0'),
        onChanged: ({title, teaser, isTeaserPublic}) {
          if (title != null) titles.add(title);
          if (isTeaserPublic != null) publics.add(isTeaserPublic);
        },
      ),
    );
    await tester.enterText(find.byType(TextField).first, 'Podul Minciunilor');
    await tester.tap(find.byType(Switch));
    await tester.pump();
    expect(titles.last, 'Podul Minciunilor');
    expect(publics, [true]);
  });

  testWidgets('a mission card shows the title next to the number', (tester) async {
    await pumpUi(
      tester,
      MissionCard(index: 0, title: 'Scara Pasajului', puzzleCount: 1, status: 'Gata', done: true, onTap: () {}, onDelete: () {}),
    );
    expect(find.text('1 · Scara Pasajului'), findsOneWidget);
  });

  testWidgets('a mission card without a title keeps its old label', (tester) async {
    await pumpUi(
      tester,
      MissionCard(index: 1, puzzleCount: 0, status: 'Nu are puzzle-uri', done: false, onTap: () {}, onDelete: () {}),
    );
    expect(find.text('Misiunea 2'), findsOneWidget);
  });
}
