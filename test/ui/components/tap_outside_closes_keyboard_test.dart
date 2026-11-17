import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/inputs/tap_outside_closes_keyboard.dart';

Future<void> _pump(WidgetTester tester, Widget body) {
  return tester.pumpWidget(
    MaterialApp(
      builder: (context, app) => TapOutsideClosesKeyboard(child: app ?? const SizedBox.shrink()),
      home: Scaffold(body: body),
    ),
  );
}

void main() {
  testWidgets('a touch outside a plain field closes the keyboard', (tester) async {
    await _pump(tester, const Column(children: [TextField(key: ValueKey('a')), SizedBox(height: 300)]));
    await tester.tap(find.byKey(const ValueKey('a')));
    await tester.pump();
    expect(tester.testTextInput.isVisible, isTrue);

    await tester.tapAt(const Offset(200, 250));
    await tester.pump();
    expect(tester.testTextInput.isVisible, isFalse);
  });

  testWidgets('moving from one field to the next keeps the keyboard up', (tester) async {
    await _pump(
      tester,
      const Column(children: [TextField(key: ValueKey('a')), SizedBox(height: 40), TextField(key: ValueKey('b'))]),
    );
    await tester.tap(find.byKey(const ValueKey('a')));
    await tester.pump();
    tester.testTextInput.log.clear();

    await tester.tap(find.byKey(const ValueKey('b')));
    await tester.pump();
    expect(tester.testTextInput.isVisible, isTrue);
    expect(tester.testTextInput.log.any((call) => call.method == 'TextInput.hide'), isFalse);
  });

  testWidgets('a field marked with TextFieldTapRegion keeps the keyboard up', (tester) async {
    var sent = 0;
    await _pump(
      tester,
      Column(
        children: [
          const TextField(key: ValueKey('a')),
          TextFieldTapRegion(child: IconButton(onPressed: () => sent++, icon: const Icon(Icons.send))),
        ],
      ),
    );
    await tester.tap(find.byKey(const ValueKey('a')));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();
    expect(sent, 1);
    expect(tester.testTextInput.isVisible, isTrue);
  });

  testWidgets('scrolling the text of a multi-line field keeps the keyboard up', (tester) async {
    // As the reason box of the photo refusal: 3 lines inside a scroll view.
    final text = TextEditingController(text: List.filled(20, 'rând').join('\n'));
    await _pump(
      tester,
      ListView(
        children: [
          TextField(key: const ValueKey('a'), controller: text, maxLines: 3, minLines: 1),
          for (var i = 0; i < 30; i++) SizedBox(height: 60, child: Text('rând $i')),
        ],
      ),
    );
    await tester.tap(find.byKey(const ValueKey('a')));
    await tester.pump();

    await tester.drag(find.byKey(const ValueKey('a')), const Offset(0, -40));
    await tester.pump();
    final inner = tester.state<ScrollableState>(
      find.descendant(of: find.byKey(const ValueKey('a')), matching: find.byType(Scrollable)),
    );
    expect(inner.position.pixels, greaterThan(0));
    expect(tester.testTextInput.isVisible, isTrue);
  }, variant: TargetPlatformVariant.mobile());

  testWidgets('a form that asks for onDrag closes the keyboard when the page is dragged', (tester) async {
    await _pump(
      tester,
      ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          const TextField(key: ValueKey('a')),
          for (var i = 0; i < 30; i++) SizedBox(height: 60, child: Text('rând $i')),
        ],
      ),
    );
    await tester.tap(find.byKey(const ValueKey('a')));
    await tester.pump();
    expect(tester.testTextInput.isVisible, isTrue);

    // Starts on the field itself, so only the drag can close it.
    await tester.drag(find.byKey(const ValueKey('a')), const Offset(0, -300));
    await tester.pump();
    expect(tester.testTextInput.isVisible, isFalse);
  });

  testWidgets('without onDrag, dragging a list from a field leaves the keyboard alone', (tester) async {
    await _pump(
      tester,
      ListView(
        children: [
          const TextField(key: ValueKey('a')),
          for (var i = 0; i < 30; i++) SizedBox(height: 60, child: Text('rând $i')),
        ],
      ),
    );
    await tester.tap(find.byKey(const ValueKey('a')));
    await tester.pump();

    await tester.drag(find.byKey(const ValueKey('a')), const Offset(0, -300));
    await tester.pump();
    expect(tester.testTextInput.isVisible, isTrue);
  });
}
