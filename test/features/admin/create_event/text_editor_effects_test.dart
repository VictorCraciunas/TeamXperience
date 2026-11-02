import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/animation_type.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/create_components/add_component_widget.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/create_components/create_text/create_text_controller.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/create_components/option_checkbox.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/model/puzzle.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

Future<void> _open(WidgetTester tester, Component component) {
  tester.view.physicalSize = const Size(800, 7000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: AddComponentWidget(puzzle: Puzzle(id: '0'), refreshUI: (_) {}, component: component, edit: true),
    ),
  );
}

Finder _sliderOf(String title) => find.descendant(
      of: find.ancestor(of: find.text(title), matching: find.byType(Column)).first,
      matching: find.byType(Slider),
    );

TextStyle? _previewStyle(WidgetTester tester, String text) {
  final widgets = tester.widgetList<Text>(find.byWidgetPredicate((w) => w is Text && w.data == text));
  return widgets.isEmpty ? null : widgets.first.style;
}

void main() {
  group('controller', () {
    test('starts with the usual look: nothing added', () {
      final c = TextComponentController();
      expect(c.letterSpacing, 0);
      expect(c.lineHeight, isNull);
      expect(c.italic, isFalse);
      expect(c.uppercase, isFalse);
      expect(c.enableGlow, isFalse);
      expect(c.shadowBlur, 0);
      expect(c.shadowDistance, 0);
    });

    test('loads what the text has', () {
      final c = TextComponentController()
        ..initializeFromComponent(
          Component(
            type: ComponentType.text,
            letterSpacing: 3,
            lineHeight: 1.5,
            italic: true,
            uppercase: true,
            enableGlow: true,
            glowColor: '#33FF66',
            shadowColor: '#112233',
            shadowBlur: 6,
            shadowDistance: 4,
          ),
        );
      expect(c.letterSpacing, 3);
      expect(c.lineHeight, 1.5);
      expect(c.italic, isTrue);
      expect(c.uppercase, isTrue);
      expect(c.enableGlow, isTrue);
      expect(c.glowColor, '#33FF66');
      expect(c.shadowColor, '#112233');
      expect(c.shadowBlur, 6);
      expect(c.shadowDistance, 4);
    });

    test('a text without them keeps the usual look', () {
      final c = TextComponentController()..initializeFromComponent(Component(type: ComponentType.text, text: 'x'));
      expect(c.letterSpacing, 0);
      expect(c.lineHeight, isNull);
      expect(c.enableGlow, isFalse);
    });

    test('writes only what was chosen, so a plain text stays plain', () {
      final c = TextComponentController()..animation = null;
      final component = Component();
      c.updateComponentFields(component);
      expect(component.letterSpacing, isNull);
      expect(component.lineHeight, isNull);
      expect(component.italic, isNull);
      expect(component.uppercase, isNull);
      expect(component.shadowBlur, isNull);
      expect(component.shadowDistance, isNull);
      expect(component.shadowColor, isNull);
    });

    test('writes what was chosen', () {
      final c = TextComponentController()
        ..letterSpacing = 2
        ..lineHeight = 1.4
        ..italic = true
        ..uppercase = true
        ..enableGlow = true
        ..glowColor = '#33FF66'
        ..shadowBlur = 5
        ..shadowDistance = 3
        ..shadowColor = '#000000';
      final component = Component();
      c.updateComponentFields(component);
      expect(component.letterSpacing, 2);
      expect(component.lineHeight, 1.4);
      expect(component.italic, isTrue);
      expect(component.uppercase, isTrue);
      expect(component.enableGlow, isTrue);
      expect(component.glowColor, '#33FF66');
      expect(component.shadowBlur, 5);
      expect(component.shadowDistance, 3);
      expect(component.shadowColor, '#000000');
    });

    test('the speed is written for the typewriter and for decode, not for no animation', () {
      for (final animation in [AnimationType.typewriter, AnimationType.decode]) {
        final component = Component();
        TextComponentController()
          ..animation = animation
          ..typewriterSpeed = 40
          ..updateComponentFields(component);
        expect(component.typewriterSpeed, 40, reason: animation.name);
      }
      final plain = Component();
      TextComponentController()
        ..animation = AnimationType.none
        ..typewriterSpeed = 40
        ..updateComponentFields(plain);
      expect(plain.typewriterSpeed, isNull);
    });

    test('options that were switched off are removed from a text that had them', () {
      final component = Component(type: ComponentType.text, italic: true, uppercase: true, shadowBlur: 5, shadowDistance: 5, lineHeight: 1.5, letterSpacing: 4);
      TextComponentController().updateComponentFields(component);
      expect(component.italic, isNull);
      expect(component.uppercase, isNull);
      expect(component.shadowBlur, isNull);
      expect(component.shadowDistance, isNull);
      expect(component.lineHeight, isNull);
      expect(component.letterSpacing, isNull);
    });
  });

  group('the text editor', () {
    testWidgets('has the new controls', (tester) async {
      await _open(tester, Component(type: ComponentType.text, text: 'Salut'));
      expect(_sliderOf('Spațiu între litere'), findsOneWidget);
      expect(_sliderOf('Înălțime rând'), findsOneWidget);
      expect(find.text('Cursiv'), findsOneWidget);
      expect(find.text('Majuscule'), findsOneWidget);
      expect(find.text('Glow text'), findsOneWidget);
      expect(_sliderOf('Încețoșare umbră'), findsOneWidget);
      expect(_sliderOf('Distanță umbră'), findsOneWidget);
    });

    testWidgets('the glow colour appears only when the glow is on', (tester) async {
      await _open(tester, Component(type: ComponentType.text, text: 'Salut'));
      expect(find.text('Culoare glow'), findsNothing);
      await tester.tap(find.widgetWithText(OptionCheckbox, 'Glow text'));
      await tester.pump();
      expect(find.text('Culoare glow'), findsOneWidget);
    });

    testWidgets('the shadow colour appears only when there is a shadow', (tester) async {
      await _open(tester, Component(type: ComponentType.text, text: 'Salut'));
      expect(find.text('Culoare umbră'), findsNothing);
      await tester.drag(_sliderOf('Distanță umbră'), const Offset(2000, 0));
      await tester.pump();
      expect(find.text('Culoare umbră'), findsOneWidget);
    });

    testWidgets('italic and capitals change the preview at once', (tester) async {
      await _open(tester, Component(type: ComponentType.text, text: 'Salut'));
      expect(_previewStyle(tester, 'Salut')?.fontStyle, anyOf(isNull, FontStyle.normal));

      await tester.tap(find.widgetWithText(OptionCheckbox, 'Cursiv'));
      await tester.tap(find.widgetWithText(OptionCheckbox, 'Majuscule'));
      await tester.pump();
      expect(_previewStyle(tester, 'SALUT')?.fontStyle, FontStyle.italic);
    });

    testWidgets('moving the letter spacing changes the preview', (tester) async {
      await _open(tester, Component(type: ComponentType.text, text: 'Salut'));
      await tester.drag(_sliderOf('Spațiu între litere'), const Offset(2000, 0));
      await tester.pump();
      expect(_previewStyle(tester, 'Salut')?.letterSpacing, 12);
    });

    testWidgets('the line height says automatic until it is moved', (tester) async {
      await _open(tester, Component(type: ComponentType.text, text: 'Salut'));
      expect(find.textContaining('(automat)'), findsOneWidget);
      await tester.drag(_sliderOf('Înălțime rând'), const Offset(2000, 0));
      await tester.pump();
      expect(find.textContaining('(automat)'), findsNothing);
      expect(find.text('2.0 ×'), findsOneWidget);
    });

    testWidgets('the speed slider is there for the decode effect, as for the typewriter', (tester) async {
      await _open(tester, Component(type: ComponentType.text, text: 'Salut', animation: AnimationType.decode, typewriterSpeed: 60));
      expect(_sliderOf('Viteză Typewriter (ms/caracter)'), findsOneWidget);
    });

    testWidgets('and not when the text has no animation', (tester) async {
      await _open(tester, Component(type: ComponentType.text, text: 'Salut', animation: AnimationType.none));
      expect(find.text('Viteză Typewriter (ms/caracter)'), findsNothing);
    });

    testWidgets('a text that already has effects shows them', (tester) async {
      await _open(
        tester,
        Component(type: ComponentType.text, text: 'Salut', italic: true, enableGlow: true, glowColor: '#33FF66', shadowDistance: 4),
      );
      expect(find.text('Culoare glow'), findsOneWidget);
      expect(find.text('Culoare umbră'), findsOneWidget);
    });
  });
}
