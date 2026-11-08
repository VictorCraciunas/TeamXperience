import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/features/event_details/logic/route_preview.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/service/event_service/event_completeness.dart';
import 'package:teamxperience/service/event_service/event_json_import.dart';
import 'package:teamxperience/utils/component_conversion/component_to_widget.dart';

import '../ui/pump_ui.dart';

/// Every example event in the docs must import, be publishable, be playable
/// (a code puzzle has an input of the right length and a button) and draw.
final _files = <File>[
  File('docs/event-import-sample.json'),
  ...Directory('docs/event-examples')
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.json')),
];

Event _load(File file) {
  final result = importEventFromJson(file.readAsStringSync());
  expect(result.errors, isEmpty, reason: file.path);
  return result.event!;
}

void main() {
  test('there are examples to check', () {
    expect(_files.length, greaterThanOrEqualTo(2));
  });

  for (final file in _files) {
    final name = file.path.replaceAll('\\', '/');

    group(name, () {
      test('imports without mistakes and could be published', () {
        final event = _load(file);
        expect(publishProblems(event).map((p) => p.text), isEmpty);
      });

      test('shows the route map on the event page', () {
        expect(routePreviewOf(_load(file)), isNotNull);
      });

      test('looks the same in the light and dark themes: the page and the text colours are set', () {
        final event = _load(file);
        final components = [...event.missions.expand((m) => m.puzzles).expand((p) => p.components)];
        expect(components.any((c) => c.frameBackgroundColor != null), isTrue);
        final written = components.where((c) => c.type == ComponentType.text || c.type == ComponentType.code);
        expect(written.map((c) => c.textColor), everyElement(isNotNull));
      });

      test('every code puzzle can be solved', () {
        final event = _load(file);
        for (final puzzle in event.missions.expand((m) => m.puzzles)) {
          if (puzzle.type != PuzzleType.code) continue;
          final input = puzzle.components.where((c) => c.type == ComponentType.code);
          expect(input, hasLength(1), reason: 'puzzle ${puzzle.id} needs one code input');
          expect(input.single.codeLength, puzzle.code?.length, reason: 'puzzle ${puzzle.id}: boxes and answer');
          expect(
            puzzle.components.any((c) => c.type == ComponentType.button),
            isTrue,
            reason: 'puzzle ${puzzle.id} needs a button to submit',
          );
        }
      });

      test('a background that is not a link is a picture inside the app', () {
        final path = _load(file).taskBackgroundImageUrl;
        if (path == null || path.startsWith('http')) return;
        expect(File(path).existsSync(), isTrue, reason: path);
      });

      testWidgets('every component draws on a phone-width screen', (tester) async {
        final event = _load(file);
        final components = <Component>[
          for (final mission in event.missions)
            for (final puzzle in mission.puzzles) ...puzzle.components,
        ];
        for (final component in components) {
          await pumpUi(
            tester,
            SingleChildScrollView(child: ComponentToWidget().convert(component)),
            width: 360,
          );
          await tester.pump(const Duration(milliseconds: 100));
          expect(tester.takeException(), isNull, reason: '${component.type?.name}: ${component.text ?? ''}');
        }
      });
    });
  }
}
