import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/features/event_game/logic/style_hints.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/event_defaults.dart';
import 'package:teamxperience/model/mission.dart';
import 'package:teamxperience/model/puzzle.dart';
import 'package:teamxperience/ui/theme/app_colors.dart';
import 'package:teamxperience/ui/theme/event_palette.dart';

Component _button(String? color) => Component(type: ComponentType.button, buttonColor: color);
Component _text(String? color, {String? font}) => Component(type: ComponentType.text, textColor: color, fontFamily: font);
Component _code({String? border, String? fill, String? frame, String? glow}) => Component(
      type: ComponentType.code,
      colorBorderInput: border,
      inputBackgroundColor: fill,
      frameBackgroundColor: frame,
      glowColor: glow,
      enableGlow: glow != null,
    );

void main() {
  group('styleHintsFrom', () {
    test('nothing set: no hints', () {
      final hints = styleHintsFrom([Component(type: ComponentType.text)], null);
      expect(hints.accent, isNull);
      expect(hints.ink, isNull);
      expect(hints.font, isNull);
      expect(hints.surface, isNull);
      expect(hints.background, isNull);
      expect(hints.glow, isNull);
    });

    test('the most common button colour is the accent', () {
      final hints = styleHintsFrom([_button('#000000'), _button('#8A3B12'), _button('8a3b12')], null);
      expect(hints.accent, const Color(0xFF8A3B12));
    });

    test('colours the editor wrote as #aarrggbb count too, fully transparent ones do not', () {
      final hints = styleHintsFrom([_button('#ff8a3b12'), _button('#ff8a3b12'), _button('#00000000')], null);
      expect(hints.accent, const Color(0xFF8A3B12));
      expect(styleHintsFrom([_button('#00123456')], null).accent, isNull);
    });

    test('a tie goes to the first seen', () {
      expect(styleHintsFrom([_button('#111111'), _button('#222222')], null).accent, const Color(0xFF111111));
    });

    test('blank and unreadable colours are ignored', () {
      final hints = styleHintsFrom([_button(''), _button('red'), _button('  '), _button('#8A3B12')], null);
      expect(hints.accent, const Color(0xFF8A3B12));
    });

    test('without buttons, the code field border; without either, the defaults', () {
      expect(styleHintsFrom([_code(border: '#33FF66')], null).accent, const Color(0xFF33FF66));
      expect(
        styleHintsFrom([_text(null)], const EventDefaults(accentColor: '#123456')).accent,
        const Color(0xFF123456),
      );
    });

    test('the puzzles win over the defaults', () {
      final hints = styleHintsFrom([_button('#8A3B12')], const EventDefaults(accentColor: '#123456'));
      expect(hints.accent, const Color(0xFF8A3B12));
    });

    test('text colour and font come from the text pieces, else the defaults', () {
      final hints = styleHintsFrom(
        [_text('#3B2A1A', font: 'Gelasio'), _text('#3B2A1A', font: 'Gelasio'), _text('#FFFFFF', font: 'Poppins')],
        null,
      );
      expect(hints.ink, const Color(0xFF3B2A1A));
      expect(hints.font, 'Gelasio');
      final fallback = styleHintsFrom([], const EventDefaults(textColor: '#222222', fontFamily: 'Monospace'));
      expect(fallback.ink, const Color(0xFF222222));
      expect(fallback.font, 'Monospace');
    });

    test('a button\'s text colour is not the ink', () {
      final hints = styleHintsFrom([Component(type: ComponentType.button, textColor: '#FFFFFF')], null);
      expect(hints.ink, isNull);
    });

    test('the surface is the code field fill, else its frame', () {
      expect(styleHintsFrom([_code(fill: '#FBF4E4', frame: '#000000')], null).surface, const Color(0xFFFBF4E4));
      expect(styleHintsFrom([_code(frame: '#EADBC0')], null).surface, const Color(0xFFEADBC0));
    });

    test('the page is the defaults\' background, else the code frame', () {
      expect(
        styleHintsFrom([_code(frame: '#000000')], const EventDefaults(backgroundColor: '#EADBC0')).background,
        const Color(0xFFEADBC0),
      );
      expect(styleHintsFrom([_code(frame: '#0A0F0A')], null).background, const Color(0xFF0A0F0A));
    });

    test('the second accent is the most common glow that is switched on', () {
      Component glowing(String colour, bool? on) => Component(type: ComponentType.code, glowColor: colour, enableGlow: on);
      expect(styleHintsFrom([glowing('#B8862B', true)], null).glow, const Color(0xFFB8862B));
      expect(
        styleHintsFrom([glowing('#000000', false), glowing('#000000', null), glowing('#B8862B', true)], null).glow,
        const Color(0xFFB8862B),
      );
      expect(styleHintsFrom([glowing('#000000', false)], null).glow, isNull);
    });
  });

  group('eventPaletteOf', () {
    Event event({String? background}) => Event(
          eventId: 'e1',
          taskBackgroundImageUrl: background,
          missions: [
            Mission(id: '0', puzzles: [
              Puzzle(id: '0', components: [_text('#3B2A1A', font: 'Gelasio')]),
            ]),
            Mission(id: '1', puzzles: [
              Puzzle(id: '0', components: [_button('#8A3B12'), _code(fill: '#FBF4E4', glow: '#B8862B')]),
            ]),
          ],
          defaults: const EventDefaults(backgroundColor: '#EADBC0'),
        );

    test('walks every mission and puzzle', () {
      final palette = eventPaletteOf(event(), AppColors.light);
      const p = EventPalette.parchment;
      expect(palette.background, p.background);
      expect(palette.surface, p.surface);
      expect(palette.ink, p.ink);
      expect(palette.accent, p.accent);
      expect(palette.secondaryAccent, p.secondaryAccent);
      expect(palette.voiceFont, 'Gelasio');
    });

    test('an event with no puzzles and no picture looks exactly like the app', () {
      final palette = eventPaletteOf(Event(eventId: 'e1'), AppColors.dark);
      expect(palette, EventPalette.fromApp(AppColors.dark));
      expect(palette.backgroundImage, isNull);
      expect(eventPaletteOf(Event(eventId: 'e1', taskBackgroundImageUrl: '  '), AppColors.dark).backgroundImage, isNull);
    });

    test('the puzzles\' background image comes along', () {
      expect(
        eventPaletteOf(event(background: 'https://example.com/bg.jpg'), AppColors.light).backgroundImage,
        const NetworkImage('https://example.com/bg.jpg'),
      );
      expect(
        eventPaletteOf(event(background: 'assets/images/harta.png'), AppColors.light).backgroundImage,
        const AssetImage('assets/images/harta.png'),
      );
    });
  });
}
