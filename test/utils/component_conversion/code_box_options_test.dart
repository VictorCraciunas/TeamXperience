import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/utils/component_conversion/component_to_widget.dart';

import '../../ui/pump_ui.dart';

Component _code({
  String inputType = 'Separated',
  double fontSize = 20,
  double? boxHeight,
  bool? boldText,
  bool glow = false,
  String? glowOn,
  int length = 4,
}) => Component(
      type: ComponentType.code,
      codeLength: length,
      inputType: inputType,
      fontSize: fontSize,
      boxHeight: boxHeight,
      boldText: boldText,
      enableGlow: glow,
      glowColor: '#33FF66',
      glowOn: glowOn,
    );

Future<void> _draw(WidgetTester tester, Component component) {
  return pumpUi(tester, Column(children: [ComponentToWidget().convert(component)]), width: 360);
}

/// The box around the first letter field.
Size _boxSize(WidgetTester tester) {
  final box = find.ancestor(of: find.byType(TextField).first, matching: find.byType(Container)).first;
  return tester.getSize(box);
}

bool _hasGlow(Widget w) =>
    w is Container && w.decoration is BoxDecoration && ((w.decoration as BoxDecoration).boxShadow?.isNotEmpty ?? false);

int _glowing(WidgetTester tester) => tester.widgetList(find.byWidgetPredicate(_hasGlow)).length;

/// Whether the outer frame (the container around all the boxes) glows.
bool _frameGlows(WidgetTester tester) {
  final frame = tester.widget<Container>(
    find.descendant(of: find.byType(IntrinsicWidth), matching: find.byType(Container)).first,
  );
  return _hasGlow(frame);
}

FontWeight? _weight(WidgetTester tester) => tester.widget<TextField>(find.byType(TextField).first).style?.fontWeight;

void main() {
  group('box height', () {
    testWidgets('is one and a half times the text when nothing was chosen, as it always was', (tester) async {
      await _draw(tester, _code(fontSize: 20));
      expect(_boxSize(tester).height, 30);
      await _draw(tester, _code(fontSize: 40));
      expect(_boxSize(tester).height, 60);
    });

    testWidgets('can be chosen, whatever the text size', (tester) async {
      await _draw(tester, _code(fontSize: 20, boxHeight: 64));
      expect(_boxSize(tester).height, 64);
    });

    testWidgets('can be chosen for a single free box too', (tester) async {
      await _draw(tester, _code(inputType: 'Free', fontSize: 20, boxHeight: 70));
      expect(_boxSize(tester).height, 70);
    });

    testWidgets('the extremes draw without trouble', (tester) async {
      for (final height in [20.0, 100.0]) {
        await _draw(tester, _code(boxHeight: height));
        expect(tester.takeException(), isNull, reason: '$height');
      }
    });
  });

  group('bold text', () {
    testWidgets('is bold when nothing was chosen, as it always was', (tester) async {
      await _draw(tester, _code());
      expect(_weight(tester), FontWeight.bold);
    });

    testWidgets('can be switched off', (tester) async {
      await _draw(tester, _code(boldText: false));
      expect(_weight(tester), FontWeight.normal);
    });

    testWidgets('can be said to be on', (tester) async {
      await _draw(tester, _code(boldText: true));
      expect(_weight(tester), FontWeight.bold);
    });

    testWidgets('applies to a free box too', (tester) async {
      await _draw(tester, _code(inputType: 'Free', boldText: false));
      expect(_weight(tester), FontWeight.normal);
    });
  });

  group('where the glow is', () {
    testWidgets('without glow nothing glows', (tester) async {
      await _draw(tester, _code());
      expect(_glowing(tester), 0);
    });

    testWidgets('on the frame around the boxes when nothing was chosen, as it always was', (tester) async {
      await _draw(tester, _code(glow: true));
      expect(_frameGlows(tester), isTrue);
      expect(_glowing(tester), 1, reason: 'only the frame');
    });

    testWidgets('on the frame when asked for the frame', (tester) async {
      await _draw(tester, _code(glow: true, glowOn: 'frame'));
      expect(_frameGlows(tester), isTrue);
      expect(_glowing(tester), 1);
    });

    testWidgets('on each box when asked for the boxes', (tester) async {
      await _draw(tester, _code(glow: true, glowOn: 'boxes', length: 4));
      expect(_frameGlows(tester), isFalse);
      expect(_glowing(tester), 4);
    });

    testWidgets('on each box, whatever their number', (tester) async {
      await _draw(tester, _code(glow: true, glowOn: 'boxes', length: 7));
      expect(_glowing(tester), 7);
    });

    testWidgets('a single free box glows either way', (tester) async {
      await _draw(tester, _code(inputType: 'Free', glow: true, glowOn: 'frame'));
      expect(_glowing(tester), 1);
      await _draw(tester, _code(inputType: 'Free', glow: true, glowOn: 'boxes'));
      expect(_glowing(tester), 1);
    });

    testWidgets('the glow on the boxes pulses like the one on the frame', (tester) async {
      await _draw(tester, _code(glow: true, glowOn: 'boxes', length: 2));
      final first = tester.widgetList<Container>(find.byWidgetPredicate(_hasGlow)).map((c) => (c.decoration as BoxDecoration).boxShadow!.first.spreadRadius).toList();
      await tester.pump(const Duration(milliseconds: 500));
      final later = tester.widgetList<Container>(find.byWidgetPredicate(_hasGlow)).map((c) => (c.decoration as BoxDecoration).boxShadow!.first.spreadRadius).toList();
      expect(later, isNot(first));
    });
  });
}
