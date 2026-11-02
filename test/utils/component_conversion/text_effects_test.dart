import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/animation_type.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/utils/component_conversion/component_to_widget.dart';

import '../../ui/pump_ui.dart';

Component _text(
  String text, {
  double? letterSpacing,
  double? lineHeight,
  bool? italic,
  bool? uppercase,
  bool? glow,
  String? glowColor,
  String? textColor,
  String? shadowColor,
  double? shadowBlur,
  double? shadowDistance,
  AnimationType? animation,
}) => Component(
      type: ComponentType.text,
      text: text,
      fontSize: 18,
      textColor: textColor,
      letterSpacing: letterSpacing,
      lineHeight: lineHeight,
      italic: italic,
      uppercase: uppercase,
      enableGlow: glow,
      glowColor: glowColor,
      shadowColor: shadowColor,
      shadowBlur: shadowBlur,
      shadowDistance: shadowDistance,
      animation: animation,
      typewriterSpeed: 10,
    );

Future<void> _draw(WidgetTester tester, Component component) {
  return pumpUi(tester, Column(children: [ComponentToWidget().convert(component)]), width: 360);
}

/// The style of the text on screen. The typewriter draws it as spans, a normal
/// text as one style.
TextStyle _style(WidgetTester tester) {
  final rich = tester.widget<RichText>(find.byType(RichText).first);
  final root = rich.text as TextSpan;
  final inner = root.children?.isNotEmpty == true ? root.children!.first : null;
  if (inner is TextSpan && inner.children != null && inner.children!.isNotEmpty) {
    return root.style!.merge(inner.style);
  }
  return root.style!;
}

String _shown(WidgetTester tester) {
  final rich = tester.widget<RichText>(find.byType(RichText).first);
  return rich.text.toPlainText();
}

