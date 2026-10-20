import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/inputs/app_dropdown.dart';

import '../pump_ui.dart';

const _items = [
  AppDropdownItem<String>(value: 'a', label: 'Prima'),
  AppDropdownItem<String>(value: 'b', label: 'A doua'),
];

void main() {
  testWidgets('shows the label and the selected item', (tester) async {
    await pumpUi(
      tester,
      AppDropdown<String>(label: 'Tip', items: _items, value: 'b', onChanged: (_) {}),
    );
    expect(find.text('Tip'), findsOneWidget);
    expect(find.text('A doua'), findsOneWidget);
  });

  testWidgets('shows the hint when nothing is selected', (tester) async {
    await pumpUi(
      tester,
      AppDropdown<String>(items: _items, value: null, hint: 'Alege', onChanged: (_) {}),
    );
    expect(find.text('Alege'), findsOneWidget);
  });

  testWidgets('opens the list and reports the selection', (tester) async {
    String? picked;
    await pumpUi(
      tester,
      AppDropdown<String>(label: 'Tip', items: _items, value: 'a', onChanged: (v) => picked = v),
    );
    await tester.tap(find.text('Prima'));
    await tester.pumpAndSettle();
    expect(find.text('A doua'), findsOneWidget);
    await tester.tap(find.text('A doua'));
    await tester.pumpAndSettle();
    expect(picked, 'b');
  });

  testWidgets('shows the validator message as an error', (tester) async {
    final key = GlobalKey<FormState>();
    await pumpUi(
      tester,
      Form(
        key: key,
        child: AppDropdown<String>(
          items: _items,
          value: null,
          onChanged: (_) {},
          validator: (v) => v == null ? 'Alege o opțiune' : null,
        ),
      ),
    );
    key.currentState!.validate();
    await tester.pump();
    expect(find.text('Alege o opțiune'), findsOneWidget);
  });
}
