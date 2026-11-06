import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/event_game/widgets/route_header.dart';
import 'package:teamxperience/ui/theme/app_colors.dart';
import 'package:teamxperience/ui/theme/event_palette.dart';
import 'package:teamxperience/ui/theme/event_palette_resolver.dart';
import 'package:teamxperience/ui/theme/event_theme_scope.dart';

import '../../ui/pump_ui.dart';

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
  String? place = 'Vulpile · locul 2 din 12',
  EventPalette palette = EventPalette.parchment,
  double width = 316,
  double textScale = 1,
}) async {
  final calls = <String>[];
  await pumpUi(
    tester,
    EventThemeScope(
      palette: palette,
      child: RouteHeader(
        eventName: 'Moștenirea Cartografului',
        placeLine: place,
        played: '0:42:18',
        left: '1:17:42',
        onClose: () => calls.add('close'),
        onChat: () => calls.add('chat'),
      ),
    ),
    width: width,
    textScale: textScale,
  );
  return calls;
}

void main() {
  testWidgets('the mockup\'s name, place and two clocks', (tester) async {
    await _pump(tester);
    expect(find.text('Moștenirea Cartografului'), findsOneWidget);
    expect(find.text('Vulpile · locul 2 din 12'), findsOneWidget);
    expect(find.text('0:42:18 jucat', findRichText: true), findsOneWidget);
    expect(find.text('1:17:42 rămas', findRichText: true), findsOneWidget);
    expect(find.byIcon(TablerIcons.clock), findsOneWidget);
    expect(find.byIcon(TablerIcons.hourglass), findsOneWidget);
    final name = tester.widget<Text>(find.text('Moștenirea Cartografului')).style;
    expect((name?.fontFamily, name?.fontSize), (EventPalette.parchment.voiceFont, 15));
  });

  testWidgets('no place line before the ranking arrives', (tester) async {
    await _pump(tester, place: null);
    expect(find.textContaining('locul'), findsNothing);
    expect(find.text('Moștenirea Cartografului'), findsOneWidget);
  });

  testWidgets('close and chat call back', (tester) async {
    final calls = await _pump(tester);
    await tester.tap(find.byIcon(TablerIcons.x));
    await tester.tap(find.byIcon(TablerIcons.message_circle));
    expect(calls, ['close', 'chat']);
    expect(find.bySemanticsLabel('Închide'), findsOneWidget);
    expect(find.bySemanticsLabel('Chat cu organizatorul'), findsOneWidget);
  });

  testWidgets('another event\'s colours', (tester) async {
    await _pump(tester, palette: _neon);
    final name = tester.widget<Text>(find.text('Moștenirea Cartografului')).style;
    expect(name?.color, _neon.ink);
    expect(tester.widget<Icon>(find.byIcon(TablerIcons.clock)).color, _neon.ink);
  });

  testWidgets('fits 320 px at 1.3x text', (tester) async {
    await _pump(tester, width: 320, textScale: 1.3);
    expect(tester.takeException(), isNull);
  });
}
