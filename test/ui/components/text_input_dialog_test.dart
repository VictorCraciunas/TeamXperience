import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/feedback/text_input_dialog.dart';

import '../pump_ui.dart';

class _Harness {
  String? result;
  bool returned = false;
}

Future<_Harness> _open(WidgetTester tester) async {
  final h = _Harness();
  await pumpUi(
    tester,
    Builder(
      builder: (context) => TextButton(
        onPressed: () async {
          h.result = await showTextInputDialog(
            context,
            title: 'Categorie nouă',
            label: 'Nume categorie',
            confirmLabel: 'Adaugă',
            cancelLabel: 'Anulează',
          );
          h.returned = true;
        },
        child: const Text('deschide'),
      ),
    ),
  );
  await tester.tap(find.text('deschide'));
  await tester.pumpAndSettle();
  return h;
}

void main() {
  testWidgets('shows the title and the field', (tester) async {
    await _open(tester);
    expect(find.text('Categorie nouă'), findsOneWidget);
    expect(find.text('Nume categorie'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('returns the typed text, trimmed, on confirm', (tester) async {
    final h = await _open(tester);
    await tester.enterText(find.byType(TextField), '  Anunțuri  ');
    await tester.tap(find.text('Adaugă'));
    await tester.pumpAndSettle();
    expect(h.result, 'Anunțuri');
  });

  testWidgets('does not close on confirm while the field is empty', (tester) async {
    final h = await _open(tester);
    await tester.tap(find.text('Adaugă'));
    await tester.pumpAndSettle();
    expect(h.returned, isFalse);
    expect(find.text('Scrie un nume'), findsOneWidget);
  });

  testWidgets('returns null on cancel', (tester) async {
    final h = await _open(tester);
    await tester.enterText(find.byType(TextField), 'Ceva');
    await tester.tap(find.text('Anulează'));
    await tester.pumpAndSettle();
    expect(h.returned, isTrue);
    expect(h.result, isNull);
  });
}
