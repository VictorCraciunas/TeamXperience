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

    testWidgets('highlightNext marks the first empty place with a plus', (tester) async {
      await pumpUi(tester, stack(total: 4, highlightNext: true));
      expect(find.byIcon(TablerIcons.plus), findsOneWidget);
      final dashed = tester.widget<DashedBorder>(find.byType(DashedBorder).first);
      expect(dashed.color, AppColors.light.tick);
      expect(dashed.fill, AppColors.light.panel);
      expect(tester.widget<Icon>(find.byIcon(TablerIcons.plus)).color, AppColors.light.accent);
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

    testWidgets('error draws every box border in the danger colour', (tester) async {
      await pumpUi(tester, _codeBoxes(error: true));
      for (var i = 0; i < 6; i++) {
        expect(_borderColor(tester, find.byKey(ValueKey('code-box-$i'))), AppColors.light.danger);
      }
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
      // The phone's share sheet, not WhatsApp itself, so a share icon.
      expect(find.byIcon(TablerIcons.share), findsOneWidget);
      expect(find.byIcon(TablerIcons.brand_whatsapp), findsNothing);
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
    testWidgets('ok shows its text', (tester) async {
      await pumpUi(tester, const FieldStatusLine(text: 'Numele e liber', status: FieldStatus.ok));
      expect(find.text('Numele e liber'), findsOneWidget);
    });

    testWidgets('checking shows a spinner and neutral shows no icon', (tester) async {
      await pumpUi(tester, const FieldStatusLine(text: 'Verific...', status: FieldStatus.checking));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

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
