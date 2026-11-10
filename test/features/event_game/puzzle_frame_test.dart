import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/event_game/widgets/hint_sheet.dart';
import 'package:teamxperience/features/event_game/widgets/puzzle_bottom_bar.dart';
import 'package:teamxperience/features/event_game/widgets/puzzle_feedback.dart';
import 'package:teamxperience/features/event_game/widgets/puzzle_header.dart';
import 'package:teamxperience/ui/components/game/attempt_dots.dart';
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

Future<void> _pump(WidgetTester tester, Widget child,
    {EventPalette palette = EventPalette.parchment, double width = 316, double textScale = 1}) {
  return pumpUi(tester, EventThemeScope(palette: palette, child: child), width: width, textScale: textScale);
}

void main() {
  group('PuzzleHeader', () {
    testWidgets('the mission, its title and the clock', (tester) async {
      var back = 0;
      await _pump(
        tester,
        PuzzleHeader(mission: 4, missions: 6, title: 'Casa cu ochi', clock: '0:42:18', onBack: () => back++),
      );
      expect(find.text('Misiunea 4 din 6'), findsOneWidget);
      expect(find.text('Casa cu ochi'), findsOneWidget);
      expect(find.text('0:42:18'), findsOneWidget);
      final title = tester.widget<Text>(find.text('Casa cu ochi')).style;
      expect((title?.fontFamily, title?.fontSize), (EventPalette.parchment.voiceFont, 17));
      final clock = tester.widget<Text>(find.text('0:42:18')).style;
      expect((clock?.fontFamily, clock?.fontWeight), ('Monospace', FontWeight.w500));
      await tester.tap(find.byIcon(TablerIcons.arrow_left));
      expect(back, 1);
    });

    testWidgets('neon colours', (tester) async {
      await _pump(
        tester,
        PuzzleHeader(mission: 1, missions: 2, title: 'X', clock: '0:00:01', onBack: () {}),
        palette: _neon,
      );
      expect(tester.widget<Text>(find.text('X')).style?.color, _neon.ink);
    });
  });

  group('PuzzleFeedback', () {
    testWidgets('the organiser\'s wrong line in the danger colour, then the attempts', (tester) async {
      await _pump(
        tester,
        const PuzzleFeedback(wrong: 'Nu e anul ăsta. Uită-te mai sus pe ușă.', maxAttempts: 3, attemptsLeft: 2),
      );
      final line = tester.widget<Text>(find.text('Nu e anul ăsta. Uită-te mai sus pe ușă.')).style;
      expect((line?.color, line?.fontWeight, line?.fontSize), (EventPalette.parchment.danger, FontWeight.w500, 14));
      expect(find.byIcon(TablerIcons.alert_circle), findsOneWidget);
      expect(find.text('2 încercări rămase'), findsOneWidget);
    });

    testWidgets('no limit: no dots', (tester) async {
      await _pump(tester, const PuzzleFeedback(wrong: 'Nu e corect. Mai încearcă.'));
      expect(find.byType(AttemptDots), findsNothing);
      expect(find.text('Nu e corect. Mai încearcă.'), findsOneWidget);
    });

    testWidgets('nothing to say: nothing drawn', (tester) async {
      await _pump(tester, const PuzzleFeedback());
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('during a lock: the countdown instead of the line and the dots', (tester) async {
      await _pump(
        tester,
        const PuzzleFeedback(
          wrong: 'Nu e corect. Mai încearcă.',
          maxAttempts: 3,
          attemptsLeft: 3,
          lockLeft: Duration(seconds: 45),
        ),
      );
      expect(find.text('Mai încercați în 0:45'), findsOneWidget);
      expect(find.text('Nu e corect. Mai încearcă.'), findsNothing);
      expect(find.byType(AttemptDots), findsNothing);
      expect(tester.widget<Text>(find.text('Mai încercați în 0:45')).style?.color, EventPalette.parchment.muted);
    });
  });

  group('PuzzleBottomBar', () {
    testWidgets('"Indiciu" and chat call back', (tester) async {
      final calls = <String>[];
      await _pump(tester, PuzzleBottomBar(onHint: () => calls.add('hint'), onChat: () => calls.add('chat')));
      await tester.tap(find.text('Indiciu'));
      await tester.tap(find.byIcon(TablerIcons.message_circle));
      expect(calls, ['hint', 'chat']);
    });

    testWidgets('no hint left: greyed', (tester) async {
      await _pump(tester, PuzzleBottomBar(onHint: null, onChat: () {}));
      final opacity = tester.widget<Opacity>(find.ancestor(of: find.text('Indiciu'), matching: find.byType(Opacity)));
      expect(opacity.opacity, .5);
    });
  });

  group('HintSheet', () {
    testWidgets('shows the hint in the event\'s colours, even outside its scope', (tester) async {
      await pumpUi(
        tester,
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showHintSheet(context, hint: 'Uită-te în sus.', palette: _neon),
            child: const Text('deschide'),
          ),
        ),
      );
      await tester.tap(find.text('deschide'));
      await tester.pumpAndSettle();
      expect(find.text('Indiciu'), findsOneWidget);
      expect(find.text('Uită-te în sus.'), findsOneWidget);
      expect(tester.widget<Text>(find.text('Uită-te în sus.')).style?.color, _neon.ink);
    });
  });

  testWidgets('everything fits 320 px at 1.3x text', (tester) async {
    await _pump(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PuzzleHeader(mission: 12, missions: 12, title: 'Unde dorm clopotele de la biserica mare', clock: '2:59:59', onBack: () {}),
          const PuzzleFeedback(wrong: 'Nu e anul ăsta. Uită-te mai sus pe ușă, lângă fereastra a doua.', maxAttempts: 5, attemptsLeft: 1),
          PuzzleBottomBar(onHint: () {}, onChat: () {}),
        ],
      ),
      width: 320,
      textScale: 1.3,
    );
    expect(tester.takeException(), isNull);
  });
}
