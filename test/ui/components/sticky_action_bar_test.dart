import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/buttons/bar_tone.dart';
import 'package:teamxperience/ui/components/buttons/sticky_action_bar.dart';
import 'package:teamxperience/ui/theme/app_colors.dart';

import '../pump_ui.dart';

Color _topBorder(WidgetTester tester) {
  final box = tester.widget<DecoratedBox>(
    find.descendant(of: find.byType(StickyActionBar), matching: find.byType(DecoratedBox)).first,
  );
  return ((box.decoration as BoxDecoration).border as Border).top.color;
}

void main() {
  testWidgets('the prominent bar shows its texts and calls onAction', (tester) async {
    var taps = 0;
    await pumpUi(
      tester,
      StickyActionBar(
        title: 'Mai sunt 5 zile',
        detail: '12 echipe înscrise',
        actionLabel: 'Înscrie echipa',
        actionIcon: TablerIcons.users_plus,
        onAction: () => taps++,
      ),
    );
    expect(find.text('Mai sunt 5 zile'), findsOneWidget);
    expect(find.text('12 echipe înscrise'), findsOneWidget);
    await tester.tap(find.text('Înscrie echipa'));
    expect(taps, 1);
  });

  testWidgets('the inline variant puts the detail after the title', (tester) async {
    await pumpUi(
      tester,
      StickyActionBar(
        title: 'Vulpile',
        detail: '4 membri',
        inlineDetail: true,
        leadingIcon: TablerIcons.circle_check,
        tone: BarTone.success,
        actionLabel: 'Echipa ta',
        prominent: false,
        onAction: () {},
      ),
    );
    expect(find.textContaining('Vulpile', findRichText: true), findsOneWidget);
    expect(find.textContaining(' · 4 membri', findRichText: true), findsOneWidget);
    expect(find.text('4 membri'), findsNothing);
    final icon = tester.widget<Icon>(find.byIcon(TablerIcons.circle_check));
    expect(icon.color, AppColors.light.success);
  });

  testWidgets('a quiet action is still tappable with a 48 tall hit area', (tester) async {
    var taps = 0;
    await pumpUi(
      tester,
      StickyActionBar(title: 'A început', actionLabel: 'Introdu codul', prominent: false, onAction: () => taps++),
    );
    await tester.tap(find.text('Introdu codul'));
    expect(taps, 1);
    final hit = find.ancestor(of: find.text('Introdu codul'), matching: find.byType(InkWell)).first;
    expect(tester.getSize(hit).height, greaterThanOrEqualTo(48));
  });

  testWidgets('highlighted bars have a tick top border', (tester) async {
    await pumpUi(tester, const StickyActionBar(title: 'A început', actionLabel: 'Introdu codul', highlighted: true));
    expect(_topBorder(tester), AppColors.light.tick);
  });

  testWidgets('normal bars have a border-coloured top border', (tester) async {
    await pumpUi(tester, const StickyActionBar(title: 'A început', actionLabel: 'Introdu codul'));
    expect(_topBorder(tester), AppColors.light.border);
  });

  testWidgets('a long title fits a narrow phone with large text', (tester) async {
    await pumpUi(
      tester,
      StickyActionBar(
        title: 'Înscrierile se închid foarte curând pentru acest eveniment',
        detail: '12 echipe înscrise',
        actionLabel: 'Înscrie echipa',
        actionIcon: TablerIcons.users_plus,
        onAction: () {},
      ),
      width: 320,
      textScale: 1.3,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('a long action label with an icon shrinks instead of overflowing', (tester) async {
    await pumpUi(
      tester,
      StickyActionBar(
        title: 'A început',
        detail: '42 min să intri',
        inlineDetail: true,
        leadingIcon: TablerIcons.player_play,
        tone: BarTone.accent,
        actionLabel: 'Introdu codul de start acum',
        actionIcon: TablerIcons.player_play,
        onAction: () {},
      ),
      width: 320,
      textScale: 1.3,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('the bar has the mockup height (1 + 10 + 37.4 button + 10)', (tester) async {
    await pumpUi(
      tester,
      StickyActionBar(title: 'A', detail: 'B', actionLabel: 'C', onAction: () {}),
    );
    expect(tester.getSize(find.byType(StickyActionBar)).height, closeTo(58.4, 0.5));
  });

  testWidgets('the leading icon sits 8 before the text', (tester) async {
    await pumpUi(
      tester,
      StickyActionBar(
        title: 'Vulpile',
        leadingIcon: TablerIcons.circle_check,
        actionLabel: 'Echipa ta',
        prominent: false,
        onAction: () {},
      ),
    );
    final iconRight = tester.getTopRight(find.byIcon(TablerIcons.circle_check)).dx;
    final textLeft = tester.getTopLeft(find.text('Vulpile')).dx;
    expect(textLeft - iconRight, 8);
  });

  testWidgets('a bar without an action shows only its status', (tester) async {
    await pumpUi(
      tester,
      const StickyActionBar(title: 'Înscrierile se deschid pe 1 nov, așa că mai ai puțin de așteptat'),
      width: 320,
      textScale: 1.3,
    );
    expect(find.textContaining('Înscrierile se deschid'), findsOneWidget);
    expect(find.byType(InkWell), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
