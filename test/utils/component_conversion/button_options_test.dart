import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/utils/component_conversion/component_to_widget.dart';

import '../../ui/pump_ui.dart';

Future<void> _draw(WidgetTester tester, Component component) {
  return pumpUi(tester, Column(children: [ComponentToWidget().convert(component)]), width: 360);
}

Component _button({double? letterSpacing, double? paddingY}) => Component(
      type: ComponentType.button,
      buttonLabel: 'EXECUTĂ',
      fontSize: 16,
      letterSpacing: letterSpacing,
      paddingY: paddingY,
    );

Size _size(WidgetTester tester) {
  final box = find.ancestor(of: find.text('EXECUTĂ'), matching: find.byType(Container)).first;
  return tester.getSize(box);
}

TextStyle? _style(WidgetTester tester) => tester.widget<Text>(find.text('EXECUTĂ')).style;

void main() {
  group('letter spacing', () {
    testWidgets('is 8 when nothing was chosen, as it always was', (tester) async {
      await _draw(tester, _button());
      expect(_style(tester)?.letterSpacing, 8);
    });

    testWidgets('can be chosen', (tester) async {
      await _draw(tester, _button(letterSpacing: 2));
      expect(_style(tester)?.letterSpacing, 2);
    });

    testWidgets('0 is a real choice, not "not set"', (tester) async {
      await _draw(tester, _button(letterSpacing: 0));
      expect(_style(tester)?.letterSpacing, 0);
    });

    testWidgets('a smaller spacing makes a narrower button', (tester) async {
      await _draw(tester, _button());
      final wide = _size(tester).width;
      await _draw(tester, _button(letterSpacing: 0));
      expect(_size(tester).width, lessThan(wide));
    });
  });

  group('vertical padding', () {
    testWidgets('is 5 above and below when nothing was chosen', (tester) async {
      await _draw(tester, _button());
      final usual = _size(tester).height;
      await _draw(tester, _button(paddingY: 5));
      expect(_size(tester).height, usual);
    });

    testWidgets('a bigger padding makes a taller button, by twice the difference', (tester) async {
      await _draw(tester, _button());
      final usual = _size(tester).height;
      await _draw(tester, _button(paddingY: 15));
      expect(_size(tester).height, usual + 20);
    });

    testWidgets('0 makes the button as tall as its text', (tester) async {
      await _draw(tester, _button());
      final usual = _size(tester).height;
      await _draw(tester, _button(paddingY: 0));
      expect(_size(tester).height, usual - 10);
    });

    testWidgets('the width does not change with the padding', (tester) async {
      await _draw(tester, _button());
      final usual = _size(tester).width;
      await _draw(tester, _button(paddingY: 25));
      expect(_size(tester).width, usual);
    });
  });

  testWidgets('both at their extremes draw without trouble', (tester) async {
    for (final spacing in [0.0, 12.0]) {
      for (final padding in [0.0, 30.0]) {
        await _draw(tester, _button(letterSpacing: spacing, paddingY: padding));
        expect(tester.takeException(), isNull, reason: '$spacing / $padding');
      }
    }
  });
}
