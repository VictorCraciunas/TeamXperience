import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/feedback/status_pill.dart';
import 'package:teamxperience/ui/theme/app_colors.dart';

import '../pump_ui.dart';

Color _pillColor(WidgetTester tester) {
  final box = tester.widget<DecoratedBox>(
    find.descendant(of: find.byType(StatusPill), matching: find.byType(DecoratedBox)).first,
  );
  return (box.decoration as BoxDecoration).color ?? Colors.transparent;
}

void main() {
  testWidgets('shows its label and icon', (tester) async {
    await pumpUi(
      tester,
      const StatusPill(label: 'A început', icon: Icons.bolt, kind: StatusPillKind.soon),
    );
    expect(find.text('A început'), findsOneWidget);
    expect(find.byIcon(Icons.bolt), findsOneWidget);
  });

  testWidgets('live kind uses the live colour', (tester) async {
    await pumpUi(tester, const StatusPill(label: 'LIVE', kind: StatusPillKind.live));
    expect(_pillColor(tester), AppColors.light.live);
  });

  testWidgets('soon kind uses the soon colour', (tester) async {
    await pumpUi(tester, const StatusPill(label: 'A început', kind: StatusPillKind.soon));
    expect(_pillColor(tester), AppColors.light.soon);
  });

  testWidgets('info kind uses the teal tick colour', (tester) async {
    await pumpUi(tester, const StatusPill(label: 'Recomandat'));
    expect(_pillColor(tester), AppColors.light.tick);
  });
}
