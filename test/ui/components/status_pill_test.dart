import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/feedback/status_pill.dart';

import '../pump_ui.dart';

void main() {
  testWidgets('shows its label and icon', (tester) async {
    await pumpUi(
      tester,
      const StatusPill(label: 'A început', icon: Icons.bolt, kind: StatusPillKind.soon),
    );
    expect(find.text('A început'), findsOneWidget);
    expect(find.byIcon(Icons.bolt), findsOneWidget);
  });
}
