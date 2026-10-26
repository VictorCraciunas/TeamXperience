import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/model/mission.dart';
import 'package:teamxperience/service/event_service/event_json_import.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';
import 'package:teamxperience/utils/component_conversion/component_to_widget.dart';

/// Components written by hand (or imported from JSON) often leave most options
/// out. Every kind must still draw, with the app's own look for what is missing.
Future<void> _draw(WidgetTester tester, Component component) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: SingleChildScrollView(child: ComponentToWidget().convert(component)),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('a component with only its type', () {
    for (final type in ComponentType.values) {
      testWidgets('${type.name} draws', (tester) async {
        await _draw(tester, Component(type: type));
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('options that used to be forced', () {
    testWidgets('a code input without a font, in separated mode', (tester) async {
      await _draw(tester, Component(type: ComponentType.code, codeLength: 4, inputType: 'Separated'));
      expect(tester.takeException(), isNull);
      expect(find.byType(TextField), findsNWidgets(4));
    });

    testWidgets('a code input without a font, in free mode', (tester) async {
      await _draw(tester, Component(type: ComponentType.code, inputType: 'Free'));
      expect(tester.takeException(), isNull);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('a button without a label or rounded corners', (tester) async {
      await _draw(tester, Component(type: ComponentType.button));
      expect(tester.takeException(), isNull);
    });

    testWidgets('a button with a label but no corners keeps its label', (tester) async {
      await _draw(tester, Component(type: ComponentType.button, buttonLabel: 'Verifică'));
      expect(find.text('Verifică'), findsOneWidget);
    });
  });

  group('every component of the example in docs', () {
    final text = File('docs/event-import-sample.json').readAsStringSync();
    final event = importEventFromJson(text).event;
    final components = <Component>[
      for (final mission in event?.missions ?? <Mission>[])
        for (final puzzle in mission.puzzles) ...puzzle.components,
    ];

    test('there are some to check', () {
      expect(components, isNotEmpty);
    });

    for (var i = 0; i < components.length; i++) {
      testWidgets('component ${i + 1} (${components[i].type?.name}) draws', (tester) async {
        await _draw(tester, components[i]);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
