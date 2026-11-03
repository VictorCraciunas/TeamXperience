import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/utils/component_conversion/component_to_widget.dart';

import '../../ui/pump_ui.dart';

Component _component(
  ComponentType type, {
  double? opacity,
  double? shadowBlur,
  double? shadowDistance,
  String? shadowColor,
  double? borderWidth,
  String? borderColor,
  bool? glow,
  String? glowColor,
  double? cornerRadius,
  double? frameCornerRadius,
  String inputType = 'Separated',
}) => Component(
      type: type,
      text: 'Salut',
      buttonLabel: 'OK',
      codeLength: 4,
      inputType: inputType,
      imageUrl: '/tmp/none.png',
      opacity: opacity,
      shadowBlur: shadowBlur,
      shadowDistance: shadowDistance,
      shadowColor: shadowColor,
      borderWidth: borderWidth,
      borderColor: borderColor,
      enableGlow: glow,
      glowColor: glowColor,
      cornerRadius: cornerRadius,
      frameCornerRadius: frameCornerRadius,
    );

Future<void> _draw(WidgetTester tester, Component component) {
  return pumpUi(tester, Column(children: [ComponentToWidget().convert(component)]), width: 360);
}

Iterable<DecoratedBox> _boxes(WidgetTester tester) => tester.widgetList<DecoratedBox>(find.byType(DecoratedBox));

BoxDecoration? _decoration(DecoratedBox box) => box.decoration is BoxDecoration ? box.decoration as BoxDecoration : null;

/// The boxes that have a shadow with this blur and distance.
Iterable<DecoratedBox> _withShadow(WidgetTester tester, double blur, double distance) => _boxes(tester).where(
      (box) => _decoration(box)?.boxShadow?.any((s) => s.blurRadius == blur && s.offset == Offset(distance, distance)) ?? false,
    );

int _opacityWidgets(WidgetTester tester) => tester.widgetList<Opacity>(find.byType(Opacity)).length;