void main() {
  group('nothing chosen', () {
    testWidgets('changes nothing about how a text looks', (tester) async {
      await _draw(tester, _text('Salut'));
      final style = _style(tester);
      final theme = Theme.of(tester.element(find.byType(RichText).first)).textTheme.bodyMedium!;
      expect(style.letterSpacing, theme.letterSpacing, reason: 'what the theme gives, nothing added');
      expect(style.height, theme.height);
      expect(style.fontStyle, anyOf(isNull, FontStyle.normal));
      expect(style.shadows, isNull);
      expect(_shown(tester), 'Salut');
    });
  });

  group('letter spacing', () {
    testWidgets('is applied', (tester) async {
      await _draw(tester, _text('Salut', letterSpacing: 4));
      expect(_style(tester).letterSpacing, 4);
    });

    testWidgets('0 is a real choice', (tester) async {
      await _draw(tester, _text('Salut', letterSpacing: 0));
      expect(_style(tester).letterSpacing, 0);
    });
  });

  group('line height', () {
    testWidgets('is applied', (tester) async {
      await _draw(tester, _text('Salut', lineHeight: 1.6));
      expect(_style(tester).height, 1.6);
    });

    testWidgets('makes a wrapped text taller', (tester) async {
      const long = 'Serverul fizic a fost localizat. Mergi la punctul marcat pe hartă pentru a-l conecta rapid.';
      await _draw(tester, _text(long));
      final usual = tester.getSize(find.byType(RichText).first).height;
      await _draw(tester, _text(long, lineHeight: 2.0));
      expect(tester.getSize(find.byType(RichText).first).height, greaterThan(usual));
    });
  });

  group('italic', () {
    testWidgets('on', (tester) async {
      await _draw(tester, _text('Salut', italic: true));
      expect(_style(tester).fontStyle, FontStyle.italic);
    });

    testWidgets('off', (tester) async {
      await _draw(tester, _text('Salut', italic: false));
      expect(_style(tester).fontStyle, anyOf(isNull, FontStyle.normal));
    });
  });

  group('capitals', () {
    testWidgets('on: the text is shown in capitals, with the diacritics', (tester) async {
      await _draw(tester, _text('Operațiunea în Sibiu', uppercase: true));
      expect(_shown(tester), 'OPERAȚIUNEA ÎN SIBIU');
    });

    testWidgets('off: the text is as written', (tester) async {
      await _draw(tester, _text('Operațiunea în Sibiu', uppercase: false));
      expect(_shown(tester), 'Operațiunea în Sibiu');
    });
  });

  group('glow', () {
    testWidgets('a glow in the colour asked for', (tester) async {
      await _draw(tester, _text('Salut', glow: true, glowColor: '#33FF66'));
      final shadows = _style(tester).shadows!;
      expect(shadows, isNotEmpty);
      expect(shadows.every((s) => s.color == const Color(0xFF33FF66)), isTrue);
      expect(shadows.every((s) => s.blurRadius > 0), isTrue);
      expect(shadows.every((s) => s.offset == Offset.zero), isTrue);
    });

    testWidgets('without a colour the glow has the colour of the text', (tester) async {
      await _draw(tester, _text('Salut', glow: true, textColor: '#FF3EA5'));
      expect(_style(tester).shadows!.first.color, const Color(0xFFFF3EA5));
    });

    testWidgets('switched off there is none, whatever the colour', (tester) async {
      await _draw(tester, _text('Salut', glow: false, glowColor: '#33FF66'));
      expect(_style(tester).shadows, isNull);
    });
  });

  group('shadow', () {
    testWidgets('has the distance and the blur asked for', (tester) async {
      await _draw(tester, _text('Salut', shadowBlur: 6, shadowDistance: 4, shadowColor: '#000000'));
      final shadow = _style(tester).shadows!.single;
      expect(shadow.blurRadius, 6);
      expect(shadow.offset, const Offset(4, 4));
      expect(shadow.color, const Color(0xFF000000));
    });

    testWidgets('a blur alone is a soft shadow behind the text', (tester) async {
      await _draw(tester, _text('Salut', shadowBlur: 8));
      final shadow = _style(tester).shadows!.single;
      expect(shadow.blurRadius, 8);
      expect(shadow.offset, Offset.zero);
    });

    testWidgets('a distance alone is a hard shadow', (tester) async {
      await _draw(tester, _text('Salut', shadowDistance: 3));
      final shadow = _style(tester).shadows!.single;
      expect(shadow.blurRadius, 0);
      expect(shadow.offset, const Offset(3, 3));
    });

    testWidgets('without a colour it is dark', (tester) async {
      await _draw(tester, _text('Salut', shadowDistance: 3));
      final color = _style(tester).shadows!.single.color;
      expect(color.a, greaterThan(0.5));
      expect(color.r + color.g + color.b, lessThan(0.3));
    });

    testWidgets('0 and 0 is no shadow', (tester) async {
      await _draw(tester, _text('Salut', shadowBlur: 0, shadowDistance: 0));
      expect(_style(tester).shadows, isNull);
    });

    testWidgets('with a glow, the shadow is drawn behind it', (tester) async {
      await _draw(tester, _text('Salut', glow: true, glowColor: '#33FF66', shadowDistance: 4, shadowColor: '#000000'));
      final shadows = _style(tester).shadows!;
      expect(shadows.first.offset, const Offset(4, 4), reason: 'the first one is painted first, at the back');
      expect(shadows.skip(1).every((s) => s.color == const Color(0xFF33FF66)), isTrue);
    });
  });

  group('the typewriter', () {
    testWidgets('has the same options, and keeps its steady size', (tester) async {
      await _draw(
        tester,
        _text(
          'Operațiunea Zero-Day',
          animation: AnimationType.typewriter,
          uppercase: true,
          italic: true,
          letterSpacing: 2,
          lineHeight: 1.4,
          glow: true,
          glowColor: '#33FF66',
          shadowDistance: 2,
        ),
      );
      final size = tester.getSize(find.byType(RichText).first);
      final style = _style(tester);
      expect(style.fontStyle, FontStyle.italic);
      expect(style.letterSpacing, 2);
      expect(style.height, 1.4);
      expect(style.shadows, isNotEmpty);

      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.getSize(find.byType(RichText).first), size);
      await tester.pump(const Duration(seconds: 2));
      expect(_shown(tester), 'OPERAȚIUNEA ZERO-DAY');
    });
  });

  testWidgets('every option at once draws at phone width', (tester) async {
    await _draw(
      tester,
      _text(
        'Serverul fizic a fost localizat. Mergi la punctul marcat.',
        letterSpacing: 12,
        lineHeight: 2,
        italic: true,
        uppercase: true,
        glow: true,
        glowColor: '#33FF66',
        shadowBlur: 30,
        shadowDistance: 20,
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
