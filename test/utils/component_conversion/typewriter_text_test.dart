import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/utils/component_conversion/text_component_widget.dart';

import '../../ui/pump_ui.dart';

const _text = 'Serverul fizic a fost localizat. Mergi la punctul marcat pe hartă pentru a-l conecta.';

Future<void> _pump(WidgetTester tester, {TextAlign align = TextAlign.left}) {
  return pumpUi(
    tester,
    Center(
      child: TypewriterText(
        text: _text,
        textColor: Colors.green,
        fontWeight: FontWeight.normal,
        fontSize: 18,
        msPerCharacter: 20,
        textAlign: align,
      ),
    ),
    width: 360,
  );
}

Size _size(WidgetTester tester) => tester.getSize(find.byType(TypewriterText));

Offset _topLeft(WidgetTester tester) => tester.getTopLeft(find.byType(TypewriterText));

/// The text span of the typewriter: its first child is what can be seen, the
/// second what is still transparent.
TextSpan _span(WidgetTester tester) {
  final rich = tester.widget<RichText>(find.descendant(of: find.byType(TypewriterText), matching: find.byType(RichText)).first);
  return (rich.text as TextSpan).children!.first as TextSpan;
}

/// The letters that can be seen right now (the rest is drawn transparent).
String _visible(WidgetTester tester) => _span(tester).children!.first.toPlainText();

void main() {
  testWidgets('starts with nothing visible and ends with all of the text', (tester) async {
    await _pump(tester);
    expect(_visible(tester), isEmpty);

    await tester.pump(const Duration(milliseconds: 20 * 40));
    expect(_visible(tester).length, inInclusiveRange(30, 50));

    await tester.pump(const Duration(seconds: 5));
    expect(_visible(tester), _text);
  });

  testWidgets('the letters appear in order, never more than before', (tester) async {
    await _pump(tester);
    var last = 0;
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      final length = _visible(tester).length;
      expect(length, greaterThanOrEqualTo(last));
      expect(_text.startsWith(_visible(tester)), isTrue);
      last = length;
    }
  });

  testWidgets('the block keeps its size and place while it types (it does not slide or jump)', (tester) async {
    await _pump(tester);
    final size = _size(tester);
    final place = _topLeft(tester);

    for (var i = 0; i < 25; i++) {
      await tester.pump(const Duration(milliseconds: 90));
      expect(_size(tester), size, reason: 'step $i');
      expect(_topLeft(tester), place, reason: 'step $i');
    }
    await tester.pump(const Duration(seconds: 5));
    expect(_size(tester), size);
    expect(_topLeft(tester), place);
  });

  testWidgets('the same when centered', (tester) async {
    await _pump(tester, align: TextAlign.center);
    final size = _size(tester);
    await tester.pump(const Duration(milliseconds: 600));
    expect(_size(tester), size);
  });

  testWidgets('a word that does not fit does not jump to the next line half way', (tester) async {
    await _pump(tester);
    final height = _size(tester).height;
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 150));
      expect(_size(tester).height, height);
    }
  });

  testWidgets('what is not typed yet cannot be seen', (tester) async {
    await _pump(tester);
    await tester.pump(const Duration(milliseconds: 200));
    final span = _span(tester);
    expect(span.children!.length, 2);
    expect(span.children!.last.style?.color, Colors.transparent);
    expect(span.style?.color, Colors.green);
  });

  testWidgets('a new text starts again', (tester) async {
    await _pump(tester);
    await tester.pump(const Duration(seconds: 5));
    expect(_visible(tester), _text);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: TypewriterText(text: 'Alt text', textColor: Colors.green, fontWeight: FontWeight.normal, msPerCharacter: 20),
          ),
        ),
      ),
    );
    expect(_visible(tester), isEmpty);
    await tester.pump(const Duration(seconds: 2));
    expect(_visible(tester), 'Alt text');
  });

  testWidgets('an empty text does not break', (tester) async {
    await pumpUi(
      tester,
      TypewriterText(text: '', textColor: Colors.green, fontWeight: FontWeight.normal),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
  });
}
