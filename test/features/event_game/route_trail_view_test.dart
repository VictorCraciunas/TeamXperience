import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/event_game/logic/trail_layout.dart';
import 'package:teamxperience/features/event_game/widgets/route_trail_view.dart';
import 'package:teamxperience/ui/theme/app_colors.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';
import 'package:teamxperience/ui/theme/event_palette.dart';
import 'package:teamxperience/ui/theme/event_palette_resolver.dart';
import 'package:teamxperience/ui/theme/event_theme_scope.dart';

const _mockup = <TrailStop>[
  DoneStop(1, 'Scara Pasajului'),
  DoneStop(2, 'Podul Minciunilor'),
  DoneStop(3, 'Turnul Sfatului'),
  CurrentStop(4, 'Casa cu ochi', 'la 180 m de tine'),
  LockedStop('5 · 6'),
  FinishStop(),
];

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

Future<void> _pump(
  WidgetTester tester,
  List<TrailStop> stops, {
  VoidCallback? onContinue,
  EventPalette palette = EventPalette.parchment,
  double width = 304,
  double height = 430,
  double textScale = 1,
}) async {
  tester.view.physicalSize = Size(width * 2, (height + 100) * 2);
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
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: width,
            height: height,
            child: RouteTrailView(stops: stops, onContinue: onContinue ?? () {}),
          ),
        ),
      ),
    ),
  ));
}

Color? _fill(WidgetTester tester, Finder finder) =>
    (tester.widget<DecoratedBox>(finder).decoration as BoxDecoration).color;

void main() {
  testWidgets('the mockup\'s stops, with their labels', (tester) async {
    await _pump(tester, _mockup);
    expect(find.text('1 · Scara Pasajului'), findsOneWidget);
    expect(find.text('2 · Podul Minciunilor'), findsOneWidget);
    expect(find.text('3 · Turnul Sfatului'), findsOneWidget);
    expect(find.text('Misiunea 4 · acum'), findsOneWidget);
    expect(find.text('Casa cu ochi'), findsOneWidget);
    expect(find.text('la 180 m de tine'), findsOneWidget);
    expect(find.text('5 · 6'), findsOneWidget);
    expect(find.byIcon(TablerIcons.lock), findsOneWidget);
    expect(find.byIcon(TablerIcons.flag), findsOneWidget);
    expect(find.byIcon(TablerIcons.check), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('"Continuă" calls back', (tester) async {
    var taps = 0;
    await _pump(tester, _mockup, onContinue: () => taps++);
    await tester.tap(find.text('Continuă'));
    expect(taps, 1);
  });

  testWidgets('stops on the right have their label on the left', (tester) async {
    await _pump(tester, _mockup);
    final circle = tester.getRect(find.byKey(const ValueKey('trail-done-2')));
    final label = tester.getRect(find.text('2 · Podul Minciunilor'));
    expect(label.right, lessThanOrEqualTo(circle.left));
    final left = tester.getRect(find.byKey(const ValueKey('trail-done-1')));
    expect(tester.getRect(find.text('1 · Scara Pasajului')).left, greaterThanOrEqualTo(left.right));
  });

  testWidgets('everything done: no card, the flag at the top', (tester) async {
    await _pump(tester, const [
      DoneStop(1, 'A'),
      DoneStop(2, 'B'),
      DoneStop(3, 'C'),
      FinishStop(),
    ]);
    expect(find.text('Continuă'), findsNothing);
    expect(find.byKey(const ValueKey('trail-finish')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('twelve missions scroll: open on the last one, the first at the bottom of the trail', (tester) async {
    await _pump(tester, [
      for (var i = 1; i <= 11; i++) DoneStop(i, 'Misiunea $i'),
      const CurrentStop(12, 'Harta completă', null),
      const FinishStop(),
    ]);
    await tester.pump();
    expect(find.byType(Scrollable), findsOneWidget);
    final card = tester.getRect(find.byKey(const ValueKey('trail-card')));
    expect(card.top, greaterThanOrEqualTo(0));
    expect(card.bottom, lessThanOrEqualTo(430));
    await tester.drag(find.byType(Scrollable), const Offset(0, -3000));
    await tester.pump();
    final first = tester.getRect(find.byKey(const ValueKey('trail-done-1')));
    expect(first.bottom, lessThanOrEqualTo(430));
    expect(first.top, greaterThan(300));
    expect(tester.takeException(), isNull);
  });

  testWidgets('one mission: the card and the flag, no overflow', (tester) async {
    await _pump(tester, const [CurrentStop(1, 'Scara Pasajului', null), FinishStop()]);
    expect(find.text('Continuă'), findsOneWidget);
    expect(find.text('la 180 m de tine'), findsNothing);
    final card = tester.getRect(find.byKey(const ValueKey('trail-card')));
    expect(card.bottom, lessThanOrEqualTo(430), reason: 'the whole card, button included, is on screen');
    expect(tester.takeException(), isNull);
  });

  testWidgets('a long route opens on the current mission', (tester) async {
    await _pump(tester, [
      for (var i = 1; i <= 8; i++) DoneStop(i, 'Misiunea $i'),
      const CurrentStop(9, 'Unde dorm clopotele', null),
      const LockedStop('10–12'),
      const FinishStop(),
    ]);
    await tester.pump();
    final card = tester.getRect(find.byKey(const ValueKey('trail-card')));
    expect(card.top, greaterThanOrEqualTo(0));
    expect(card.bottom, lessThanOrEqualTo(430));
  });

  testWidgets('a card at the very top is not cut off', (tester) async {
    await _pump(tester, const [DoneStop(1, 'A'), DoneStop(2, 'B'), DoneStop(3, 'C'), CurrentStop(4, 'D', 'la 180 m de tine'), FinishStop()]);
    await tester.drag(find.byType(Scrollable), const Offset(0, 2000));
    await tester.pump();
    expect(tester.getRect(find.byKey(const ValueKey('trail-card'))).top, greaterThanOrEqualTo(0));
  });

  testWidgets('another event\'s colours', (tester) async {
    await _pump(tester, _mockup, palette: _neon);
    expect(_fill(tester, find.byKey(const ValueKey('trail-done-1'))), _neon.accent);
  });

  testWidgets('fits 320 px at 1.3x text', (tester) async {
    await _pump(tester, _mockup, width: 320, textScale: 1.3);
    expect(tester.takeException(), isNull);
  });
}
