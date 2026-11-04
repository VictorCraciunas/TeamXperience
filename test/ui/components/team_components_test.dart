import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/feedback/field_status_line.dart';
import 'package:teamxperience/ui/components/inputs/code_boxes_input.dart';
import 'package:teamxperience/ui/components/inputs/size_picker.dart';
import 'package:teamxperience/ui/components/misc/avatar_stack.dart';
import 'package:teamxperience/ui/components/team/invite_code_card.dart';
import 'package:teamxperience/ui/theme/app_colors.dart';

import '../pump_ui.dart';

Color? _fill(WidgetTester tester, Finder box) =>
    (tester.widget<DecoratedBox>(box).decoration as BoxDecoration).color;

Color _borderColor(WidgetTester tester, Finder box) {
  final decoration =
      tester
              .widget<DecoratedBox>(
                find.descendant(of: box, matching: find.byType(DecoratedBox)).first,
              )
              .decoration
          as BoxDecoration;
  return (decoration.border as Border).top.color;
}

Widget _codeBoxes({
  bool error = false,
  ValueChanged<String>? onChanged,
  ValueChanged<String>? onCompleted,
}) {
  return CodeBoxesInput(
    length: 6,
    dashAfter: 3,
    error: error,
    onChanged: onChanged ?? (_) {},
    onCompleted: onCompleted,
  );
}

Widget _inviteCard({VoidCallback? onShare, VoidCallback? onCopy, String? caption}) {
  return InviteCodeCard(
    code: 'VLP-482',
    caption: caption,
    shareLabel: 'WhatsApp',
    copyLabel: 'Copiază',
    onShare: onShare ?? () {},
    onCopy: onCopy ?? () {},
  );
}

