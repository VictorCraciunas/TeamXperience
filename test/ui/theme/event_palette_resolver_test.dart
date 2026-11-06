import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/theme/app_colors.dart';
import 'package:teamxperience/ui/theme/event_palette.dart';
import 'package:teamxperience/ui/theme/event_palette_resolver.dart';

const _nearBlack = Color(0xFF1A1410);
const _nearWhite = Color(0xFFF7F2E8);

void main() {
  group('contrastRatio', () {
    test('black on white is 21, a colour on itself is 1', () {
      expect(contrastRatio(const Color(0xFF000000), const Color(0xFFFFFFFF)), closeTo(21, 0.01));
      expect(contrastRatio(const Color(0xFF8A3B12), const Color(0xFF8A3B12)), closeTo(1, 0.001));
    });

    test('the order does not matter', () {
      const a = Color(0xFF3B2A1A);
      const b = Color(0xFFEADBC0);
      expect(contrastRatio(a, b), contrastRatio(b, a));
    });
  });

  group('resolveEventPalette', () {
    for (final app in [AppColors.light, AppColors.dark]) {
      test('no hints: the app\'s own palette (${app == AppColors.light ? 'light' : 'dark'})', () {
        final palette = resolveEventPalette(hints: const StyleHints(), app: app);
        expect(palette, EventPalette.fromApp(app));
      });
    }

    test('the hints become the palette', () {
      final palette = resolveEventPalette(
        hints: const StyleHints(
          background: Color(0xFF0A0F0A),
          surface: Color(0xFF111A11),
          ink: Color(0xFF33FF66),
          accent: Color(0xFF33FF66),
          glow: Color(0xFF00CC44),
          font: 'Monospace',
        ),
        app: AppColors.light,
      );
      expect(palette.background, const Color(0xFF0A0F0A));
      expect(palette.surface, const Color(0xFF111A11));
      expect(palette.ink, const Color(0xFF33FF66));
      expect(palette.accent, const Color(0xFF33FF66));
      expect(palette.secondaryAccent, const Color(0xFF00CC44));
      expect(palette.voiceFont, 'Monospace');
    });

    test('muted, faint and border are the ink, quieter', () {
      const ink = Color(0xFF3B2A1A);
      final palette = resolveEventPalette(
        hints: const StyleHints(ink: ink, background: Color(0xFFEADBC0)),
        app: AppColors.light,
      );
      expect(palette.muted, ink.withValues(alpha: .75));
      expect(palette.faint, ink.withValues(alpha: .55));
      expect(palette.border, ink.withValues(alpha: .25));
    });

    test('without a glow, the second accent is the accent, softer', () {
      const accent = Color(0xFF8A3B12);
      final palette = resolveEventPalette(hints: const StyleHints(accent: accent), app: AppColors.light);
      expect(palette.secondaryAccent, accent.withValues(alpha: .55));
    });

    test('black text on a black page becomes readable', () {
      final palette = resolveEventPalette(
        hints: const StyleHints(ink: Color(0xFF000000), background: Color(0xFF000000), surface: Color(0xFF101010)),
        app: AppColors.light,
      );
      expect(palette.ink, _nearWhite);
    });

    test('pale text on a pale page becomes near-black', () {
      final palette = resolveEventPalette(
        hints: const StyleHints(ink: Color(0xFFEEEEEE), background: Color(0xFFFFFFFF)),
        app: AppColors.light,
      );
      expect(palette.ink, _nearBlack);
    });

    test('dark text that reads on the page but not on a dark surface is guarded too', () {
      final palette = resolveEventPalette(
        hints: const StyleHints(ink: Color(0xFF222222), background: Color(0xFFFFFFFF), surface: Color(0xFF111111)),
        app: AppColors.light,
      );
      expect(palette.ink, isNot(const Color(0xFF222222)));
    });

    test('text on accent fills is dark on a light accent and light on a dark one', () {
      final light = resolveEventPalette(
        hints: const StyleHints(accent: Color(0xFFF5D76E), surface: Color(0xFF222222)),
        app: AppColors.light,
      );
      final dark = resolveEventPalette(hints: const StyleHints(accent: Color(0xFF8A3B12)), app: AppColors.light);
      expect(light.onAccent, _nearBlack);
      expect(dark.onAccent, _nearWhite);
    });

    test('an accent that vanishes on the surface falls back to the app accent', () {
      final palette = resolveEventPalette(
        hints: const StyleHints(accent: Color(0xFFFBF4E4), surface: Color(0xFFFBF4E4)),
        app: AppColors.light,
      );
      expect(palette.accent, AppColors.light.accent);
    });

    test('the mockup\'s parchment colours come through unchanged', () {
      final palette = resolveEventPalette(
        hints: const StyleHints(
          background: Color(0xFFEADBC0),
          surface: Color(0xFFFBF4E4),
          ink: Color(0xFF3B2A1A),
          accent: Color(0xFF8A3B12),
          glow: Color(0xFFB8862B),
          font: 'Gelasio',
        ),
        app: AppColors.light,
      );
      const p = EventPalette.parchment;
      expect(palette.background, p.background);
      expect(palette.surface, p.surface);
      expect(palette.ink, p.ink);
      expect(palette.accent, p.accent);
      expect(palette.secondaryAccent, p.secondaryAccent);
      expect(palette.voiceFont, p.voiceFont);
    });

    test('the background image is carried', () {
      const image = AssetImage('assets/images/default_background.png');
      final palette = resolveEventPalette(hints: const StyleHints(), app: AppColors.light, backgroundImage: image);
      expect(palette.backgroundImage, image);
      expect(palette, isNot(EventPalette.fromApp(AppColors.light)));
    });
  });
}
