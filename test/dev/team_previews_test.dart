import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/dev/join_team_preview.dart';
import 'package:teamxperience/dev/register_team_preview.dart';
import 'package:teamxperience/dev/team_previews_launcher.dart';
import 'package:teamxperience/dev/teams_preview.dart';
import 'package:teamxperience/ui/ui.dart';

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

void main() {
  for (final entry
      in {'light': AppTheme.light, 'dark': AppTheme.dark}.entries) {
    testWidgets('the register preview renders in ${entry.key}', (tester) async {
      _phone(tester);
      await tester.pumpWidget(
        MaterialApp(theme: entry.value, home: const RegisterTeamPreview()),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Numele e liber'), findsOneWidget);
      expect(find.text('Înscrie echipa'), findsWidgets);

      await tester.tap(find.text('După înscriere'));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('VLP-482'), findsOneWidget);
      expect(find.text('1 din 4 în echipă'), findsOneWidget);
    });

    testWidgets('the join preview renders in ${entry.key}', (tester) async {
      _phone(tester);
      await tester.pumpWidget(
        MaterialApp(theme: entry.value, home: const JoinTeamPreview()),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Vulpile'), findsWidgets);
      expect(find.text('Intră în Vulpile'), findsOneWidget);

      await tester.tap(find.text('Problemă'));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('Codul nu există'), findsOneWidget);

      await tester.tap(find.text('Scrie'));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('Intră în echipă'), findsOneWidget);
    });

    testWidgets('the Echipe preview renders in ${entry.key}', (tester) async {
      _phone(tester);
      await tester.pumpWidget(
        MaterialApp(theme: entry.value, home: const TeamsPreview()),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Vulpile'), findsOneWidget);
      expect(find.text('VLP-482'), findsOneWidget);

      await tester.tap(find.text('Fără echipe'));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('Nu ești încă într-o echipă.'), findsOneWidget);
    });
  }

  testWidgets('the launcher opens each preview', (tester) async {
    _phone(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: TeamPreviewsLauncher()),
      ),
    );

    final opened = {
      'Înscrierea echipei': RegisterTeamPreview,
      'Intră într-o echipă': JoinTeamPreview,
      'Echipe': TeamsPreview,
    };
    for (final entry in opened.entries) {
      await tester.tap(find.text(entry.key));
      await tester.pumpAndSettle();
      expect(find.byType(entry.value), findsOneWidget);
      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pumpAndSettle();
    }
  });
}
