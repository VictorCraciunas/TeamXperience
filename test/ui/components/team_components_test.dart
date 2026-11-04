import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/feedback/field_status_line.dart';
import 'package:teamxperience/ui/components/inputs/code_boxes_input.dart';
import 'package:teamxperience/ui/components/inputs/size_picker.dart';
import 'package:teamxperience/ui/components/misc/avatar_stack.dart';
import 'package:teamxperience/ui/components/misc/dashed_border.dart';
import 'package:teamxperience/ui/components/team/invite_code_card.dart';
import 'package:teamxperience/ui/theme/app_colors.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

import '../pump_ui.dart';
import '../theme/contrast_test.dart' show contrast;

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
    Widget stack({
      List<String> initials = const ['VC', 'AM'],
      int? total,
      bool onDark = false,
      bool highlightNext = false,
    }) {
      return Align(
        alignment: Alignment.topLeft,
        child: AvatarStack(
          initials: initials,
          total: total,
          onDark: onDark,
          highlightNext: highlightNext,
        ),
      );
    }

    testWidgets('shows the initials and the empty places up to the total', (tester) async {
      await pumpUi(tester, stack(total: 4));
      expect(find.text('VC'), findsOneWidget);
      expect(find.text('AM'), findsOneWidget);
      expect(find.textContaining('+'), findsNothing);
      expect(find.byType(DashedBorder), findsNWidgets(2));
    });

    testWidgets('has no empty places when every member has a circle', (tester) async {
      await pumpUi(tester, stack(total: 2));
      expect(find.byType(DashedBorder), findsNothing);
    });

    testWidgets('empty places are dashed 2 px circles in the border colour with no fill', (
      tester,
    ) async {
      await pumpUi(tester, stack(total: 3));
      final dashed = tester.widget<DashedBorder>(find.byType(DashedBorder));
      expect(dashed.color, AppColors.light.border);
      expect(dashed.width, 2);
      expect(dashed.circle, isTrue);
      expect(dashed.fill, isNull);
    });

    testWidgets('filled members cycle navy, amber, accent, tick', (tester) async {
      await pumpUi(tester, stack(initials: ['A', 'B', 'C', 'D', 'E']));
      Color? fillOf(String initial) {
        final circle = find.ancestor(of: find.text(initial), matching: find.byType(Container));
        return (tester.widget<Container>(circle.first).decoration as BoxDecoration).color;
      }

      expect(fillOf('A'), AppColors.light.navy);
      expect(fillOf('B'), AppColors.light.soon);
      expect(fillOf('C'), AppColors.light.accent);
      expect(fillOf('D'), AppColors.light.tick);
      expect(fillOf('E'), AppColors.light.navy);
      expect(tester.widget<Text>(find.text('A')).style?.color, AppColors.light.onNavy);
      expect(tester.widget<Text>(find.text('B')).style?.color, AppColors.light.onTick);
    });

    for (final (themeName, theme, colors) in [
      ('light', AppTheme.light, AppColors.light),
      ('dark', AppTheme.dark, AppColors.dark),
    ]) {
      testWidgets('on a dark card the fills cycle tickOnNavy, amber, onNavy, pale teal and stay readable ($themeName)', (
        tester,
      ) async {
        await pumpUi(
          tester,
          stack(initials: ['A', 'B', 'C', 'D', 'E'], onDark: true),
          theme: theme,
        );
        Color? fillOf(String initial) {
          final circle = find.ancestor(of: find.text(initial), matching: find.byType(Container));
          return (tester.widget<Container>(circle.first).decoration as BoxDecoration).color;
        }

        final pale = Color.alphaBlend(colors.tickOnNavy.withValues(alpha: 0.2), colors.onNavy);
        final expected = [colors.tickOnNavy, colors.soon, colors.onNavy, pale, colors.tickOnNavy];
        for (final (i, initial) in ['A', 'B', 'C', 'D', 'E'].indexed) {
          expect(fillOf(initial), expected[i]);
          expect(tester.widget<Text>(find.text(initial)).style?.color, colors.onTick);
          expect(contrast(colors.onTick, expected[i]), greaterThanOrEqualTo(4.5));
        }
      });
    }

    testWidgets('on a dark card in the light theme the fills are the mockup colours', (tester) async {
      await pumpUi(tester, stack(initials: ['A', 'B', 'C', 'D'], onDark: true));
      Color? fillOf(String initial) {
        final circle = find.ancestor(of: find.text(initial), matching: find.byType(Container));
        return (tester.widget<Container>(circle.first).decoration as BoxDecoration).color;
      }

      expect(fillOf('A'), const Color(0xFF53C4C7));
      expect(fillOf('B'), const Color(0xFFF2A93B));
      expect(fillOf('C'), const Color(0xFFFFFFFF));
      final pale = fillOf('D');
      expect(pale, isNotNull);
      // The mockup's #DDF3F3, give or take a rounding step.
      expect(pale?.toARGB32() ?? 0, closeTo(0xFFDDF3F3, 0x020202));
    });

    testWidgets('highlightNext marks the first empty place with a plus', (tester) async {
      await pumpUi(tester, stack(total: 4, highlightNext: true));
      expect(find.byIcon(TablerIcons.plus), findsOneWidget);
      final dashed = tester.widget<DashedBorder>(find.byType(DashedBorder).first);
      expect(dashed.color, AppColors.light.tick);
      expect(dashed.fill, AppColors.light.panel);
      expect(tester.widget<Icon>(find.byIcon(TablerIcons.plus)).color, AppColors.light.accent);
    });

    testWidgets('circles are 30 across and overlap by 8', (tester) async {
      await pumpUi(tester, stack());
      expect(tester.getSize(find.byType(AvatarStack)).width, 30 + 22);
      expect(tester.getSize(find.byType(AvatarStack)).height, 30);
    });

    testWidgets('on a dark card the overlap is 6 and empty places use onNavyMuted', (tester) async {
      await pumpUi(tester, stack(total: 3, onDark: true));
      expect(tester.getSize(find.byType(AvatarStack)).width, 30 + 24 * 2);
      expect(
        tester.widget<DashedBorder>(find.byType(DashedBorder)).color,
        AppColors.light.onNavyMuted,
      );
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

    testWidgets('a long press pastes the clipboard, cleaned, into the boxes', (tester) async {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (
        call,
      ) async {
        if (call.method == 'Clipboard.getData') return <String, dynamic>{'text': ' vlp-482 '};
        return null;
      });
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      String? completed;
      String? latest;
      await pumpUi(
        tester,
        _codeBoxes(onChanged: (v) => latest = v, onCompleted: (v) => completed = v),
      );
      await tester.longPress(find.byType(CodeBoxesInput));
      await tester.pump();
      expect(latest, 'VLP482');
      expect(completed, 'VLP482');
      for (final c in ['V', 'L', 'P', '4', '8', '2']) {
        expect(find.text(c), findsOneWidget);
      }
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

    testWidgets('filled boxes and the next one have the tick border, the rest the plain one', (
      tester,
    ) async {
      await pumpUi(tester, _codeBoxes());
      await tester.tap(find.byType(CodeBoxesInput));
      await tester.enterText(find.byType(TextField), 'vl');
      await tester.pump();
      for (final i in [0, 1, 2]) {
        expect(
          _borderColor(tester, find.byKey(ValueKey('code-box-$i'))),
          AppColors.light.tick,
        );
      }
      for (final i in [3, 4, 5]) {
        expect(
          _borderColor(tester, find.byKey(ValueKey('code-box-$i'))),
          AppColors.light.border,
        );
      }
    });

    testWidgets('error draws every box border in the danger colour', (tester) async {
      await pumpUi(tester, _codeBoxes(error: true));
      for (var i = 0; i < 6; i++) {
        expect(_borderColor(tester, find.byKey(ValueKey('code-box-$i'))), AppColors.light.danger);
      }
    });

    testWidgets('boxes are 34 x 47 with a 1 px border and a radius of 12', (tester) async {
      await pumpUi(tester, _codeBoxes());
      final box = find.byKey(const ValueKey('code-box-0'));
      expect(tester.getSize(box), const Size(34, 47));
      final decoration =
          tester.widget<DecoratedBox>(find.descendant(of: box, matching: find.byType(DecoratedBox)).first).decoration
              as BoxDecoration;
      expect((decoration.border as Border).top.width, 1);
      expect(decoration.borderRadius, BorderRadius.circular(12));
    });

    testWidgets('boxes sit 6 px apart and the dash has 6 px either side', (tester) async {
      await pumpUi(tester, _codeBoxes());
      Rect rect(int i) => tester.getRect(find.byKey(ValueKey('code-box-$i')));
      expect(rect(1).left - rect(0).right, 6);
      final dash = tester.getRect(find.text('-'));
      expect(dash.left - rect(2).right, 6);
      expect(rect(3).left - dash.right, 6);
      expect(dash.center.dy, closeTo(rect(2).center.dy, 0.5));
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

    testWidgets('the boxes share the width equally with 5 between them', (tester) async {
      await pumpUi(tester, picker((_) {}));
      final first = tester.getRect(find.byKey(const ValueKey('size-picker-2')));
      final second = tester.getRect(find.byKey(const ValueKey('size-picker-3')));
      final last = tester.getRect(find.byKey(const ValueKey('size-picker-6')));
      expect(first.width, closeTo((360 - 4 * 5) / 5, .01));
      expect(second.width, first.width);
      expect(second.left - first.right, 5);
      expect(last.right, closeTo(360, .01));
    });

    testWidgets('a box is a 12 radius rectangle, 1 px border plus 7 of padding tall', (tester) async {
      await pumpUi(tester, picker((_) {}));
      final box = find.byKey(const ValueKey('size-picker-2'));
      final decoration = tester.widget<DecoratedBox>(box).decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(12));
      expect((decoration.border as Border).top.width, 1);
      expect(tester.getSize(box).height, closeTo(2 * 8 + 12 * 1.45, .5));
    });

    testWidgets('the chosen box has a navy border and a medium-weight number', (tester) async {
      await pumpUi(tester, picker((_) {}));
      final decoration =
          tester.widget<DecoratedBox>(find.byKey(const ValueKey('size-picker-4'))).decoration as BoxDecoration;
      expect((decoration.border as Border).top.color, AppColors.light.navy);
      expect(tester.widget<Text>(find.text('4')).style?.fontWeight, FontWeight.w500);
    });

    testWidgets('a long range wraps into rows of equal boxes', (tester) async {
      await pumpUi(tester, SizePicker(min: 2, max: 20, value: 4, onChanged: (_) {}));
      expect(tester.takeException(), isNull);
      final first = tester.getRect(find.byKey(const ValueKey('size-picker-2')));
      final ninth = tester.getRect(find.byKey(const ValueKey('size-picker-10')));
      expect(ninth.top, greaterThan(first.top));
      expect(ninth.width, first.width);
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

    testWidgets('is a navy card with a dashed code box, as in mockup 04', (tester) async {
      await pumpUi(tester, _inviteCard());
      final card = find.byKey(const ValueKey('invite-code-card'));
      final decoration = tester.widget<DecoratedBox>(card).decoration as BoxDecoration;
      expect(decoration.color, AppColors.light.navy);
      expect(decoration.borderRadius, BorderRadius.circular(22));
      final dashed = tester.widget<DashedBorder>(find.byType(DashedBorder));
      expect(dashed.color, AppColors.light.onNavyMuted);
      expect(dashed.width, 1.5);
      expect(dashed.radius, 12);
      final style = tester.widget<Text>(find.text('VLP-482')).style;
      expect(style?.fontSize, 26);
      expect(style?.fontWeight, FontWeight.w500);
      expect(style?.letterSpacing, 4);
      expect(style?.color, AppColors.light.onNavy);
    });

    testWidgets('WhatsApp is teal with dark text, copy is a faint white', (tester) async {
      await pumpUi(tester, _inviteCard());
      Material button(String label) => tester.widget<Material>(
        find.ancestor(of: find.text(label), matching: find.byType(Material)).first,
      );
      expect(button('WhatsApp').color, AppColors.light.tickOnNavy);
      expect(tester.widget<Text>(find.text('WhatsApp')).style?.color, AppColors.light.onTick);
      expect(button('Copiază').color, AppColors.light.onNavy.withValues(alpha: .12));
      expect(tester.widget<Text>(find.text('Copiază')).style?.color, AppColors.light.onNavy);
    });

    testWidgets('shows a footer under the buttons', (tester) async {
      await pumpUi(
        tester,
        InviteCodeCard(
          code: 'VLP-482',
          shareLabel: 'WhatsApp',
          copyLabel: 'Copiază',
          onShare: () {},
          onCopy: () {},
          footer: const Text('1 din 4 în echipă'),
        ),
      );
      expect(find.text('1 din 4 în echipă'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('1 din 4 în echipă')).dy,
        greaterThan(tester.getBottomLeft(find.text('Copiază')).dy),
      );
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
