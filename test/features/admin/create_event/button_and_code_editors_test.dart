import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/create_components/add_component_widget.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/create_components/create_button/create_button_controller.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/create_components/create_code/code_component_controller.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/create_components/option_checkbox.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/create_components/optional_slider.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/ui/components/inputs/app_dropdown.dart';
import 'package:teamxperience/utils/event_fonts.dart';
import 'package:teamxperience/model/puzzle.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

Future<void> _openEditor(WidgetTester tester, Component component) {
  tester.view.physicalSize = const Size(800, 6000);
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

void main() {
  group('button controller', () {
    test('starts with the usual look: spacing 8 and padding 5', () {
      final c = ButtonComponentController();
      expect(c.letterSpacing, 8);
      expect(c.paddingY, 5);
    });

    test('loads what the button has', () {
      final c = ButtonComponentController()
        ..initializeFromComponent(Component(type: ComponentType.button, letterSpacing: 2, paddingY: 14));
      expect(c.letterSpacing, 2);
      expect(c.paddingY, 14);
    });

    test('a button without them keeps the usual look', () {
      final c = ButtonComponentController()..initializeFromComponent(Component(type: ComponentType.button));
      expect(c.letterSpacing, 8);
      expect(c.paddingY, 5);
    });

    test('writes them onto the component, zero included', () {
      final c = ButtonComponentController()
        ..letterSpacing = 0
        ..paddingY = 0;
      final component = Component();
      c.updateComponentFields(component);
      expect(component.letterSpacing, 0);
      expect(component.paddingY, 0);
    });
  });

  group('code controller', () {
    test('starts with the usual look: automatic height, bold, glow on the frame', () {
      final c = CodeComponentController();
      expect(c.boxHeight, isNull);
      expect(c.boldText, isTrue);
      expect(c.glowOn, 'frame');
    });

    test('loads what the code input has', () {
      final c = CodeComponentController()
        ..initializeFromComponent(
          Component(type: ComponentType.code, boxHeight: 64, boldText: false, glowOn: 'boxes'),
        );
      expect(c.boxHeight, 64);
      expect(c.boldText, isFalse);
      expect(c.glowOn, 'boxes');
    });

    test('a code input without them keeps the usual look', () {
      final c = CodeComponentController()..initializeFromComponent(Component(type: ComponentType.code));
      expect(c.boxHeight, isNull);
      expect(c.boldText, isTrue);
      expect(c.glowOn, 'frame');
    });

    test('writes them onto the component', () {
      final c = CodeComponentController()
        ..boxHeight = 50
        ..boldText = false
        ..glowOn = 'boxes';
      final component = Component();
      c.updateComponent(component);
      expect(component.boxHeight, 50);
      expect(component.boldText, isFalse);
      expect(component.glowOn, 'boxes');
    });

    test('an automatic height stays automatic when saved', () {
      final component = Component(boxHeight: 40);
      CodeComponentController().updateComponent(component);
      expect(component.boxHeight, isNull);
    });
  });

  group('optional slider', () {
    testWidgets('shows the automatic value with a note until one is chosen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: OptionalSlider(
              title: 'Înălțime',
              min: 20,
              max: 100,
              divisions: 80,
              unit: 'px',
              value: null,
              automaticValue: 30,
              automaticNote: 'automat',
              onChanged: (_) {},
            ),
          ),
        ),
      );
      expect(find.text('30 px (automat)'), findsOneWidget);
    });

    testWidgets('shows the chosen value and reports changes', (tester) async {
      double? reported;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: OptionalSlider(
              title: 'Înălțime',
              min: 20,
              max: 100,
              divisions: 80,
              unit: 'px',
              value: 64,
              automaticValue: 30,
              automaticNote: 'automat',
              onChanged: (v) => reported = v,
            ),
          ),
        ),
      );
      expect(find.text('64 px'), findsOneWidget);
      await tester.drag(find.byType(Slider), const Offset(-2000, 0));
      await tester.pump();
      expect(reported, 20);
    });

    testWidgets('an automatic value outside the range is shown inside it', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: OptionalSlider(
              title: 'Înălțime',
              min: 20,
              max: 100,
              divisions: 80,
              unit: 'px',
              value: null,
              automaticValue: 12,
              automaticNote: 'automat',
              onChanged: (_) {},
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(tester.widget<Slider>(find.byType(Slider)).value, 20);
    });
  });

  group('button editor', () {
    testWidgets('has the two new sliders', (tester) async {
      await _openEditor(tester, Component(type: ComponentType.button, buttonLabel: 'Ok'));
      expect(_sliderOf('Spațiu între litere'), findsOneWidget);
      expect(_sliderOf('Spațiu sus și jos'), findsOneWidget);
    });

    testWidgets('moving the letter spacing changes the preview', (tester) async {
      await _openEditor(tester, Component(type: ComponentType.button, buttonLabel: 'Ok'));
      double spacing() => tester.widget<Text>(find.byWidgetPredicate((w) => w is Text && w.data == 'Ok' && w.style?.letterSpacing != null)).style!.letterSpacing!;
      expect(spacing(), 8);

      await tester.drag(_sliderOf('Spațiu între litere'), const Offset(-2000, 0));
      await tester.pump();
      expect(spacing(), 0);
    });
  });

  group('the font list of the editors', () {
    List<String> fontsOf(WidgetTester tester) {
      final dropdown = tester.widget<AppDropdown<String>>(
        find.byWidgetPredicate((w) => w is AppDropdown<String> && w.label == 'Tip Font'),
      );
      return [for (final item in dropdown.items) item.value];
    }

    testWidgets('text', (tester) async {
      await _openEditor(tester, Component(type: ComponentType.text, text: 'Salut'));
      expect(fontsOf(tester), eventFontNames);
    });

    testWidgets('button', (tester) async {
      await _openEditor(tester, Component(type: ComponentType.button, buttonLabel: 'Ok'));
      expect(fontsOf(tester), eventFontNames);
    });

    testWidgets('code input', (tester) async {
      await _openEditor(
        tester,
        Component(type: ComponentType.code, codeLength: 4, inputType: 'Separated', capsLock: 'CapsLock'),
      );
      expect(fontsOf(tester), eventFontNames);
    });
  });

  group('code editor', () {
    Component code({bool glow = false, String inputType = 'Separated'}) => Component(
          type: ComponentType.code,
          codeLength: 4,
          inputType: inputType,
          capsLock: 'CapsLock',
          enableGlow: glow,
        );

    testWidgets('has the box height slider and the bold option', (tester) async {
      await _openEditor(tester, code());
      expect(_sliderOf('Înălțime casete'), findsOneWidget);
      expect(find.text('Text îngroșat'), findsOneWidget);
    });

    testWidgets('the box height says automatic until it is moved', (tester) async {
      await _openEditor(tester, code());
      expect(find.textContaining('(automat)'), findsOneWidget);
      await tester.drag(_sliderOf('Înălțime casete'), const Offset(2000, 0));
      await tester.pump();
      expect(find.textContaining('(automat)'), findsNothing);
      expect(find.text('100 px'), findsOneWidget);
    });

    testWidgets('has the answer feedback option, on', (tester) async {
      await _openEditor(tester, code());
      expect(find.text('Animație la răspuns'), findsOneWidget);
      final box = tester.widget<Checkbox>(find.descendant(of: find.widgetWithText(OptionCheckbox, 'Animație la răspuns'), matching: find.byType(Checkbox)));
      expect(box.value, isTrue);
    });

    test('the controller starts with the feedback on and writes it only when it is off', () {
      final c = CodeComponentController();
      expect(c.answerFeedback, isTrue);
      final on = Component();
      c.updateComponent(on);
      expect(on.answerFeedback, isNull, reason: 'on is the usual, so nothing is written');

      c.answerFeedback = false;
      final off = Component();
      c.updateComponent(off);
      expect(off.answerFeedback, isFalse);
    });

    test('the controller loads a code input that has the feedback off', () {
      final c = CodeComponentController()..initializeFromComponent(Component(type: ComponentType.code, answerFeedback: false));
      expect(c.answerFeedback, isFalse);
    });

    testWidgets('where the glow is can be chosen when it is on and the boxes are separate', (tester) async {
      await _openEditor(tester, code(glow: true));
      expect(find.text('Glow pe'), findsOneWidget);
    });

    testWidgets('without glow there is nothing to place', (tester) async {
      await _openEditor(tester, code(glow: false));
      expect(find.text('Glow pe'), findsNothing);
    });

    testWidgets('a single free box has no choice of place', (tester) async {
      await _openEditor(tester, code(glow: true, inputType: 'Free'));
      expect(find.text('Glow pe'), findsNothing);
    });
  });
}