void main() {
  group('AvatarStack', () {
    testWidgets('shows the initials and the number of the others', (tester) async {
      await pumpUi(tester, const AvatarStack(initials: ['VC', 'AM'], total: 4));
      expect(find.text('VC'), findsOneWidget);
      expect(find.text('AM'), findsOneWidget);
      expect(find.text('+2'), findsOneWidget);
    });

    testWidgets('shows no "+N" when every member has a circle', (tester) async {
      await pumpUi(tester, const AvatarStack(initials: ['VC', 'AM'], total: 2));
      expect(find.textContaining('+'), findsNothing);
    });

    testWidgets('circles overlap by 8', (tester) async {
      await pumpUi(
        tester,
        const Align(alignment: Alignment.topLeft, child: AvatarStack(initials: ['VC', 'AM'])),
      );
      expect(tester.getSize(find.byType(AvatarStack)).width, 28 + 20);
    });
  });

  group('CodeBoxesInput', () {
    testWidgets('typing fills the boxes in capitals and completes', (tester) async {
      String? completed;
      await pumpUi(tester, _codeBoxes(onCompleted: (v) => completed = v));
      await tester.enterText(find.byType(TextField), 'vlp482');
      await tester.pump();
      expect(completed, 'VLP482');
      for (final c in ['V', 'L', 'P', '4', '8', '2']) {
        expect(find.text(c), findsOneWidget);
      }
      expect(find.text('-'), findsOneWidget);
    });

    testWidgets('a pasted code with a dash and spaces fills every box', (tester) async {
      String? completed;
      await pumpUi(tester, _codeBoxes(onCompleted: (v) => completed = v));
      await tester.enterText(find.byType(TextField), ' vlp-482 ');
      await tester.pump();
      expect(completed, 'VLP482');
    });

    testWidgets('does not complete before the last box', (tester) async {
      var completed = false;
      String? latest;
      await pumpUi(
        tester,
        _codeBoxes(onChanged: (v) => latest = v, onCompleted: (_) => completed = true),
      );
      await tester.enterText(find.byType(TextField), 'vlp4');
      await tester.pump();
      expect(latest, 'VLP4');
      expect(completed, isFalse);
    });

    testWidgets('extra characters are cut off', (tester) async {
      String? latest;
      await pumpUi(tester, _codeBoxes(onChanged: (v) => latest = v));
      await tester.enterText(find.byType(TextField), 'vlp4829');
      await tester.pump();
      expect(latest, 'VLP482');
    });

    testWidgets('deleting the last character empties the last box', (tester) async {
      await pumpUi(tester, _codeBoxes());
      await tester.enterText(find.byType(TextField), 'vlp48');
      await tester.pump();
      expect(find.text('8'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'vlp4');
      await tester.pump();
      expect(find.text('8'), findsNothing);
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('the next box to fill has the tick border, the rest the plain one', (tester) async {
      await pumpUi(tester, _codeBoxes());
      await tester.tap(find.byType(CodeBoxesInput));
      await tester.enterText(find.byType(TextField), 'vl');
      await tester.pump();
      expect(_borderColor(tester, find.byKey(const ValueKey('code-box-2'))), AppColors.light.tick);
      expect(
        _borderColor(tester, find.byKey(const ValueKey('code-box-1'))),
        AppColors.light.border,
      );
      expect(
        _borderColor(tester, find.byKey(const ValueKey('code-box-3'))),
        AppColors.light.border,
      );
    });

    testWidgets('error draws every box border in the danger colour', (tester) async {
      await pumpUi(tester, _codeBoxes(error: true));
      for (var i = 0; i < 6; i++) {
        expect(_borderColor(tester, find.byKey(ValueKey('code-box-$i'))), AppColors.light.danger);
      }
    });

    testWidgets('boxes are 38 x 46', (tester) async {
      await pumpUi(tester, _codeBoxes());
      expect(tester.getSize(find.byKey(const ValueKey('code-box-0'))), const Size(38, 46));
    });
  });

  group('SizePicker', () {
    Widget picker(ValueChanged<int> onChanged) =>
        SizePicker(min: 2, max: 6, value: 4, onChanged: onChanged);

    testWidgets('tapping a number reports it', (tester) async {
      int? picked;
      await pumpUi(tester, picker((n) => picked = n));
      await tester.tap(find.text('5'));
      expect(picked, 5);
    });

    testWidgets('the chosen number is navy with on-navy text, the rest are panel', (tester) async {
      await pumpUi(tester, picker((_) {}));
      expect(_fill(tester, find.byKey(const ValueKey('size-picker-4'))), AppColors.light.navy);
      expect(tester.widget<Text>(find.text('4')).style?.color, AppColors.light.onNavy);
      expect(_fill(tester, find.byKey(const ValueKey('size-picker-5'))), AppColors.light.panel);
      expect(tester.widget<Text>(find.text('5')).style?.color, AppColors.light.text);
    });

    testWidgets('buttons are 40 across', (tester) async {
      await pumpUi(tester, picker((_) {}));
      expect(tester.getSize(find.byKey(const ValueKey('size-picker-2'))), const Size(40, 40));
    });
  });

  group('InviteCodeCard', () {
    testWidgets('shows the code and the caption', (tester) async {
      await pumpUi(tester, _inviteCard(caption: 'Gata. Trimite codul coechipierilor'));
      expect(find.text('VLP-482'), findsOneWidget);
      expect(find.text('Gata. Trimite codul coechipierilor'), findsOneWidget);
      expect(find.byIcon(TablerIcons.brand_whatsapp), findsOneWidget);
      expect(find.byIcon(TablerIcons.copy), findsOneWidget);
    });

    testWidgets('both buttons call their callbacks', (tester) async {
      var shared = 0;
      var copied = 0;
      await pumpUi(tester, _inviteCard(onShare: () => shared++, onCopy: () => copied++));
      await tester.tap(find.text('WhatsApp'));
      expect(shared, 1);
      expect(copied, 0);
      await tester.tap(find.text('Copiază'));
      expect(copied, 1);
    });

    testWidgets('the code sits on the inset colour', (tester) async {
      await pumpUi(tester, _inviteCard());
      final box =
          find.ancestor(of: find.text('VLP-482'), matching: find.byType(DecoratedBox)).first;
      expect(_fill(tester, box), AppColors.light.inset);
      final style = tester.widget<Text>(find.text('VLP-482')).style;
      expect(style?.fontSize, 26);
      expect(style?.fontWeight, FontWeight.w700);
    });
  });

  group('FieldStatusLine', () {
    testWidgets('ok shows the check icon in the success colour', (tester) async {
      await pumpUi(tester, const FieldStatusLine(text: 'Numele e liber', status: FieldStatus.ok));
      expect(find.text('Numele e liber'), findsOneWidget);
      final icon = tester.widget<Icon>(find.byIcon(TablerIcons.circle_check));
      expect(icon.color, AppColors.light.success);
      expect(icon.size, 13);
    });

    testWidgets('problem shows the alert icon in the danger colour', (tester) async {
      await pumpUi(
        tester,
        const FieldStatusLine(text: 'Numele e luat', status: FieldStatus.problem),
      );
      expect(
        tester.widget<Icon>(find.byIcon(TablerIcons.alert_circle)).color,
        AppColors.light.danger,
      );
    });

    testWidgets('checking shows a 10 px spinner and neutral shows no icon', (tester) async {
      await pumpUi(tester, const FieldStatusLine(text: 'Verific...', status: FieldStatus.checking));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(tester.getSize(find.byType(CircularProgressIndicator)), const Size(10, 10));

      await pumpUi(
        tester,
        const FieldStatusLine(text: 'Între 2 și 30 de caractere', status: FieldStatus.neutral),
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(Icon), findsNothing);
    });
  });

  group('at 320 wide and 1.3x text', () {
    final cases = <String, Widget Function()>{
      'AvatarStack': () => const AvatarStack(initials: ['VC', 'AM', 'IR'], total: 112),
      'CodeBoxesInput': () => _codeBoxes(),
      'SizePicker': () => SizePicker(min: 2, max: 6, value: 4, onChanged: (_) {}),
      'InviteCodeCard': () => _inviteCard(caption: 'Gata. Trimite codul coechipierilor'),
      'FieldStatusLine':
          () => const FieldStatusLine(
            text: 'Acest nume e deja folosit de altă echipă din acest eveniment',
            status: FieldStatus.problem,
          ),
    };
    for (final entry in cases.entries) {
      testWidgets('${entry.key} lays out without an exception', (tester) async {
        await pumpUi(tester, entry.value(), width: 320, textScale: 1.3);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
