import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/register_team/widgets/invite_result_section.dart';
import 'package:teamxperience/ui/components/misc/avatar_stack.dart';
import 'package:teamxperience/ui/theme/app_colors.dart';

import '../../ui/pump_ui.dart';

Widget _section({
  List<String> initials = const ['VC'],
  List<String> leftOut = const [],
VoidCallback? onShare, VoidCallback? onCopy, int size = 4}) =>
    InviteResultSection(
      code: 'VLP-482',
      size: size,
      initials: initials,
      leftOut: leftOut,
      onShare: onShare ?? () {},
      onCopy: onCopy ?? () {},
    );

void main() {
  testWidgets('a crew signed up: everyone who came, and who did not', (tester) async {
    await pumpUi(tester, _section(initials: const ['VC', 'AP'], leftOut: const ['Dan Ion']));
    expect(find.text('2 din 4 în echipă'), findsOneWidget);
    expect(find.textContaining('Dan Ion'), findsOneWidget);
  });

  testWidgets('shows the caption, the code and the two buttons', (
    tester,
  ) async {
    await pumpUi(tester, _section());
    expect(find.text('Gata. Trimite codul coechipierilor'), findsOneWidget);
    expect(find.text('VLP-482'), findsOneWidget);
    expect(find.text('WhatsApp'), findsOneWidget);
    expect(find.text('Copiază'), findsOneWidget);
  });

  testWidgets('the buttons call their callbacks', (tester) async {
    var shared = 0;
    var copied = 0;
    await pumpUi(
      tester,
      _section(onShare: () => shared++, onCopy: () => copied++),
    );
    await tester.tap(find.text('WhatsApp'));
    await tester.tap(find.text('Copiază'));
    expect((shared, copied), (1, 1));
  });

  testWidgets('the footer is the captain among the empty places, on dark', (
    tester,
  ) async {
    await pumpUi(tester, _section(size: 4));
    final stack = tester.widget<AvatarStack>(find.byType(AvatarStack));
    expect(stack.initials, ['VC']);
    expect(stack.total, 4);
    expect(stack.onDark, isTrue);
    expect(find.text('VC'), findsOneWidget);
    final text = tester.widget<Text>(find.text('1 din 4 în echipă'));
    expect(text.style?.fontSize, 11);
    expect(text.style?.color, AppColors.light.onNavy.withValues(alpha: .8));
  });

  testWidgets('lays out at 320 wide and 1.3x text without an exception', (
    tester,
  ) async {
    await pumpUi(tester, _section(size: 6), width: 320, textScale: 1.3);
    expect(tester.takeException(), isNull);
  });
}
