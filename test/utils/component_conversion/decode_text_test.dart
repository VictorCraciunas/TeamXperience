import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/animation_type.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/utils/component_conversion/component_to_widget.dart';
import 'package:teamxperience/utils/component_conversion/decode_text.dart';
import 'package:teamxperience/utils/component_conversion/text_effects.dart';

import '../../ui/pump_ui.dart';

const _final = 'Serverul fizic a fost localizat. Mergi la punctul marcat.';

void main() {
  group('scrambling', () {
    test('the letters already settled stay as they are', () {
      final shown = scrambleText('Operațiunea', 4, 7);
      expect(shown.substring(0, 4), 'Oper');
    });

    test('the rest is replaced, one character for one', () {
      final shown = scrambleText('Operațiunea', 4, 7);
      expect(shown.length, 'Operațiunea'.length);
      expect(shown.substring(4), isNot('ațiunea'));
    });

    test('spaces, new lines and punctuation stay where they are', () {
      const text = 'ab cd\nef, gh. ij';
      final shown = scrambleText(text, 0, 3);
      for (var i = 0; i < text.length; i++) {
        if (' \n,.'.contains(text[i])) expect(shown[i], text[i], reason: 'index $i');
      }
    });

    test('the same moment gives the same letters, another moment other ones', () {
      expect(scrambleText(_final, 5, 11), scrambleText(_final, 5, 11));
      expect(scrambleText(_final, 5, 11), isNot(scrambleText(_final, 5, 12)));
    });

    test('everything settled is the text itself', () {
      expect(scrambleText(_final, _final.length, 3), _final);
      expect(scrambleText(_final, _final.length + 10, 3), _final);
    });

    test('nothing settled replaces every letter', () {
      final shown = scrambleText('abcdef', 0, 1);
      expect(shown.length, 6);
      expect(shown, isNot('abcdef'));
    });

    test('a negative count of settled letters counts as none', () {
      expect(scrambleText('abc', -5, 2).length, 3);
    });

    test('an empty text stays empty', () {
      expect(scrambleText('', 0, 1), '');
    });

    test('the replacements come from letters, digits and a few signs only', () {
      final shown = scrambleText('abcdefghijklmnopqrstuvwxyz' * 4, 0, 9);
      expect(RegExp(r'^[A-Za-z0-9#$%&*<>/{}\[\]=+\-_@!?]+$').hasMatch(shown), isTrue, reason: shown);
    });
  });

  group('the widget', () {
    Future<void> pump(WidgetTester tester, {String text = _final, int speed = 10, bool disableAnimations = false, TextEffects effects = const TextEffects()}) {
      return tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: disableAnimations),
            child: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 360,
                  child: DecodeText(
                    text: text,
                    textColor: Colors.green,
                    fontWeight: FontWeight.normal,
                    fontSize: 18,
                    msPerCharacter: speed,
                    textAlign: TextAlign.left,
                    effects: effects,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    /// What can be seen: the last text on screen (the first one only keeps the room).
    String shown(WidgetTester tester) => tester.widgetList<RichText>(find.byType(RichText)).last.text.toPlainText();

    testWidgets('starts as scrambled letters of the same length', (tester) async {
      await pump(tester);
      expect(shown(tester).length, _final.length);
      expect(shown(tester), isNot(_final));
    });

    testWidgets('settles on the text, from the left', (tester) async {
      await pump(tester, speed: 20);
      var lastSettled = -1;
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 60));
        final now = shown(tester);
        var settled = 0;
        while (settled < now.length && now[settled] == _final[settled]) {
          settled++;
        }
        expect(settled, greaterThanOrEqualTo(lastSettled), reason: 'step $i');
        lastSettled = settled;
      }
      expect(lastSettled, greaterThan(5));
    });

    testWidgets('ends with exactly the text', (tester) async {
      await pump(tester, speed: 10);
      await tester.pump(const Duration(milliseconds: _final.length * 10 + 800));
      expect(shown(tester), _final);
    });

    testWidgets('the room it takes does not change while it decodes', (tester) async {
      await pump(tester);
      final size = tester.getSize(find.byType(DecodeText));
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        expect(tester.getSize(find.byType(DecodeText)), size, reason: 'step $i');
      }
      await tester.pump(const Duration(seconds: 3));
      expect(tester.getSize(find.byType(DecodeText)), size);
    });

    testWidgets('capitals are used while decoding and at the end', (tester) async {
      await pump(tester, text: 'Operațiunea', effects: const TextEffects(uppercase: true));
      await tester.pump(const Duration(seconds: 2));
      expect(shown(tester), 'OPERAȚIUNEA');
    });

    testWidgets('letter spacing and the other effects are kept', (tester) async {
      await pump(tester, effects: const TextEffects(letterSpacing: 3, italic: true));
      final style = tester.widgetList<RichText>(find.byType(RichText)).last.text.style!;
      expect(style.letterSpacing, 3);
      expect(style.fontStyle, FontStyle.italic);
    });

    testWidgets('with animations switched off in the phone settings the text is shown at once', (tester) async {
      await pump(tester, disableAnimations: true);
      expect(shown(tester), _final);
    });

    testWidgets('a new text decodes again', (tester) async {
      await pump(tester, text: 'Primul');
      await tester.pump(const Duration(seconds: 2));
      expect(shown(tester), 'Primul');
      await pump(tester, text: 'Al doilea');
      expect(shown(tester), isNot('Al doilea'));
      await tester.pump(const Duration(seconds: 2));
      expect(shown(tester), 'Al doilea');
    });

    testWidgets('an empty text does not break', (tester) async {
      await pump(tester, text: '');
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('leaving the screen disposes it without trouble', (tester) async {
      await pump(tester);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });
  });

  group('as a text component', () {
    testWidgets('the animation "decode" uses it, with the speed of the typewriter', (tester) async {
      await pumpUi(
        tester,
        Column(
          children: [
            ComponentToWidget().convert(
              Component(type: ComponentType.text, text: 'Salut', animation: AnimationType.decode, typewriterSpeed: 30),
            ),
          ],
        ),
        width: 360,
      );
      expect(find.byType(DecodeText), findsOneWidget);
      expect(tester.widget<DecodeText>(find.byType(DecodeText)).msPerCharacter, 30);
    });

    testWidgets('without a speed it is as fast as the typewriter was', (tester) async {
      await pumpUi(
        tester,
        Column(children: [ComponentToWidget().convert(Component(type: ComponentType.text, text: 'Salut', animation: AnimationType.decode))]),
        width: 360,
      );
      expect(tester.widget<DecodeText>(find.byType(DecodeText)).msPerCharacter, 100);
    });

    testWidgets('the other animations do not use it', (tester) async {
      for (final animation in [AnimationType.none, AnimationType.typewriter, null]) {
        await pumpUi(
          tester,
          Column(children: [ComponentToWidget().convert(Component(type: ComponentType.text, text: 'Salut', animation: animation))]),
          width: 360,
        );
        expect(find.byType(DecodeText), findsNothing, reason: '$animation');
      }
    });

    testWidgets('an empty text with decode is just empty', (tester) async {
      await pumpUi(
        tester,
        Column(children: [ComponentToWidget().convert(Component(type: ComponentType.text, text: '', animation: AnimationType.decode))]),
        width: 360,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
