import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/buttons/app_button.dart';

import '../pump_ui.dart';

void main() {
  testWidgets('shows label text', (tester) async {
    await pumpUi(tester, AppButton(label: 'Continuă jocul', onPressed: () {}));
    expect(find.text('Continuă jocul'), findsOneWidget);
  });

  testWidgets('calls onPressed when tapped', (tester) async {
    var taps = 0;
    await pumpUi(tester, AppButton(label: 'Salvează', onPressed: () => taps++));
    await tester.tap(find.byType(AppButton));
    expect(taps, 1);
  });

  testWidgets('does not call onPressed while loading and shows a spinner',
      (tester) async {
    var taps = 0;
    await pumpUi(
      tester,
      AppButton(label: 'Salvează', isLoading: true, onPressed: () => taps++),
    );
    await tester.tap(find.byType(AppButton));
    expect(taps, 0);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('is inert when onPressed is null', (tester) async {
    await pumpUi(tester, const AppButton(label: 'Salvează', onPressed: null));
    await tester.tap(find.byType(AppButton));
    expect(tester.takeException(), isNull);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('has at least 44dp height', (tester) async {
    await pumpUi(tester, AppButton(label: 'Salvează', onPressed: () {}));
    expect(tester.getSize(find.byType(AppButton)).height, greaterThanOrEqualTo(44));
  });

  testWidgets('shows the leading widget', (tester) async {
    await pumpUi(
      tester,
      AppButton(
        label: 'Distribuie',
        leading: const Icon(Icons.share),
        variant: AppButtonVariant.secondary,
        onPressed: () {},
      ),
    );
    expect(find.byIcon(Icons.share), findsOneWidget);
  });

  testWidgets('long label does not overflow at text scale 1.5', (tester) async {
    await pumpUi(
      tester,
      AppButton(
        label: 'Salvează schimbările echipei',
        leading: const Icon(Icons.check),
        onPressed: () {},
      ),
      textScale: 1.5,
      width: 160,
    );
    expect(tester.takeException(), isNull);
  });
}
