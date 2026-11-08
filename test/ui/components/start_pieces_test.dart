import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/inputs/code_boxes_input.dart';
import 'package:teamxperience/ui/components/misc/avatar_stack.dart';
import 'package:teamxperience/ui/theme/app_colors.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

import '../pump_ui.dart';

Widget _onNavy(Widget child) => ColoredBox(
      color: AppColors.light.navy,
      child: Center(child: child),
    );

void main() {
  testWidgets('a Romanian letter typed into the boxes becomes its plain letter', (tester) async {
    String? typed;
    await pumpUi(tester, _onNavy(CodeBoxesInput(length: 5, onChanged: (v) => typed = v, onDark: true)));
    await tester.enterText(find.byType(TextField), 'șarpe');
    await tester.pump();
    expect(typed, 'SARPE');
    expect(find.text('S'), findsOneWidget);
  });

  for (final theme in [AppTheme.light, AppTheme.dark]) {
    testWidgets('fits 320 px at 1.3x text (${theme.brightness.name})', (tester) async {
      await pumpUi(
        tester,
        _onNavy(Column(mainAxisSize: MainAxisSize.min, children: [
          CodeBoxesInput(length: 7, onChanged: (_) {}, onDark: true),
          const AvatarStack(initials: ['VC', 'AM', 'IR', 'DP', 'EB'], total: 6, size: 30, onDark: true, gap: 6),
        ])),
        width: 320,
        textScale: 1.3,
        theme: theme,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
