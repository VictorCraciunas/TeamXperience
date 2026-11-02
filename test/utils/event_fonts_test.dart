import 'dart:io';
import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/utils/event_fonts.dart';

void main() {
  group('the list of fonts', () {
    test('starts with the two the app always had', () {
      expect(eventFonts.take(2).map((f) => f.family), ['Poppins', 'Monospace']);
    });

    test('has the ten fonts of the gallery', () {
      expect(eventFonts.map((f) => f.family), [
        'Poppins',
        'Monospace',
        'Orbitron',
        'Share Tech Mono',
        'Press Start 2P',
        'Cinzel',
        'Special Elite',
        'Caveat',
        'Bebas Neue',
        'Playfair Display',
      ]);
    });

    test('has no font twice', () {
      expect(eventFonts.map((f) => f.family).toSet(), hasLength(eventFonts.length));
    });

    test('names are the families, for the importer and the skill', () {
      expect(eventFontNames, eventFonts.map((f) => f.family).toList());
    });

    test('knows which names are fonts of the app', () {
      expect(isEventFont('Orbitron'), isTrue);
      expect(isEventFont('Arial'), isFalse);
      expect(isEventFont(null), isFalse);
    });
  });

  group('weight of a variable font', () {
    test('four fonts are variable, the others are not', () {
      final variable = eventFonts.where((f) => f.variable).map((f) => f.family).toSet();
      expect(variable, {'Orbitron', 'Cinzel', 'Caveat', 'Playfair Display'});
    });

    test('a variable font gets its weight as a variation', () {
      final variations = fontVariationsFor('Orbitron', FontWeight.w700);
      expect(variations, hasLength(1));
      expect(variations!.single.axis, 'wght');
      expect(variations.single.value, 700);
    });

    test('every weight the app offers is handled', () {
      for (final weight in [FontWeight.w300, FontWeight.w400, FontWeight.w500, FontWeight.w700, FontWeight.w900]) {
        expect(fontVariationsFor('Cinzel', weight), isNotNull, reason: '$weight');
      }
    });

    test('a weight below what the font has is raised to the lightest it has', () {
      expect(fontVariationsFor('Orbitron', FontWeight.w100)!.single.value, 400);
      expect(fontVariationsFor('Cinzel', FontWeight.w300)!.single.value, 400);
    });

    test('a weight above what the font has is lowered to the heaviest it has', () {
      expect(fontVariationsFor('Caveat', FontWeight.w900)!.single.value, 700);
      expect(fontVariationsFor('Cinzel', FontWeight.w900)!.single.value, 900);
    });

    test('a font with one weight, or none of ours, gets no variation', () {
      expect(fontVariationsFor('Press Start 2P', FontWeight.w700), isNull);
      expect(fontVariationsFor('Poppins', FontWeight.w700), isNull);
      expect(fontVariationsFor('Monospace', FontWeight.w400), isNull);
      expect(fontVariationsFor(null, FontWeight.w700), isNull);
      expect(fontVariationsFor('Arial', FontWeight.w700), isNull);
    });
  });

  group('the files', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();

    test('every font has its file', () {
      for (final font in eventFonts) {
        for (final file in font.files) {
          expect(File(file).existsSync(), isTrue, reason: '${font.family}: $file');
        }
      }
    });

    test('every font is declared in pubspec.yaml with the name the app uses', () {
      for (final font in eventFonts) {
        expect(pubspec, contains('family: ${font.family}'), reason: font.family);
      }
    });

    test('every file of a font is declared in pubspec.yaml', () {
      for (final font in eventFonts) {
        for (final file in font.files) {
          expect(pubspec, contains('asset: $file'), reason: file);
        }
      }
    });

    test('every font file named in pubspec.yaml exists', () {
      final declared = RegExp(r'asset:\s*(assets/fonts/\S+\.ttf)').allMatches(pubspec).map((m) => m.group(1)!).toSet();
      expect(declared, isNotEmpty);
      for (final file in declared) {
        expect(File(file).existsSync(), isTrue, reason: file);
      }
    });

    test('a variable font is declared for each weight the app offers', () {
      for (final font in eventFonts.where((f) => f.variable)) {
        final file = font.files.single;
        final start = pubspec.indexOf('family: ${font.family}');
        final end = pubspec.indexOf('- family:', start + 1);
        final block = pubspec.substring(start, end < 0 ? pubspec.length : end);
        final entries = RegExp(RegExp.escape('asset: $file')).allMatches(block).length;
        expect(entries, 6, reason: '${font.family}: weights 100, 300, 400, 500, 700 and 900');
      }
    });

    test('every new font has its licence next to it', () {
      final licences = Directory('assets/fonts/licenses').listSync().map((f) => f.path.replaceAll('\\', '/').split('/').last).toList();
      for (final font in eventFonts.where((f) => f.licence != null)) {
        expect(licences, contains(font.licence), reason: font.family);
      }
    });
  });
}
