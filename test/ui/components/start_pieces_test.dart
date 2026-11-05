import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/inputs/code_box.dart';
import 'package:teamxperience/ui/components/inputs/code_boxes_input.dart';
import 'package:teamxperience/ui/components/misc/avatar_stack.dart';
import 'package:teamxperience/ui/theme/app_colors.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

import '../pump_ui.dart';

Widget _onNavy(Widget child) => ColoredBox(
      color: AppColors.light.navy,
      child: Center(child: child),
    );

BoxDecoration _box(WidgetTester tester, int i) => tester
    .widget<DecoratedBox>(find.descendant(of: find.byKey(ValueKey('code-box-$i')), matching: find.byType(DecoratedBox)).first)
    .decoration as BoxDecoration;

void main() {
  group('CodeBox on navy', () {
    testWidgets('38 x 48 inside a 2 px border: 42 x 52', (tester) async {
      await pumpUi(tester, _onNavy(const CodeBox(character: 'H', active: false, error: false, onDark: true)));
      expect(tester.getSize(find.byType(CodeBox)), const Size(42, 52));
      final text = tester.widget<Text>(find.text('H')).style;
      expect((text?.fontSize, text?.fontWeight, text?.color), (20, FontWeight.w500, AppColors.light.onNavy));
    });

    testWidgets('the light box stays 34 x 47', (tester) async {
      await pumpUi(tester, const Center(child: CodeBox(character: 'H', active: false, error: false)));
      expect(tester.getSize(find.byType(CodeBox)), const Size(34, 47));
    });
  });

  group('CodeBoxesInput on navy', () {
    testWidgets('five boxes 6 apart: 234 wide; red borders on error', (tester) async {
      await pumpUi(tester, _onNavy(CodeBoxesInput(length: 5, onChanged: (_) {}, error: true, onDark: true)));
      final left = tester.getTopLeft(find.byKey(const ValueKey('code-box-0'))).dx;
      final right = tester.getTopRight(find.byKey(const ValueKey('code-box-4'))).dx;
      expect(right - left, 234);
      final border = _box(tester, 0).border as Border;
      expect((border.top.color, border.top.width), (AppColors.light.dangerOnNavy, 2));
    });

    testWidgets('an empty box has a faint border, a filled one the tick colour', (tester) async {
      await pumpUi(tester, _onNavy(CodeBoxesInput(length: 5, onChanged: (_) {}, onDark: true)));
      await tester.enterText(find.byType(TextField), 'HA');
      await tester.pump();
      expect((_box(tester, 0).border as Border).top.color, AppColors.light.tickOnNavy);
      expect((_box(tester, 4).border as Border).top.color, AppColors.light.onNavy.withValues(alpha: .3));
      expect(_box(tester, 4).color, AppColors.light.onNavy.withValues(alpha: .08));
    });
  });

  testWidgets('a Romanian letter typed into the boxes becomes its plain letter', (tester) async {
    String? typed;
    await pumpUi(tester, _onNavy(CodeBoxesInput(length: 5, onChanged: (v) => typed = v, onDark: true)));
    await tester.enterText(find.byType(TextField), 'șarpe');
    await tester.pump();
    expect(typed, 'SARPE');
    expect(find.text('S'), findsOneWidget);
  });

  testWidgets('AvatarStack with a gap: side by side, no ring, empty places dashed', (tester) async {
    await pumpUi(
      tester,
      _onNavy(const AvatarStack(initials: ['VC', 'AM', 'IR'], total: 4, size: 30, onDark: true, gap: 6)),
    );
    expect(tester.getSize(find.byType(AvatarStack)), const Size(138, 30));
    final third = find.ancestor(of: find.text('IR'), matching: find.byType(Container)).first;
    final stackLeft = tester.getTopLeft(find.byType(AvatarStack)).dx;
    expect(tester.getTopLeft(third).dx - stackLeft, 72);
    expect((tester.widget<Container>(third).decoration as BoxDecoration).border, isNull);
  });

  test('the error tokens on navy', () {
    for (final c in [AppColors.light, AppColors.dark]) {
      expect(c.dangerOnNavy, const Color(0xFFEF6A6E));
      expect(c.dangerTextOnNavy, const Color(0xFFF7C1C1));
    }
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
