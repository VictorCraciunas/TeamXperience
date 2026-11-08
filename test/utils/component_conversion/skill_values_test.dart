import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/animation_type.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/features/event_details/logic/route_preview.dart';
import 'package:teamxperience/features/event_game/logic/style_hints.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/service/event_service/event_completeness.dart';
import 'package:teamxperience/service/event_service/event_json_import.dart';
import 'package:teamxperience/utils/component_conversion/component_to_widget.dart';
import 'package:teamxperience/utils/event_fonts.dart';

import '../../ui/pump_ui.dart';

/// Everything docs/skills/event-json/SKILL.md says is allowed must draw on a
/// phone-width screen, at both ends of every range it gives.
Future<void> _draw(WidgetTester tester, Component component) async {
  await pumpUi(
    tester,
    SingleChildScrollView(child: ComponentToWidget().convert(component)),
    width: 360,
  );
  await tester.pump(const Duration(milliseconds: 50));
  expect(tester.takeException(), isNull);
}

const _weights = ['Thin (100)', 'Light (300)', 'Regular (400)', 'Medium (500)', 'Bold (700)', 'Black (900)'];
final _fonts = eventFontNames;
const _aligns = ['left', 'center', 'right', 'justify'];

/// The first ```json block after a heading of the skill file.
String _jsonAfter(String heading) {
  final text = File('docs/skills/event-json/SKILL.md').readAsStringSync().replaceAll('\r\n', '\n');
  final start = text.indexOf(heading);
  expect(start, greaterThanOrEqualTo(0), reason: heading);
  final open = text.indexOf('```json\n', start) + '```json\n'.length;
  final close = text.indexOf('\n```', open);
  return text.substring(open, close);
}

/// A part of the skill file, from one heading up to the next one named.
String _section(String from, String to) {
  final text = File('docs/skills/event-json/SKILL.md').readAsStringSync().replaceAll('\r\n', '\n');
  return text.substring(text.indexOf(from), text.indexOf(to));
}

/// Every key the import reads, taken from the import itself.
Set<String> _importedKeys() {
  final source = File('lib/service/event_service/event_json_import.dart').readAsStringSync();
  return RegExp(r"reader\.\w+\('(\w+)'").allMatches(source).map((m) => m.group(1) ?? '').toSet();
}

