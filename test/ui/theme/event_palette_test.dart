import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:teamxperience/utils/event_fonts.dart';

Future<EventPalette> _read(WidgetTester tester, ThemeData theme, {EventPalette? scope}) async {
  late EventPalette palette;
  final reader = Builder(builder: (context) {
    palette = context.eventPalette;
    return const SizedBox.shrink();
  });
  await tester.pumpWidget(MaterialApp(
    theme: theme,
    home: scope == null ? reader : EventThemeScope(palette: scope, child: reader),
  ));
  return palette;
}

void main() {
  _voiceFontIsAnAppFont();

  testWidgets('inside a scope the event palette is used', (tester) async {
    final p = await _read(tester, AppTheme.light, scope: EventPalette.parchment);
    expect(p.accent, const Color(0xFF8A3B12));
    expect(p.background, const Color(0xFFEADBC0));
  });

  testWidgets('without a scope the app colours are used (light)', (tester) async {
    final p = await _read(tester, AppTheme.light);
    expect(p.background, AppColors.light.page);
    expect(p.surface, AppColors.light.panel);
    expect(p.ink, AppColors.light.text);
    expect(p.accent, AppColors.light.accent);
  });

  testWidgets('without a scope the app colours are used (dark)', (tester) async {
    final p = await _read(tester, AppTheme.dark);
    expect(p.background, AppColors.dark.page);
    expect(p.accent, AppColors.dark.accent);
  });

  test('the scope notifies only when the palette changes', () {
    const child = SizedBox.shrink();
    const a = EventThemeScope(palette: EventPalette.parchment, child: child);
    const b = EventThemeScope(palette: EventPalette.parchment, child: child);
    final c = EventThemeScope(palette: EventPalette.fromApp(AppColors.light), child: child);
    expect(a.updateShouldNotify(b), isFalse);
    expect(a.updateShouldNotify(c), isTrue);
  });

  test('parchment uses the voice font', () {
    expect(EventPalette.parchment.voiceFont, AppFonts.voice);
    expect(AppFonts.voice, 'Gelasio');
  });
}

void _voiceFontIsAnAppFont() {
  test('the voice font is one of the app fonts', () {
    expect(isEventFont(AppFonts.voice), isTrue);
  });
}
