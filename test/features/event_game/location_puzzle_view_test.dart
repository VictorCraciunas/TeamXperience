import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/event_game/logic/location_texts.dart';
import 'package:teamxperience/features/event_game/widgets/location_puzzle_view.dart';
import 'package:teamxperience/ui/components/game/distance_compass.dart';
import 'package:teamxperience/ui/components/game/game_filled_button.dart';
import 'package:teamxperience/ui/theme/app_colors.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';
import 'package:teamxperience/ui/theme/event_palette.dart';
import 'package:teamxperience/ui/theme/event_palette_resolver.dart';
import 'package:teamxperience/ui/theme/event_theme_scope.dart';

final _neon = resolveEventPalette(
  hints: const StyleHints(
    background: Color(0xFF0A0F0A),
    surface: Color(0xFF111A11),
    ink: Color(0xFFB8FFC8),
    accent: Color(0xFF33FF66),
  ),
  app: AppColors.light,
);

Future<List<String>> _pump(
  WidgetTester tester, {
  LocationViewState state = LocationViewState.tracking,
  double? meters = 140,
  double? bearing = 40,
  DistanceTrend? trend = DistanceTrend.closer,
  bool inside = false,
  bool hint = true,
  EventPalette palette = EventPalette.parchment,
  double width = 316,
  double textScale = 1,
}) async {
  final calls = <String>[];
  tester.view.physicalSize = Size(width * 2, 640 * 2);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.light,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
      child: child ?? const SizedBox.shrink(),
    ),
    home: Scaffold(
      body: EventThemeScope(
        palette: palette,
        child: LocationPuzzleView(
          state: state,
          map: const SizedBox.expand(key: ValueKey('map')),
          meters: meters,
          bearing: bearing,
          trend: trend,
          inside: inside,
          onEnter: () => calls.add('enter'),
          onHint: hint ? () => calls.add('hint') : null,
          onOpenSettings: () => calls.add('settings'),
        ),
      ),
    ),
  ));
  return calls;
}

GameFilledButton _enter(WidgetTester tester) =>
    tester.widget<GameFilledButton>(find.widgetWithText(GameFilledButton, 'Intră în cerc'));

void main() {
  testWidgets('tracking: the map, how far and which way, closer; not inside yet', (tester) async {
    final calls = await _pump(tester);
    expect(find.byKey(const ValueKey('map')), findsOneWidget);
    expect(tester.getSize(find.byKey(const ValueKey('location-map-card'))).height, 210);
    expect(find.text('140 m'), findsOneWidget);
    expect(find.text('spre nord-est · ~2 min pe jos'), findsOneWidget);
    expect(find.text('mai aproape'), findsOneWidget);
    expect(_enter(tester).onTap, isNull);
    await tester.tap(find.text('Indiciu'));
    expect(calls, ['hint']);
  });

  testWidgets('inside: "Ești în cerc", and "Intră în cerc" goes on', (tester) async {
    final calls = await _pump(tester, inside: true, meters: 12);
    expect(find.text('Ești în cerc'), findsOneWidget);
    expect(find.byType(DistanceCompass), findsNothing);
    await tester.tap(find.text('Intră în cerc'));
    expect(calls, ['enter']);
  });

  testWidgets('location refused: the ask, settings, no map, no way in', (tester) async {
    final calls = await _pump(tester, state: LocationViewState.denied, meters: null, bearing: null);
    expect(find.text('Permite accesul la locație ca să vedeți cât de aproape sunteți.'), findsOneWidget);
    expect(find.byKey(const ValueKey('map')), findsNothing);
    expect(_enter(tester).onTap, isNull);
    await tester.tap(find.text('Deschide setările'));
    expect(calls, ['settings']);
  });

  testWidgets('no place set: the team is told and may go on', (tester) async {
    final calls = await _pump(tester, state: LocationViewState.noTarget, meters: null, bearing: null);
    expect(find.text('Organizatorul n-a pus locul pe hartă. Puteți merge mai departe.'), findsOneWidget);
    await tester.tap(find.text('Intră în cerc'));
    expect(calls, ['enter']);
  });

  testWidgets('waiting for the first fix: the map, no compass, no way in', (tester) async {
    await _pump(tester, state: LocationViewState.waiting, meters: null, bearing: null);
    expect(find.byKey(const ValueKey('map')), findsOneWidget);
    expect(find.byType(DistanceCompass), findsNothing);
    expect(_enter(tester).onTap, isNull);
  });

  testWidgets('a solved mission: just "Continuă"', (tester) async {
    final calls = await _pump(tester, state: LocationViewState.done, meters: null, bearing: null);
    await tester.tap(find.text('Continuă'));
    expect(calls, ['enter']);
  });

  testWidgets('no hint: "Indiciu" greyed', (tester) async {
    await _pump(tester, hint: false);
    final opacity = tester.widget<Opacity>(find.ancestor(of: find.text('Indiciu'), matching: find.byType(Opacity)));
    expect(opacity.opacity, .5);
  });

  testWidgets('another event\'s colours', (tester) async {
    await _pump(tester, palette: _neon, inside: true);
    final box = tester.widget<DecoratedBox>(find.byKey(const ValueKey('game-filled-button'))).decoration as BoxDecoration;
    expect(box.color, _neon.accent);
  });

  testWidgets('fits 320 px at 1.3x text, in every state', (tester) async {
    for (final state in LocationViewState.values) {
      await _pump(tester, state: state, width: 320, textScale: 1.3);
      expect(tester.takeException(), isNull, reason: state.name);
    }
  });
}