void main() {
  group('the skill keeps up with the app', () {
    test('every key the import reads is in the shape and has a row', () {
      final keys = _importedKeys();
      expect(keys, isNotEmpty);
      final shape = _section('## The whole shape', '## Small example');
      final rows = _section('## Every field and what it can hold', '### Fonts');
      for (final key in keys) {
        expect(shape, matches(RegExp('^  $key\\??:', multiLine: true)), reason: '$key is not in the shape');
        expect(rows, contains('`$key`'), reason: '$key has no row');
      }
    });

    test('the shape has no key the import would ignore', () {
      final keys = _importedKeys();
      final shape = _section('## The whole shape', '## Small example');
      final written = RegExp(r'^  (\w+)\??:', multiLine: true).allMatches(shape).map((m) => m.group(1) ?? '');
      expect(written.where((key) => !keys.contains(key)), isEmpty);
    });

    test('every font of the app is listed', () {
      final fonts = _section('### Fonts', '### Colours');
      for (final name in eventFontNames) {
        expect(fonts, contains('`"$name"`'));
      }
    });
  });

  group('the example inside the skill', () {
    test('shows the route map, and the line bends with its mission', () {
      final event = importEventFromJson(_jsonAfter('## Small example')).event;
      final preview = event == null ? null : routePreviewOf(event);
      expect(preview?.line.length, greaterThan(2));
    });

    test('looks the same in the light and dark themes: the page and the text colours are set', () {
      final event = importEventFromJson(_jsonAfter('## Small example')).event;
      final components = [...?event?.missions.expand((m) => m.puzzles).expand((p) => p.components)];
      expect(styleHintsFrom(components, null).background, isNotNull);
      final written = components.where((c) => c.type == ComponentType.text || c.type == ComponentType.code);
      expect(written, isNotEmpty);
      expect(written.map((c) => c.textColor), everyElement(isNotNull));
    });

    test('is valid JSON the app imports without mistakes', () {
      final result = importEventFromJson(_jsonAfter('## Small example'));
      expect(result.errors, isEmpty);
    });

    test('can be published as it is', () {
      final event = importEventFromJson(_jsonAfter('## Small example')).event;
      expect(event, isNotNull);
      if (event != null) expect(publishProblems(event).map((p) => p.text), isEmpty);
    });

    test('has a code puzzle that can be solved: answer length equals the boxes and a button is there', () {
      final event = importEventFromJson(_jsonAfter('## Small example')).event;
      final puzzle = event?.missions.first.puzzles.first;
      final codeBox = puzzle?.components.firstWhere((c) => c.type == ComponentType.code);
      expect(codeBox?.codeLength, puzzle?.code?.length);
      expect(puzzle?.components.any((c) => c.type == ComponentType.button), isTrue);
    });

    test('is plain JSON: no comments and no trailing commas', () {
      expect(() => jsonDecode(_jsonAfter('## Small example')), returnsNormally);
    });

    testWidgets('every component of it draws', (tester) async {
      final event = importEventFromJson(_jsonAfter('## Small example')).event;
      final components = event?.missions.expand((m) => m.puzzles).expand((p) => p.components) ?? [];
      expect(components, isNotEmpty);
      for (final component in components) {
        await _draw(tester, component);
      }
    });
  });

  group('text', () {
    for (final weight in _weights) {
      testWidgets('weight $weight', (tester) async {
        await _draw(tester, Component(type: ComponentType.text, text: 'Salut', fontWeight: weight));
      });
    }
    for (final font in _fonts) {
      testWidgets('font $font', (tester) async {
        await _draw(tester, Component(type: ComponentType.text, text: 'Salut', fontFamily: font));
      });
    }
    for (final align in _aligns) {
      testWidgets('align $align', (tester) async {
        await _draw(tester, Component(type: ComponentType.text, text: 'Salut', textAlign: align));
      });
    }
    for (final size in [8.0, 72.0]) {
      testWidgets('a long sentence at size $size', (tester) async {
        await _draw(
          tester,
          Component(
            type: ComponentType.text,
            text: 'Du-te la Podul Minciunilor și caută inscripția de pe cea de-a treia piatră.',
            fontSize: size,
          ),
        );
      });
    }
    for (final animation in AnimationType.values) {
      testWidgets('animation ${animation.name}', (tester) async {
        await _draw(
          tester,
          Component(type: ComponentType.text, text: 'Salut', animation: animation, typewriterSpeed: 10),
        );
        await tester.pump(const Duration(seconds: 1));
        expect(tester.takeException(), isNull);
      });
    }
    testWidgets('typewriter at the slowest speed', (tester) async {
      await _draw(
        tester,
        Component(type: ComponentType.text, text: 'Salut', animation: AnimationType.typewriter, typewriterSpeed: 300),
      );
    });
  });

  group('button', () {
    for (final weight in _weights) {
      testWidgets('weight $weight', (tester) async {
        await _draw(tester, Component(type: ComponentType.button, buttonLabel: 'Verifică', fontWeight: weight));
      });
    }
    for (final font in _fonts) {
      testWidgets('font $font', (tester) async {
        await _draw(tester, Component(type: ComponentType.button, buttonLabel: 'Verifică', fontFamily: font));
      });
    }
    for (final radius in [0.0, 50.0]) {
      testWidgets('corner radius $radius', (tester) async {
        await _draw(tester, Component(type: ComponentType.button, buttonLabel: 'Verifică', cornerRadius: radius));
      });
    }
    for (final size in [8.0, 72.0]) {
      testWidgets('font size $size', (tester) async {
        await _draw(tester, Component(type: ComponentType.button, buttonLabel: 'Verifică', fontSize: size));
      });
    }
    testWidgets('a long label', (tester) async {
      await _draw(tester, Component(type: ComponentType.button, buttonLabel: 'Am găsit comoara, verifică acum', fontSize: 20));
    });
    testWidgets('glow and flicker', (tester) async {
      await _draw(
        tester,
        Component(
          type: ComponentType.button,
          buttonLabel: 'Verifică',
          enableGlow: true,
          glowColor: '#33FF66',
          enableFlicker: true,
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
    });
    testWidgets('all colours', (tester) async {
      await _draw(
        tester,
        Component(
          type: ComponentType.button,
          buttonLabel: 'Verifică',
          buttonColor: '#33FF66',
          buttonColorOnTap: '#1FA34A',
          buttonTextColor: '#000000',
          buttonTextColorOnTap: '#FFFFFF',
          borderColor: '#2AA5A9',
        ),
      );
    });
  });

  group('code input', () {
    for (final length in [1, 4, 5, 6, 10]) {
      for (final type in ['Separated', 'Free']) {
        testWidgets('$length characters, $type', (tester) async {
          await _draw(tester, Component(type: ComponentType.code, codeLength: length, inputType: type));
        });
      }
    }
    for (final caps in ['CapsLock', 'Fără']) {
      testWidgets('caps $caps', (tester) async {
        await _draw(tester, Component(type: ComponentType.code, codeLength: 4, inputType: 'Separated', capsLock: caps));
      });
    }
    for (final font in _fonts) {
      testWidgets('font $font', (tester) async {
        await _draw(tester, Component(type: ComponentType.code, codeLength: 4, inputType: 'Separated', fontFamily: font));
      });
    }
    // The skill allows a box width from 0 to 200: on a 360 wide phone, 5 boxes of 200 do not fit.
    for (final width in [0.0, 50.0, 200.0]) {
      testWidgets('box width $width, 4 characters', (tester) async {
        await _draw(tester, Component(type: ComponentType.code, codeLength: 4, inputType: 'Separated', width: width));
      });
      testWidgets('box width $width, 10 characters', (tester) async {
        await _draw(tester, Component(type: ComponentType.code, codeLength: 10, inputType: 'Separated', width: width));
      });
    }
    for (final radius in [0.0, 50.0]) {
      testWidgets('corner radius $radius', (tester) async {
        await _draw(
          tester,
          Component(
            type: ComponentType.code,
            codeLength: 4,
            inputType: 'Separated',
            frameCornerRadius: radius,
            inputCornerRadius: radius,
          ),
        );
      });
    }
    for (final size in [8.0, 72.0]) {
      testWidgets('font size $size', (tester) async {
        await _draw(tester, Component(type: ComponentType.code, codeLength: 4, inputType: 'Separated', fontSize: size));
      });
    }
    testWidgets('all colours and glow', (tester) async {
      await _draw(
        tester,
        Component(
          type: ComponentType.code,
          codeLength: 4,
          inputType: 'Separated',
          textColor: '#FFFFFF',
          frameBackgroundColor: '#101820',
          inputBackgroundColor: '#1B2A38',
          colorBorderContainer: '#2AA5A9',
          colorBorderInput: '#33FF66',
          enableGlow: true,
          glowColor: '#33FF66',
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
    });
  });

  group('the options added for the button and the code input', () {
    for (final spacing in [0.0, 12.0]) {
      for (final padding in [0.0, 30.0]) {
        testWidgets('button, spacing $spacing and padding $padding', (tester) async {
          await _draw(
            tester,
            Component(type: ComponentType.button, buttonLabel: 'Am găsit comoara, verifică', letterSpacing: spacing, paddingY: padding),
          );
        });
      }
    }
    for (final height in [20.0, 100.0]) {
      for (final length in [1, 10]) {
        testWidgets('code, box height $height with $length characters', (tester) async {
          await _draw(tester, Component(type: ComponentType.code, codeLength: length, inputType: 'Separated', boxHeight: height));
        });
      }
    }
    for (final place in ['frame', 'boxes']) {
      for (final type in ['Separated', 'Free']) {
        testWidgets('code, glow on $place, $type, not bold', (tester) async {
          await _draw(
            tester,
            Component(
              type: ComponentType.code,
              codeLength: 10,
              inputType: type,
              enableGlow: true,
              glowColor: '#33FF66',
              glowOn: place,
              boldText: false,
            ),
          );
          await tester.pump(const Duration(seconds: 1));
          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  group('the text effects at both ends', () {
    for (final value in [0.0, 12.0]) {
      testWidgets('letter spacing $value on a long text', (tester) async {
        await _draw(tester, Component(type: ComponentType.text, text: 'Serverul fizic a fost localizat. Mergi la punctul marcat.', letterSpacing: value, fontSize: 24));
      });
    }
    for (final value in [0.8, 2.0]) {
      testWidgets('line height $value', (tester) async {
        await _draw(tester, Component(type: ComponentType.text, text: 'Serverul fizic a fost localizat. Mergi la punctul marcat pe hartă.', lineHeight: value, fontSize: 24));
      });
    }
    for (final blur in [0.0, 30.0]) {
      for (final distance in [0.0, 20.0]) {
        testWidgets('shadow blur $blur distance $distance', (tester) async {
          await _draw(tester, Component(type: ComponentType.text, text: 'Salut', shadowBlur: blur, shadowDistance: distance, shadowColor: '#000000', fontSize: 30));
        });
      }
    }
    testWidgets('glow, italic and capitals together', (tester) async {
      await _draw(
        tester,
        Component(type: ComponentType.text, text: 'Operațiunea Zero-Day', italic: true, uppercase: true, enableGlow: true, glowColor: '#33FF66', fontSize: 28),
      );
    });
  });

  group('the box effects at both ends', () {
    for (final type in ComponentType.values) {
      for (final opacity in [0.0, 1.0]) {
        testWidgets('opacity $opacity on ${type.name}', (tester) async {
          await _draw(tester, Component(type: type, text: 'x', buttonLabel: 'x', codeLength: 4, inputType: 'Separated', opacity: opacity));
        });
      }
    }
    for (final type in [ComponentType.image, ComponentType.button, ComponentType.code]) {
      for (final blur in [0.0, 30.0]) {
        for (final distance in [0.0, 20.0]) {
          testWidgets('shadow blur $blur distance $distance on ${type.name}', (tester) async {
            await _draw(
              tester,
              Component(type: type, buttonLabel: 'x', codeLength: 10, inputType: 'Separated', shadowBlur: blur, shadowDistance: distance, shadowColor: '#000000'),
            );
          });
        }
      }
    }
    for (final width in [0.0, 6.0]) {
      testWidgets('border width $width on an image and a button', (tester) async {
        await _draw(tester, Component(type: ComponentType.image, borderWidth: width, borderColor: '#33FF66'));
        await _draw(tester, Component(type: ComponentType.button, buttonLabel: 'OK', borderWidth: width));
      });
    }
    testWidgets('a glowing image with a shadow and a border', (tester) async {
      await _draw(
        tester,
        Component(type: ComponentType.image, enableGlow: true, glowColor: '#33FF66', shadowBlur: 10, shadowDistance: 5, borderWidth: 3, borderColor: '#FFFFFF'),
      );
    });
  });

  group('image', () {
    for (final radius in [0.0, 50.0]) {
      testWidgets('corner radius $radius', (tester) async {
        await _draw(tester, Component(type: ComponentType.image, cornerRadius: radius));
      });
    }
    for (final height in [150.0, 500.0]) {
      testWidgets('height $height', (tester) async {
        await _draw(tester, Component(type: ComponentType.image, height: height));
      });
    }
  });
}
