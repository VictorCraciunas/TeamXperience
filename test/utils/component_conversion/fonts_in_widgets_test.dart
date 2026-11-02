import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/utils/component_conversion/component_to_widget.dart';
import 'package:teamxperience/utils/event_fonts.dart';

import '../../ui/pump_ui.dart';

Future<void> _draw(WidgetTester tester, Component component) {
  return pumpUi(tester, Column(children: [ComponentToWidget().convert(component)]), width: 360);
}

double? _wght(TextStyle? style) {
  final variations = style?.fontVariations;
  if (variations == null || variations.isEmpty) return null;
  return variations.firstWhere((v) => v.axis == 'wght').value;
}

void main() {
  group('text', () {
    testWidgets('uses the font it was given', (tester) async {
      await _draw(tester, Component(type: ComponentType.text, text: 'Salut', fontFamily: 'Cinzel', fontWeight: 'Bold (700)'));
      final style = tester.widget<Text>(find.text('Salut')).style;
      expect(style?.fontFamily, 'Cinzel');
    });

    testWidgets('a variable font gets the weight as a variation', (tester) async {
      await _draw(tester, Component(type: ComponentType.text, text: 'Salut', fontFamily: 'Orbitron', fontWeight: 'Black (900)'));
      expect(_wght(tester.widget<Text>(find.text('Salut')).style), 900);
    });

    testWidgets('a font with one weight gets no variation', (tester) async {
      await _draw(tester, Component(type: ComponentType.text, text: 'Salut', fontFamily: 'Bebas Neue', fontWeight: 'Bold (700)'));
      expect(_wght(tester.widget<Text>(find.text('Salut')).style), isNull);
    });

    testWidgets('Poppins is drawn as before', (tester) async {
      await _draw(tester, Component(type: ComponentType.text, text: 'Salut', fontFamily: 'Poppins', fontWeight: 'Bold (700)'));
      final style = tester.widget<Text>(find.text('Salut')).style;
      expect(style?.fontFamily, 'Poppins');
      expect(_wght(style), isNull);
    });

    testWidgets('the typewriter keeps the font and the weight too', (tester) async {
      await _draw(
        tester,
        Component(type: ComponentType.text, text: 'Salut', fontFamily: 'Caveat', fontWeight: 'Bold (700)', animation: null),
      );
      expect(_wght(tester.widget<Text>(find.text('Salut')).style), 700);
    });
  });

  group('button', () {
    testWidgets('uses the font and the weight', (tester) async {
      await _draw(
        tester,
        Component(type: ComponentType.button, buttonLabel: 'OK', fontFamily: 'Playfair Display', fontWeight: 'Bold (700)'),
      );
      final style = tester.widget<Text>(find.text('OK')).style;
      expect(style?.fontFamily, 'Playfair Display');
      expect(_wght(style), 700);
    });

    testWidgets('a button without a font is Poppins, as before', (tester) async {
      await _draw(tester, Component(type: ComponentType.button, buttonLabel: 'OK'));
      expect(tester.widget<Text>(find.text('OK')).style?.fontFamily, 'Poppins');
    });
  });

  group('code input', () {
    testWidgets('uses the font and, when bold, the heaviest weight', (tester) async {
      await _draw(tester, Component(type: ComponentType.code, codeLength: 3, inputType: 'Separated', fontFamily: 'Orbitron'));
      final style = tester.widget<TextField>(find.byType(TextField).first).style;
      expect(style?.fontFamily, 'Orbitron');
      expect(_wght(style), 700);
    });

    testWidgets('not bold gives the regular weight of a variable font', (tester) async {
      await _draw(
        tester,
        Component(type: ComponentType.code, codeLength: 3, inputType: 'Separated', fontFamily: 'Orbitron', boldText: false),
      );
      expect(_wght(tester.widget<TextField>(find.byType(TextField).first).style), 400);
    });

    testWidgets('a font with one weight gets no variation', (tester) async {
      await _draw(tester, Component(type: ComponentType.code, codeLength: 3, inputType: 'Free', fontFamily: 'Press Start 2P'));
      expect(_wght(tester.widget<TextField>(find.byType(TextField).first).style), isNull);
    });
  });

  group('every font of the app', () {
    for (final font in eventFonts) {
      testWidgets('${font.family} draws a text, a button and a code input at phone width', (tester) async {
        for (final component in [
          Component(type: ComponentType.text, text: 'Operațiunea Zero-Day: Serverul a fost localizat', fontFamily: font.family, fontSize: 24, fontWeight: 'Bold (700)'),
          Component(type: ComponentType.button, buttonLabel: 'EXECUTĂ', fontFamily: font.family, fontSize: 16),
          Component(type: ComponentType.code, codeLength: 8, inputType: 'Separated', fontFamily: font.family, fontSize: 22),
        ]) {
          await _draw(tester, component);
          expect(tester.takeException(), isNull, reason: '${font.family} ${component.type?.name}');
        }
      });
    }
  });
}
