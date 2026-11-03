import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/dev/event_page_preview.dart';
import 'package:teamxperience/dev/event_page_preview_launcher.dart';
import 'package:teamxperience/ui/ui.dart';

void main() {
  for (final entry in {'light': AppTheme.light, 'dark': AppTheme.dark}.entries) {
    testWidgets('the event page preview renders in ${entry.key}', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(theme: entry.value, home: const EventPagePreview()));
      expect(tester.takeException(), isNull);
      expect(find.text('Moștenirea Cartografului'), findsOneWidget);
      expect(find.text('Mai sunt 3 zile'), findsOneWidget);
    });
  }

  testWidgets('the switch shows the other bar states', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: const EventPagePreview()));
    await tester.tap(find.text('Înscriși'));
    await tester.pump();
    expect(find.text('Echipa ta'), findsOneWidget);
    await tester.tap(find.text('Start'));
    await tester.pump();
    expect(find.text('Introdu codul'), findsOneWidget);
  });

  testWidgets('the gallery opens the preview', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: const EventPagePreviewLauncher()));
    await tester.tap(find.text('Pagina evenimentului'));
    await tester.pumpAndSettle();
    expect(find.byType(EventPagePreview), findsOneWidget);
  });
}
