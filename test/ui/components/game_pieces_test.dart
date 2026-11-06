import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/game/attempt_dots.dart';
import 'package:teamxperience/ui/components/game/game_icon_button.dart';
import 'package:teamxperience/ui/components/game/game_outline_button.dart';
import 'package:teamxperience/ui/components/game/mission_segments.dart';
import 'package:teamxperience/ui/components/game/round_icon_button.dart';
import 'package:teamxperience/ui/theme/app_colors.dart';
import 'package:teamxperience/ui/theme/event_palette.dart';
import 'package:teamxperience/ui/theme/event_palette_resolver.dart';
import 'package:teamxperience/ui/theme/event_theme_scope.dart';

import '../pump_ui.dart';

const _parchment = EventPalette.parchment;

final _neon = resolveEventPalette(
  hints: const StyleHints(
    background: Color(0xFF0A0F0A),
    surface: Color(0xFF111A11),
    ink: Color(0xFFB8FFC8),
    accent: Color(0xFF33FF66),
    glow: Color(0xFF00CC44),
  ),
  app: AppColors.light,
);

Future<void> _pump(WidgetTester tester, Widget child, {EventPalette palette = _parchment, double width = 316, double textScale = 1}) {
  return pumpUi(
    tester,
    EventThemeScope(palette: palette, child: Center(child: child)),
    width: width,
    textScale: textScale,
  );
}

Color? _fill(WidgetTester tester, Finder finder) {
  final box = tester.widget<DecoratedBox>(finder);
  return (box.decoration as BoxDecoration).color;
}

BoxBorder? _border(WidgetTester tester, Finder finder) {
  final box = tester.widget<DecoratedBox>(finder);
  return (box.decoration as BoxDecoration).border;
}

