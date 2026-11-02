import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/utils/component_conversion/component_to_widget.dart';

import '../../ui/pump_ui.dart';

const _short = 'Salut';
const _long = 'Serverul fizic a fost localizat. Mergi la punctul marcat pe hartă pentru a-l conecta rapid.';

Future<void> _draw(WidgetTester tester, String text, String? align, {double width = 360}) {
  return pumpUi(
    tester,
    Column(
      children: [
        ComponentToWidget().convert(Component(type: ComponentType.text, text: text, textAlign: align, fontSize: 18)),
      ],
    ),
    width: width,
  );
}

Rect _where(WidgetTester tester) {
  final box = tester.renderObject<RenderParagraph>(find.byType(RichText).first);
  final topLeft = box.localToGlobal(Offset.zero);
  return topLeft & box.size;
}

void main() {
  testWidgets('left: a short text sits at the left edge', (tester) async {
    await _draw(tester, _short, 'left');
    expect(_where(tester).left, 0);
  });

  testWidgets('right: a short text sits at the right edge', (tester) async {
    await _draw(tester, _short, 'right');
    expect(_where(tester).right, 360);
  });

  testWidgets('center: a short text is in the middle', (tester) async {
    await _draw(tester, _short, 'center');
    final rect = _where(tester);
    expect((rect.left + rect.right) / 2, closeTo(180, 1));
  });

  testWidgets('no alignment chosen is centered, as before', (tester) async {
    await _draw(tester, _short, null);
    final rect = _where(tester);
    expect((rect.left + rect.right) / 2, closeTo(180, 1));
  });

  testWidgets('left: a long text starts at the left edge', (tester) async {
    await _draw(tester, _long, 'left');
    expect(_where(tester).left, 0);
  });

  testWidgets('justify: a long text fills the whole width', (tester) async {
    await _draw(tester, _long, 'justify');
    expect(_where(tester).width, 360);
  });

  testWidgets('it also works where the width is not limited', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ComponentToWidget().convert(Component(type: ComponentType.text, text: _short, textAlign: 'left')),
              ],
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
