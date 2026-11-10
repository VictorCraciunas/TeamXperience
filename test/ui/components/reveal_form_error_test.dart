import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/inputs/reveal_form_error.dart';

/// A long form: 30 fields, of which [wrong] fail with "Câmpul N".
Widget _form(GlobalKey<FormState> key, Set<int> wrong) => MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Form(
            key: key,
            child: Column(
              children: [
                for (var i = 0; i < 30; i++)
                  SizedBox(
                    height: 80,
                    child: TextFormField(
                      key: ValueKey('field-$i'),
                      validator: (_) => wrong.contains(i) ? 'Câmpul $i' : null,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

bool _onScreen(WidgetTester tester, int i) {
  final rect = tester.getRect(find.byKey(ValueKey('field-$i')));
  final screen = tester.getRect(find.byType(Scaffold));
  return rect.top >= screen.top && rect.bottom <= screen.bottom;
}

void main() {
  testWidgets('scrolls to the highest wrong field and gives its message', (tester) async {
    final key = GlobalKey<FormState>();
    await tester.pumpWidget(_form(key, {25, 20}));
    expect(_onScreen(tester, 20), isFalse);

    final future = revealFormError(key);
    await tester.pumpAndSettle();
    final message = await future;

    expect(message, 'Câmpul 20');
    expect(_onScreen(tester, 20), isTrue);
  });

  testWidgets('all fields right: null, and nothing moves', (tester) async {
    final key = GlobalKey<FormState>();
    await tester.pumpWidget(_form(key, {}));
    final before = tester.getRect(find.byKey(const ValueKey('field-0')));
    final future = revealFormError(key);
    await tester.pumpAndSettle();
    expect(await future, isNull);
    expect(tester.getRect(find.byKey(const ValueKey('field-0'))), before);
  });

  testWidgets('no form on screen counts as wrong, with no message', (tester) async {
    expect(await revealFormError(GlobalKey<FormState>()), '');
  });
}
