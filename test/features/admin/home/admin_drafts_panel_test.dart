import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/admin/home/widgets/admin_drafts_panel.dart';
import 'package:teamxperience/model/event.dart';

import '../../../ui/pump_ui.dart';

Event _draft(String id, String? name) => Event(eventId: id, name: name);

void main() {
  testWidgets('shows the title, the count and one row per draft', (tester) async {
    await pumpUi(
      tester,
      AdminDraftsPanel(drafts: [_draft('a', 'Sibiu Hunt'), _draft('b', 'Brașov')], onTap: (_) {}),
    );
    expect(find.text('Ciorne'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('Sibiu Hunt'), findsOneWidget);
    expect(find.text('Brașov'), findsOneWidget);
  });

  testWidgets('a draft without a name is still listed', (tester) async {
    await pumpUi(tester, AdminDraftsPanel(drafts: [_draft('a', null)], onTap: (_) {}));
    expect(find.text('Fără nume'), findsOneWidget);
  });

  testWidgets('each row says what is still missing', (tester) async {
    await pumpUi(tester, AdminDraftsPanel(drafts: [_draft('a', 'Sibiu Hunt')], onTap: (_) {}));
    expect(find.textContaining('Gata de publicat'), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('tapping a row opens that draft', (tester) async {
    Event? opened;
    await pumpUi(
      tester,
      AdminDraftsPanel(drafts: [_draft('a', 'Sibiu Hunt')], onTap: (e) => opened = e),
    );
    await tester.tap(find.text('Sibiu Hunt'));
    expect(opened?.eventId, 'a');
  });

  testWidgets('with no drafts nothing is drawn', (tester) async {
    await pumpUi(tester, AdminDraftsPanel(drafts: const [], onTap: (_) {}));
    expect(find.text('Ciorne'), findsNothing);
  });
}
