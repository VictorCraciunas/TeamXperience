import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/game/distance_compass.dart';
import 'package:teamxperience/ui/components/game/game_filled_button.dart';
import 'package:teamxperience/ui/components/game/photo_status_banner.dart';
import 'package:teamxperience/ui/theme/app_colors.dart';
import 'package:teamxperience/ui/theme/event_palette.dart';
import 'package:teamxperience/ui/theme/event_palette_resolver.dart';
import 'package:teamxperience/ui/theme/event_theme_scope.dart';

import '../pump_ui.dart';

const _p = EventPalette.parchment;
const _app = AppColors.light;

final _neon = resolveEventPalette(
  hints: const StyleHints(
    background: Color(0xFF0A0F0A),
    surface: Color(0xFF111A11),
    ink: Color(0xFFB8FFC8),
    accent: Color(0xFF33FF66),
  ),
  app: AppColors.light,
);

Future<void> _pump(WidgetTester tester, Widget child, {EventPalette palette = _p, double width = 316, double textScale = 1}) =>
    pumpUi(tester, EventThemeScope(palette: palette, child: child), width: width, textScale: textScale);

BoxDecoration _box(WidgetTester tester, String key) =>
    tester.widget<DecoratedBox>(find.byKey(ValueKey(key))).decoration as BoxDecoration;

void main() {
  group('GameFilledButton', () {
    testWidgets('the accent fill with its label on it', (tester) async {
      var taps = 0;
      await _pump(tester, GameFilledButton(label: 'Fă altă poză', icon: TablerIcons.camera, onTap: () => taps++));
      expect(_box(tester, 'game-filled-button').color, _p.accent);
      expect(_box(tester, 'game-filled-button').borderRadius, BorderRadius.circular(12));
      final label = tester.widget<Text>(find.text('Fă altă poză')).style;
      expect((label?.color, label?.fontWeight, label?.fontSize), (_p.onAccent, FontWeight.w500, 12));
      expect(tester.widget<Icon>(find.byIcon(TablerIcons.camera)).size, 15);
      await tester.tap(find.text('Fă altă poză'));
      expect(taps, 1);
    });

    testWidgets('disabled: the ink at 12 %, muted text, no tap', (tester) async {
      await _pump(tester, const GameFilledButton(label: 'Intră în cerc'));
      expect(_box(tester, 'game-filled-button').color, _p.ink.withValues(alpha: .12));
      expect(tester.widget<Text>(find.text('Intră în cerc')).style?.color, _p.muted);
      await tester.tap(find.text('Intră în cerc'));
    });
  });

  group('DistanceCompass', () {
    testWidgets('the arrow turned to the target, the distance, the line and the trend', (tester) async {
      await _pump(
        tester,
        const DistanceCompass(distance: '140 m', line: 'spre nord-est · ~2 min pe jos', bearing: 40, trend: 'mai aproape'),
      );
      expect(tester.getSize(find.byKey(const ValueKey('compass-arrow'))), const Size(46, 46));
      final turn = tester.widget<Transform>(
        find.ancestor(of: find.byIcon(TablerIcons.arrow_up), matching: find.byType(Transform)).first,
      );
      final expected = Matrix4.rotationZ(40 * math.pi / 180);
      for (var i = 0; i < 16; i++) {
        expect(turn.transform.storage[i], closeTo(expected.storage[i], 1e-9));
      }
      final distance = tester.widget<Text>(find.text('140 m')).style;
      expect((distance?.fontSize, distance?.fontWeight), (22, FontWeight.w500));
      expect(find.text('spre nord-est · ~2 min pe jos'), findsOneWidget);
      expect(tester.widget<Text>(find.text('mai aproape')).style?.color, _app.success);
      expect(_box(tester, 'distance-compass').color, _p.surface);
    });

    testWidgets('farther is in the danger colour; no trend, no text', (tester) async {
      await _pump(tester, const DistanceCompass(distance: '1,2 km', line: 'x', bearing: 0, trend: 'mai departe', closer: false));
      expect(tester.widget<Text>(find.text('mai departe')).style?.color, _app.danger);
      await _pump(tester, const DistanceCompass(distance: '1,2 km', line: 'x', bearing: 0));
      expect(find.text('mai aproape'), findsNothing);
    });
  });

  group('PhotoStatusBanner', () {
    for (final (kind, fill, text, icon) in [
      (PhotoBannerKind.waiting, _app.warningSoft, _app.warning, TablerIcons.clock),
      (PhotoBannerKind.approved, _app.successSoft, _app.success, TablerIcons.circle_check),
      (PhotoBannerKind.rejected, _app.dangerSoft, _app.danger, TablerIcons.circle_x),
    ]) {
      testWidgets('${kind.name}: its colours and icon', (tester) async {
        await _pump(tester, PhotoStatusBanner(kind: kind, text: 'Starea', trailing: 'acum 1 min'));
        expect(_box(tester, 'photo-status').color, fill);
        expect(tester.widget<Text>(find.text('Starea')).style?.color, text);
        expect(tester.widget<Icon>(find.byIcon(icon)).color, text);
        expect(find.text('acum 1 min'), findsOneWidget);
      });
    }
  });

  testWidgets('other events\' colours', (tester) async {
    await _pump(tester, GameFilledButton(label: 'Continuă', onTap: () {}), palette: _neon);
    expect(_box(tester, 'game-filled-button').color, _neon.accent);
  });

  testWidgets('all of them fit 320 px at 1.3x text', (tester) async {
    await _pump(
      tester,
      SingleChildScrollView(child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const DistanceCompass(distance: '1,2 km', line: 'spre nord-vest · ~16 min pe jos', bearing: 300, trend: 'mai departe', closer: false),
          const PhotoStatusBanner(kind: PhotoBannerKind.rejected, text: 'Respinsă: „Nu se vede ceasul turnului, nici echipa”', trailing: 'acum 12 min'),
          Row(children: [Expanded(child: GameFilledButton(label: 'Fă altă poză', icon: TablerIcons.camera, onTap: () {}))]),
        ],
      )),
      width: 320,
      textScale: 1.3,
    );
    expect(tester.takeException(), isNull);
  });
}
