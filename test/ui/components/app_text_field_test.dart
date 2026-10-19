import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/inputs/app_text_field.dart';

import '../pump_ui.dart';

void main() {
  testWidgets('shows plain label when not required', (tester) async {
    await pumpUi(tester, const AppTextField(label: 'Nume echipă'));
    expect(find.text('Nume echipă'), findsOneWidget);
    expect(find.byKey(const ValueKey('app-text-field-label')), findsOneWidget);
  });

  testWidgets('marks the label with an asterisk when required', (tester) async {
    await pumpUi(tester, const AppTextField(label: 'Nume echipă', required: true));
    expect(find.text('Nume echipă *'), findsOneWidget);
  });

  testWidgets('shows helper text while there is no error', (tester) async {
    await pumpUi(
      tester,
      const AppTextField(label: 'Nume', helper: 'Numele apare pe hartă.'),
    );
    expect(find.text('Numele apare pe hartă.'), findsOneWidget);
  });

  testWidgets('shows the validator message with an alert icon after validate',
      (tester) async {
    final formKey = GlobalKey<FormState>();
    await pumpUi(
      tester,
      Form(
        key: formKey,
        child: AppTextField(
          label: 'Nume',
          validator: (v) => (v ?? '').isEmpty ? 'Spune-ne cum se numește echipa' : null,
        ),
      ),
    );
    expect(formKey.currentState?.validate(), isFalse);
    await tester.pump();
    await tester.pump();
    expect(find.text('Spune-ne cum se numește echipa'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('does not invent a validator message when none is given',
      (tester) async {
    final formKey = GlobalKey<FormState>();
    await pumpUi(
      tester,
      Form(key: formKey, child: const AppTextField(label: 'Opțional')),
    );
    expect(formKey.currentState?.validate(), isTrue);
  });

  testWidgets('obscured field toggles visibility with the eye icon',
      (tester) async {
    await pumpUi(tester, const AppTextField(label: 'Parola', obscure: true));
    expect(tester.widget<TextField>(find.byType(TextField)).obscureText, isTrue);
    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pump();
    expect(tester.widget<TextField>(find.byType(TextField)).obscureText, isFalse);
  });

  testWidgets('read only field calls onTap', (tester) async {
    var taps = 0;
    await pumpUi(
      tester,
      AppTextField(label: 'Data', readOnly: true, onTap: () => taps++),
    );
    await tester.tap(find.byType(TextField));
    expect(taps, 1);
  });

  testWidgets('multiline field uses a 14 radius border', (tester) async {
    await pumpUi(tester, const AppTextField(label: 'Componență', maxLines: 3));
    final border = tester
        .widget<InputDecorator>(find.byType(InputDecorator))
        .decoration
        .enabledBorder as OutlineInputBorder;
    expect(border.borderRadius, BorderRadius.circular(14));
  });

  testWidgets('typing reports changes', (tester) async {
    String? last;
    await pumpUi(tester, AppTextField(label: 'Nume', onChanged: (v) => last = v));
    await tester.enterText(find.byType(TextField), 'Vulturii');
    expect(last, 'Vulturii');
  });
  testWidgets('renders no label when none is given', (tester) async {
    await pumpUi(tester, const AppTextField(hint: 'Caută eveniment'));
    expect(find.byKey(const ValueKey('app-text-field-label')), findsNothing);
    expect(find.byType(TextField), findsOneWidget);
  });
}
