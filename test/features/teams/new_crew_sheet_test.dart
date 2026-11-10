import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/teams/widgets/new_crew_sheet.dart';
import 'package:teamxperience/ui/components/buttons/navy_button.dart';
import 'package:teamxperience/ui/components/team/invite_code_card.dart';

import '../../ui/pump_ui.dart';

NavyButton _create(WidgetTester tester) =>
    tester.widget<NavyButton>(find.byType(NavyButton));

void main() {
  testWidgets('"Creează" waits for a valid name, then shows the new code', (
    tester,
  ) async {
    final created = <String>[];
    final shared = <String>[];
    final hold = Completer<void>();
    await pumpUi(
      tester,
      NewCrewSheet(
        onCreate: (name) async {
          created.add(name);
          await hold.future;
          return 'VLP-482';
        },
        onShare: (name, code) => shared.add('$name $code'),
        onCopy: (_) {},
      ),
    );
    expect(find.text('Echipă nouă'), findsOneWidget);
    expect(_create(tester).onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'V');
    await tester.pump();
    expect(_create(tester).onPressed, isNull);

    await tester.enterText(find.byType(TextField), '  Vulpile   Argintii ');
    await tester.pump();
    await tester.tap(find.text('Creează'));
    await tester.pump();
    expect(created, ['Vulpile Argintii']);
    expect(_create(tester).isLoading, isTrue);

    hold.complete();
    await tester.pump();
    await tester.pump();
    expect(find.byType(InviteCodeCard), findsOneWidget);
    expect(find.text('VLP-482'), findsOneWidget);
    expect(find.text('Vulpile Argintii'), findsOneWidget);

    await tester.tap(find.text('Trimite'));
    expect(shared, ['Vulpile Argintii VLP-482']);
  });

  testWidgets('a refused name stays on the form with the error text', (
    tester,
  ) async {
    await pumpUi(
      tester,
      NewCrewSheet(
        onCreate:
            (_) async =>
                throw FirebaseFunctionsException(
                  message: 'offline',
                  code: 'unavailable',
                ),
        onShare: (_, _) {},
        onCopy: (_) {},
      ),
    );
    await tester.enterText(find.byType(TextField), 'Vulpile');
    await tester.pump();
    await tester.tap(find.text('Creează'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Nu a mers. Verifică internetul.'), findsOneWidget);
    expect(find.byType(InviteCodeCard), findsNothing);
    expect(_create(tester).isLoading, isFalse);
    expect(_create(tester).onPressed, isNotNull);
  });

  testWidgets('lays out at 320 wide and 1.3x text', (tester) async {
    await pumpUi(
      tester,
      NewCrewSheet(
        onCreate: (_) async => 'VLP-482',
        onShare: (_, _) {},
        onCopy: (_) {},
      ),
      width: 320,
      textScale: 1.3,
    );
    expect(tester.takeException(), isNull);
  });
}
