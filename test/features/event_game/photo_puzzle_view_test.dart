import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/event_game/logic/photo_state.dart';
import 'package:teamxperience/features/event_game/widgets/image_upload/photo_puzzle_view.dart';
import 'package:teamxperience/ui/components/game/game_filled_button.dart';
import 'package:teamxperience/ui/theme/app_colors.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';
import 'package:teamxperience/ui/theme/event_palette.dart';
import 'package:teamxperience/ui/theme/event_palette_resolver.dart';
import 'package:teamxperience/ui/theme/event_theme_scope.dart';

final _now = DateTime(2026, 11, 14, 10, 30);

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
  WidgetTester tester,
  PhotoStep step, {
  String? reason,
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
        child: PhotoPuzzleView(
          step: step,
          reason: reason,
          sentAt: _now.subtract(const Duration(minutes: 1)),
          now: _now,
          onTakePhoto: () => calls.add('photo'),
          onContinue: () => calls.add('continue'),
          onChat: () => calls.add('chat'),
        ),
      ),
    ),
  ));
  return calls;
}

GameFilledButton _main(WidgetTester tester) => tester.widget<GameFilledButton>(find.byType(GameFilledButton));

void main() {
  testWidgets('waiting: who is looking, since when, the waiting line and "Refă"', (tester) async {
    final calls = await _pump(tester, PhotoStep.waiting);
    expect(find.text('Organizatorul se uită la poză'), findsOneWidget);
    expect(find.text('acum 1 min'), findsOneWidget);
    expect(find.text('Poza a ajuns și în chat. Mergeți mai departe după ce e aprobată.'), findsOneWidget);
    expect(find.text('Continuă'), findsNothing);
    expect(_main(tester).label, 'Fă altă poză');
    await tester.tap(find.text('Refă'));
    expect(calls, ['photo']);
  });

  testWidgets('approved: "Aprobată. Bravo!" and "Continuă"', (tester) async {
    final calls = await _pump(tester, PhotoStep.approved);
    expect(find.text('Aprobată. Bravo!'), findsOneWidget);
    expect(find.text('Refă'), findsNothing);
    await tester.tap(find.text('Continuă'));
    expect(calls, ['continue']);
  });

  testWidgets('rejected: the organiser\'s reason and another photo', (tester) async {
    final calls = await _pump(tester, PhotoStep.rejected, reason: 'Nu se vede ceasul');
    expect(find.text('Respinsă: „Nu se vede ceasul”'), findsOneWidget);
    expect(find.text('Refă'), findsOneWidget);
    await tester.tap(find.text('Fă altă poză'));
    expect(calls, ['photo']);
  });

  testWidgets('nothing sent: the camera prompt and "Fă poza"', (tester) async {
    final calls = await _pump(tester, PhotoStep.none);
    expect(find.byKey(const ValueKey('photo-prompt')), findsOneWidget);
    expect(find.text('Refă'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('photo-prompt')));
    await tester.tap(find.text('Fă poza'));
    expect(calls, ['photo', 'photo']);
  });

  testWidgets('while sending: the main button waits', (tester) async {
    await _pump(tester, PhotoStep.uploading);
    expect(_main(tester).label, 'Se trimite…');
    expect(_main(tester).onTap, isNull);
  });

  testWidgets('"Chat" calls back', (tester) async {
    final calls = await _pump(tester, PhotoStep.waiting);
    await tester.tap(find.text('Chat'));
    expect(calls, ['chat']);
  });

  testWidgets('another event\'s colours', (tester) async {
    await _pump(tester, PhotoStep.approved, palette: _neon);
    final card = tester.widget<DecoratedBox>(find.byKey(const ValueKey('photo-card'))).decoration as BoxDecoration;
    expect(card.color, _neon.surface);
  });

  testWidgets('fits 320 px at 1.3x text, in every step', (tester) async {
    for (final step in PhotoStep.values) {
      await _pump(tester, step, reason: 'Nu se vede ceasul turnului și nici toată echipa', width: 320, textScale: 1.3);
      expect(tester.takeException(), isNull, reason: step.name);
    }
  });
}