void main() {
  group('opacity', () {
    for (final type in ComponentType.values) {
      testWidgets('${type.name}: a half transparent one', (tester) async {
        await _draw(tester, _component(type, opacity: 0.5));
        expect(tester.widgetList<Opacity>(find.byType(Opacity)).where((o) => o.opacity == 0.5), hasLength(1));
      });

      testWidgets('${type.name}: fully visible or not set adds nothing', (tester) async {
        await _draw(tester, _component(type));
        final usual = _opacityWidgets(tester);
        await _draw(tester, _component(type, opacity: 1));
        expect(_opacityWidgets(tester), usual);
      });
    }

    testWidgets('0 makes it invisible', (tester) async {
      await _draw(tester, _component(ComponentType.text, opacity: 0));
      expect(tester.widgetList<Opacity>(find.byType(Opacity)).where((o) => o.opacity == 0), hasLength(1));
    });
  });

  group('shadow on an image, a button and a code input', () {
    for (final type in [ComponentType.image, ComponentType.button, ComponentType.code]) {
      testWidgets('${type.name}: the distance and the blur asked for', (tester) async {
        await _draw(tester, _component(type, shadowBlur: 8, shadowDistance: 4, shadowColor: '#112233'));
        final boxes = _withShadow(tester, 8, 4);
        expect(boxes, hasLength(1));
        expect(_decoration(boxes.single)!.boxShadow!.single.color, const Color(0xFF112233));
      });

      testWidgets('${type.name}: no shadow unless asked for', (tester) async {
        await _draw(tester, _component(type));
        expect(_boxes(tester).where((b) => (_decoration(b)?.boxShadow?.isNotEmpty ?? false) && (_decoration(b)!.boxShadow!.first.offset != Offset.zero)), isEmpty);
      });

      testWidgets('${type.name}: 0 and 0 is no shadow', (tester) async {
        await _draw(tester, _component(type, shadowBlur: 0, shadowDistance: 0));
        expect(_withShadow(tester, 0, 0), isEmpty);
      });
    }

    testWidgets('a blur alone is a soft shadow behind the component', (tester) async {
      await _draw(tester, _component(ComponentType.button, shadowBlur: 10));
      expect(_boxes(tester).any((b) => _decoration(b)?.boxShadow?.any((s) => s.blurRadius == 10 && s.offset == Offset.zero) ?? false), isTrue);
    });

    testWidgets('the shadow follows the rounded corners of a button', (tester) async {
      await _draw(tester, _component(ComponentType.button, shadowBlur: 8, shadowDistance: 4, cornerRadius: 22));
      expect(_decoration(_withShadow(tester, 8, 4).single)!.borderRadius, BorderRadius.circular(22));
    });

    testWidgets('the shadow of a button without corners chosen follows the usual corners', (tester) async {
      await _draw(tester, _component(ComponentType.button, shadowBlur: 8, shadowDistance: 4));
      expect(_decoration(_withShadow(tester, 8, 4).single)!.borderRadius, BorderRadius.circular(10));
    });

    testWidgets('the shadow follows the rounded corners of an image', (tester) async {
      await _draw(tester, _component(ComponentType.image, shadowBlur: 8, shadowDistance: 4, cornerRadius: 30));
      expect(_decoration(_withShadow(tester, 8, 4).single)!.borderRadius, BorderRadius.circular(30));
    });

    testWidgets('the shadow of a separated code input follows its frame', (tester) async {
      await _draw(tester, _component(ComponentType.code, shadowBlur: 8, shadowDistance: 4, frameCornerRadius: 18));
      expect(_decoration(_withShadow(tester, 8, 4).single)!.borderRadius, BorderRadius.circular(18));
    });

    testWidgets('a text keeps its own shadow and gets no box around it', (tester) async {
      await _draw(tester, _component(ComponentType.text, shadowBlur: 8, shadowDistance: 4));
      expect(_withShadow(tester, 8, 4), isEmpty);
    });

    testWidgets('a default shadow is dark', (tester) async {
      await _draw(tester, _component(ComponentType.button, shadowDistance: 4));
      final color = _boxes(tester)
          .map((b) => _decoration(b)?.boxShadow)
          .whereType<List<BoxShadow>>()
          .expand((s) => s)
          .firstWhere((s) => s.offset == const Offset(4, 4))
          .color;
      expect(color.a, greaterThan(0.5));
      expect(color.r + color.g + color.b, lessThan(0.3));
    });
  });

  group('border of an image', () {
    testWidgets('has the width and the colour asked for', (tester) async {
      await _draw(tester, _component(ComponentType.image, borderWidth: 4, borderColor: '#33FF66'));
      final bordered = _boxes(tester).where((b) => _decoration(b)?.border is Border);
      final border = _decoration(bordered.single)!.border as Border;
      expect(border.top.width, 4);
      expect(border.top.color, const Color(0xFF33FF66));
    });

    testWidgets('has none unless asked for', (tester) async {
      await _draw(tester, _component(ComponentType.image));
      expect(_boxes(tester).where((b) => _decoration(b)?.border != null), isEmpty);
    });

    testWidgets('0 is no border', (tester) async {
      await _draw(tester, _component(ComponentType.image, borderWidth: 0, borderColor: '#33FF66'));
      expect(_boxes(tester).where((b) => _decoration(b)?.border != null), isEmpty);
    });

    testWidgets('a width without a colour is black', (tester) async {
      await _draw(tester, _component(ComponentType.image, borderWidth: 2));
      final border = _decoration(_boxes(tester).singleWhere((b) => _decoration(b)?.border is Border))!.border as Border;
      expect(border.top.color, const Color(0xFF000000));
    });
  });

  group('glow of an image', () {
    testWidgets('a steady glow in the colour asked for', (tester) async {
      await _draw(tester, _component(ComponentType.image, glow: true, glowColor: '#33FF66'));
      final glowing = _boxes(tester).where(
        (b) => _decoration(b)?.boxShadow?.any((s) => s.offset == Offset.zero && s.blurRadius > 0 && s.color.toARGB32() & 0x00FFFFFF == 0x0033FF66) ?? false,
      );
      expect(glowing, hasLength(1));
    });

    testWidgets('none when switched off', (tester) async {
      await _draw(tester, _component(ComponentType.image, glow: false, glowColor: '#33FF66'));
      expect(_boxes(tester).where((b) => _decoration(b)?.boxShadow != null), isEmpty);
    });

    testWidgets('with a shadow both are there', (tester) async {
      await _draw(tester, _component(ComponentType.image, glow: true, glowColor: '#33FF66', shadowBlur: 6, shadowDistance: 3));
      final shadows = _boxes(tester).map((b) => _decoration(b)?.boxShadow).whereType<List<BoxShadow>>().single;
      expect(shadows.length, 2);
      expect(shadows.first.offset, const Offset(3, 3), reason: 'the shadow is behind the glow');
    });
  });

  group('border of a button', () {
    double? width(WidgetTester tester) {
      final bordered = _boxes(tester).where((b) => _decoration(b)?.border is Border && (_decoration(b)!.border as Border).top.width != 0 || (_decoration(b)?.border is Border && _decoration(b)!.border!.isUniform));
      return bordered.isEmpty ? null : (_decoration(bordered.first)!.border as Border).top.width;
    }

    testWidgets('is 1.5 wide when nothing was chosen, as it always was', (tester) async {
      await _draw(tester, _component(ComponentType.button));
      expect(width(tester), 1.5);
    });

    testWidgets('can be made thicker', (tester) async {
      await _draw(tester, _component(ComponentType.button, borderWidth: 5));
      expect(width(tester), 5);
    });

    testWidgets('can be removed with 0', (tester) async {
      await _draw(tester, _component(ComponentType.button, borderWidth: 0));
      expect(width(tester), 0);
    });
  });

  testWidgets('every option at its extreme draws at phone width', (tester) async {
    for (final type in [ComponentType.image, ComponentType.button, ComponentType.code]) {
      await _draw(
        tester,
        _component(
          type,
          opacity: 0,
          shadowBlur: 30,
          shadowDistance: 20,
          borderWidth: 6,
          borderColor: '#33FF66',
          glow: true,
          glowColor: '#33FF66',
        ),
      );
      expect(tester.takeException(), isNull, reason: type.name);
    }
  });
}
