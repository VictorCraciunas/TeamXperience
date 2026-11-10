import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/inputs/code_boxes_input.dart';

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
}