void main() {
  group('RoundIconButton', () {
    testWidgets('a 32 px circle in ink at 10 % with a 16 px icon', (tester) async {
      var taps = 0;
      await _pump(tester, RoundIconButton(icon: TablerIcons.x, label: 'Închide', onTap: () => taps++));
      final circle = find.byKey(const ValueKey('round-icon-button'));
      expect(tester.getSize(circle), const Size(32, 32));
      expect(_fill(tester, circle), _parchment.ink.withValues(alpha: .1));
      final icon = tester.widget<Icon>(find.byIcon(TablerIcons.x));
      expect((icon.size, icon.color), (16, _parchment.ink));
      await tester.tap(circle);
      expect(taps, 1);
      expect(find.bySemanticsLabel('Închide'), findsOneWidget);
    });

    testWidgets('follows another event\'s colours', (tester) async {
      await _pump(tester, RoundIconButton(icon: TablerIcons.x, onTap: () {}), palette: _neon);
      expect(tester.widget<Icon>(find.byIcon(TablerIcons.x)).color, _neon.ink);
    });
  });

  group('MissionSegments', () {
    testWidgets('done in accent, the current in the second accent, the rest faint', (tester) async {
      await _pump(tester, const SizedBox(width: 288, child: MissionSegments(total: 6, done: 3)));
      final colours = [for (var i = 0; i < 6; i++) _fill(tester, find.byKey(ValueKey('segment-$i')))];
      final faint = _parchment.ink.withValues(alpha: .18);
      expect(colours, [
        _parchment.accent,
        _parchment.accent,
        _parchment.accent,
        _parchment.secondaryAccent,
        faint,
        faint,
      ]);
    });

    testWidgets('5 px bars, 3 apart, sharing the width', (tester) async {
      await _pump(tester, const SizedBox(width: 288, child: MissionSegments(total: 6, done: 3)));
      final first = tester.getRect(find.byKey(const ValueKey('segment-0')));
      final second = tester.getRect(find.byKey(const ValueKey('segment-1')));
      expect(first.height, 5);
      expect(second.left - first.right, 3);
      expect(first.width, closeTo((288 - 5 * 3) / 6, 0.01));
    });

    testWidgets('all done: no current bar', (tester) async {
      await _pump(tester, const SizedBox(width: 288, child: MissionSegments(total: 3, done: 3)));
      expect(_fill(tester, find.byKey(const ValueKey('segment-2'))), _parchment.accent);
    });

    testWidgets('neon colours', (tester) async {
      await _pump(tester, const SizedBox(width: 288, child: MissionSegments(total: 2, done: 1)), palette: _neon);
      expect(_fill(tester, find.byKey(const ValueKey('segment-0'))), _neon.accent);
      expect(_fill(tester, find.byKey(const ValueKey('segment-1'))), _neon.secondaryAccent);
    });
  });

  group('AttemptDots', () {
    testWidgets('the attempts left are filled, the used ones are rings', (tester) async {
      await _pump(tester, const AttemptDots(max: 3, left: 2));
      for (var i = 0; i < 3; i++) {
        expect(tester.getSize(find.byKey(ValueKey('attempt-$i'))), const Size(8, 8));
      }
      expect(_fill(tester, find.byKey(const ValueKey('attempt-0'))), _parchment.accent);
      expect(_fill(tester, find.byKey(const ValueKey('attempt-1'))), _parchment.accent);
      expect(_fill(tester, find.byKey(const ValueKey('attempt-2'))), isNull);
      final ring = _border(tester, find.byKey(const ValueKey('attempt-2'))) as Border;
      expect((ring.top.width, ring.top.color), (1.5, _parchment.accent));
      expect(find.text('2 încercări rămase'), findsOneWidget);
    });

    testWidgets('dots 5 apart, the label 4 more after them', (tester) async {
      await _pump(tester, const AttemptDots(max: 3, left: 2));
      final a = tester.getRect(find.byKey(const ValueKey('attempt-0')));
      final b = tester.getRect(find.byKey(const ValueKey('attempt-1')));
      final c = tester.getRect(find.byKey(const ValueKey('attempt-2')));
      expect(b.left - a.right, 5);
      expect(tester.getTopLeft(find.text('2 încercări rămase')).dx - c.right, 9);
      final label = tester.widget<Text>(find.text('2 încercări rămase')).style;
      expect((label?.fontSize, label?.color), (11, _parchment.ink.withValues(alpha: .8)));
    });

    testWidgets('one left, and twenty', (tester) async {
      await _pump(tester, const AttemptDots(max: 3, left: 1));
      expect(find.text('1 încercare rămasă'), findsOneWidget);
      await _pump(tester, const AttemptDots(max: 20, left: 20));
      expect(find.text('20 de încercări rămase'), findsOneWidget);
    });

    testWidgets('neon colours', (tester) async {
      await _pump(tester, const AttemptDots(max: 2, left: 1), palette: _neon);
      expect(_fill(tester, find.byKey(const ValueKey('attempt-0'))), _neon.accent);
    });
  });

  group('GameOutlineButton', () {
    testWidgets('a 1.5 px accent outline, radius 12, accent label with its icon', (tester) async {
      var taps = 0;
      await _pump(tester, GameOutlineButton(label: 'Indiciu', icon: TablerIcons.bulb, onTap: () => taps++));
      final frame = find.byKey(const ValueKey('game-outline-button'));
      final decoration = tester.widget<DecoratedBox>(frame).decoration as BoxDecoration;
      final border = decoration.border as Border;
      expect((border.top.width, border.top.color), (1.5, _parchment.accent));
      expect(decoration.borderRadius, BorderRadius.circular(12));
      final text = tester.widget<Text>(find.text('Indiciu')).style;
      expect((text?.color, text?.fontWeight, text?.fontSize), (_parchment.accent, FontWeight.w500, 12));
      expect(tester.widget<Icon>(find.byIcon(TablerIcons.bulb)).size, 15);
      await tester.tap(frame);
      expect(taps, 1);
    });

    testWidgets('greyed without a tap', (tester) async {
      await _pump(tester, const GameOutlineButton(label: 'Indiciu'));
      final opacity = tester.widget<Opacity>(find.ancestor(of: find.text('Indiciu'), matching: find.byType(Opacity)));
      expect(opacity.opacity, .5);
    });
  });

  group('GameIconButton', () {
    testWidgets('42 px, accent fill, icon on accent', (tester) async {
      var taps = 0;
      await _pump(tester, GameIconButton(icon: TablerIcons.message_circle, label: 'Chat', onTap: () => taps++));
      final frame = find.byKey(const ValueKey('game-icon-button'));
      expect(tester.getSize(frame), const Size(42, 42));
      expect(_fill(tester, frame), _parchment.accent);
      expect(tester.widget<Icon>(find.byIcon(TablerIcons.message_circle)).color, _parchment.onAccent);
      await tester.tap(frame);
      expect(taps, 1);
    });
  });

  testWidgets('a row of all of them fits 320 px at 1.3x text', (tester) async {
    await _pump(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            RoundIconButton(icon: TablerIcons.arrow_left, onTap: () {}),
            const Expanded(child: MissionSegments(total: 12, done: 5)),
          ]),
          const AttemptDots(max: 20, left: 20),
          Row(children: [
            const Expanded(child: GameOutlineButton(label: 'Indiciu', icon: TablerIcons.bulb)),
            const SizedBox(width: 8),
            GameIconButton(icon: TablerIcons.message_circle, onTap: () {}),
          ]),
        ],
      ),
      width: 320,
      textScale: 1.3,
    );
    expect(tester.takeException(), isNull);
  });
}
