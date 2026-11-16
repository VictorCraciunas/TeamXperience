import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/inputs/code_boxes_input.dart';
import 'package:teamxperience/ui/components/inputs/tap_outside_closes_keyboard.dart';

import '../pump_ui.dart';

bool _askedForKeyboard(WidgetTester tester) => tester.testTextInput.log.any((call) => call.method == 'TextInput.show');

void main() {
  testWidgets('a tap opens the keyboard', (tester) async {
    await pumpUi(tester, CodeBoxesInput(length: 6, onChanged: (_) {}));
    await tester.tap(find.byType(CodeBoxesInput));
    await tester.pump();
    expect(_askedForKeyboard(tester), isTrue);
  });

  testWidgets('after the keyboard is closed with back, a tap opens it again', (tester) async {
    await pumpUi(tester, CodeBoxesInput(length: 6, onChanged: (_) {}));
    await tester.tap(find.byType(CodeBoxesInput));
    await tester.pump();

    // The phone's back button hides the keyboard; the boxes keep their focus.
    tester.testTextInput.log.clear();
    await tester.tap(find.byType(CodeBoxesInput));
    await tester.pump();
    expect(_askedForKeyboard(tester), isTrue);
  });

  group('under TapOutsideClosesKeyboard', () {
    Future<void> pumpWithButton(WidgetTester tester, VoidCallback onButton) {
      return tester.pumpWidget(
        MaterialApp(
          builder: (context, app) => TapOutsideClosesKeyboard(child: app ?? const SizedBox.shrink()),
          home: Scaffold(
            body: Column(
              children: [
                CodeBoxesInput(length: 6, onChanged: (_) {}),
                const SizedBox(height: 200),
                ElevatedButton(onPressed: onButton, child: const Text('Intră')),
              ],
            ),
          ),
        ),
      );
    }

    testWidgets('a tap outside closes the keyboard, a tap on the boxes opens it again', (tester) async {
      await pumpWithButton(tester, () {});
      await tester.tap(find.byType(CodeBoxesInput));
      await tester.pump();
      expect(tester.testTextInput.isVisible, isTrue);

      await tester.tapAt(const Offset(200, 150));
      await tester.pump();
      expect(tester.testTextInput.isVisible, isFalse);
      expect(FocusManager.instance.primaryFocus?.context?.widget, isNot(isA<EditableText>()));

      tester.testTextInput.log.clear();
      await tester.tap(find.byType(CodeBoxesInput));
      await tester.pump();
      expect(_askedForKeyboard(tester), isTrue);
      expect(tester.testTextInput.isVisible, isTrue);
    });

    testWidgets('a tap on the boxes while typing keeps the keyboard up', (tester) async {
      await pumpWithButton(tester, () {});
      await tester.tap(find.byType(CodeBoxesInput));
      await tester.pump();
      tester.testTextInput.log.clear();

      await tester.tap(find.byType(CodeBoxesInput));
      await tester.pump();
      expect(tester.testTextInput.isVisible, isTrue);
      expect(tester.testTextInput.log.any((call) => call.method == 'TextInput.hide'), isFalse);
    });

    testWidgets('a button outside closes the keyboard and still gets its tap', (tester) async {
      var pressed = 0;
      await pumpWithButton(tester, () => pressed++);
      await tester.tap(find.byType(CodeBoxesInput));
      await tester.pump();

      await tester.tap(find.text('Intră'));
      await tester.pump();
      expect(pressed, 1);
      expect(tester.testTextInput.isVisible, isFalse);
    });
  });
}
