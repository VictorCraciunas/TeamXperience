import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/create_components/add_component_widget.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/create_components/create_button/create_button_controller.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/create_components/create_image/create_image_controller.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/create_components/option_checkbox.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/model/puzzle.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

Future<void> _open(WidgetTester tester, Component component) {
  tester.view.physicalSize = const Size(800, 8000);
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

Future<void> _toMin(WidgetTester tester, String title) async {
  await tester.drag(_sliderOf(title), const Offset(-3000, 0));
  await tester.pump();
}

Future<void> _toMax(WidgetTester tester, String title) async {
  await tester.drag(_sliderOf(title), const Offset(3000, 0));
  await tester.pump();
}

final _boxTypes = [ComponentType.image, ComponentType.button, ComponentType.code];

Component _of(ComponentType type) => Component(
      type: type,
      buttonLabel: 'Ok',
      text: 'Salut',
      codeLength: 4,
      inputType: 'Separated',
      capsLock: 'CapsLock',
    );

void main() {
  group('opacity, in every editor', () {
    for (final type in ComponentType.values) {
      testWidgets('${type.name}: has the slider, at 100 %', (tester) async {
        await _open(tester, _of(type));
        expect(_sliderOf('Opacitate'), findsOneWidget);
        expect(find.text('100 %'), findsOneWidget);
      });
    }

    testWidgets('moving it writes the opacity onto the component', (tester) async {
      final component = _of(ComponentType.button);
      await _open(tester, component);
      await _toMin(tester, 'Opacitate');
      expect(component.opacity, 0.0);
      expect(find.text('0 %'), findsOneWidget);
    });

    testWidgets('back to 100 % removes it again, so the component is as it was', (tester) async {
      final component = _of(ComponentType.button)..opacity = 0.4;
      await _open(tester, component);
      await _toMax(tester, 'Opacitate');
      expect(component.opacity, isNull);
    });

    testWidgets('a component that already has one shows it', (tester) async {
      await _open(tester, _of(ComponentType.image)..opacity = 0.5);
      expect(find.text('50 %'), findsOneWidget);
    });

    testWidgets('the preview becomes see-through at once', (tester) async {
      await _open(tester, _of(ComponentType.button));
      await _toMin(tester, 'Opacitate');
      expect(tester.widgetList<Opacity>(find.byType(Opacity)).where((o) => o.opacity == 0.0), isNotEmpty);
    });
  });

  group('shadow, for an image, a button and a code input', () {
    for (final type in _boxTypes) {
      testWidgets('${type.name}: the editor has the two sliders', (tester) async {
        await _open(tester, _of(type));
        expect(_sliderOf('Încețoșare umbră'), findsOneWidget);
        expect(_sliderOf('Distanță umbră'), findsOneWidget);
        expect(find.text('Culoare umbră'), findsNothing);
      });
    }

    testWidgets('a text has just its own shadow controls, not two sets', (tester) async {
      await _open(tester, _of(ComponentType.text));
      expect(find.text('Încețoșare umbră'), findsOneWidget);
      expect(find.text('Distanță umbră'), findsOneWidget);
    });

    testWidgets('moving them writes onto the component and shows the colour', (tester) async {
      final component = _of(ComponentType.button);
      await _open(tester, component);
      await _toMax(tester, 'Distanță umbră');
      expect(component.shadowDistance, 20);
      expect(component.shadowBlur, isNull, reason: '0 is not written');
      expect(find.text('Culoare umbră'), findsOneWidget);

      await _toMax(tester, 'Încețoșare umbră');
      expect(component.shadowBlur, 30);
    });

    testWidgets('back to 0 and 0 removes the shadow', (tester) async {
      final component = _of(ComponentType.image)
        ..shadowBlur = 6
        ..shadowDistance = 4
        ..shadowColor = '#112233';
      await _open(tester, component);
      await _toMin(tester, 'Încețoșare umbră');
      await _toMin(tester, 'Distanță umbră');
      expect(component.shadowBlur, isNull);
      expect(component.shadowDistance, isNull);
      expect(component.shadowColor, isNull);
      expect(find.text('Culoare umbră'), findsNothing);
    });

    testWidgets('a component that already has a shadow shows it', (tester) async {
      await _open(tester, _of(ComponentType.code)..shadowDistance = 5);
      expect(find.text('Culoare umbră'), findsOneWidget);
    });

    testWidgets('the preview gets the shadow at once', (tester) async {
      await _open(tester, _of(ComponentType.button));
      await _toMax(tester, 'Distanță umbră');
      final boxes = tester.widgetList<DecoratedBox>(find.byType(DecoratedBox));
      expect(
        boxes.any((b) => b.decoration is BoxDecoration && ((b.decoration as BoxDecoration).boxShadow?.any((s) => s.offset == const Offset(20, 20)) ?? false)),
        isTrue,
      );
    });
  });

  group('image controller', () {
    test('starts with the usual look: no border, no glow', () {
      final c = ImageComponentController();
      expect(c.borderWidth, 0);
      expect(c.enableGlow, isFalse);
    });

    test('loads what the image has', () {
      final c = ImageComponentController()
        ..initializeFromComponent(
          Component(type: ComponentType.image, borderWidth: 3, borderColor: '#33FF66', enableGlow: true, glowColor: '#FF3EA5'),
        );
      expect(c.borderWidth, 3);
      expect(c.borderColor, '#33FF66');
      expect(c.enableGlow, isTrue);
      expect(c.glowColor, '#FF3EA5');
    });

    test('writes only what was chosen', () {
      final c = ImageComponentController()..image = File('/tmp/a.png');
      final component = Component();
      c.updateComponentFields(component);
      expect(component.borderWidth, isNull);
      expect(component.borderColor, isNull);
      expect(component.enableGlow, isNull);
      expect(component.glowColor, isNull);
    });

    test('writes a border and a glow when chosen', () {
      final c = ImageComponentController()
        ..image = File('/tmp/a.png')
        ..borderWidth = 4
        ..borderColor = '#33FF66'
        ..enableGlow = true
        ..glowColor = '#FF3EA5';
      final component = Component();
      c.updateComponentFields(component);
      expect(component.borderWidth, 4);
      expect(component.borderColor, '#33FF66');
      expect(component.enableGlow, isTrue);
      expect(component.glowColor, '#FF3EA5');
    });

    test('a border and a glow that were switched off are removed', () {
      final component = Component(borderWidth: 3, borderColor: '#000000', enableGlow: true, glowColor: '#000000');
      ImageComponentController()
        ..image = File('/tmp/a.png')
        ..updateComponentFields(component);
      expect(component.borderWidth, isNull);
      expect(component.borderColor, isNull);
      expect(component.enableGlow, isNull);
      expect(component.glowColor, isNull);
    });
  });

  group('image editor', () {
    testWidgets('has the border and the glow controls', (tester) async {
      await _open(tester, Component(type: ComponentType.image));
      expect(_sliderOf('Grosime chenar'), findsOneWidget);
      expect(find.text('Glow imagine'), findsOneWidget);
    });

    testWidgets('the border colour appears only with a border', (tester) async {
      await _open(tester, Component(type: ComponentType.image));
      expect(find.text('Culoare chenar'), findsNothing);
      await _toMax(tester, 'Grosime chenar');
      expect(find.text('Culoare chenar'), findsOneWidget);
    });

    testWidgets('the glow colour appears only with the glow on', (tester) async {
      await _open(tester, Component(type: ComponentType.image));
      expect(find.text('Culoare glow'), findsNothing);
      await tester.tap(find.widgetWithText(OptionCheckbox, 'Glow imagine'));
      await tester.pump();
      expect(find.text('Culoare glow'), findsOneWidget);
    });
  });

  group('button controller and editor', () {
    test('a button has a border 1.5 wide, as it always had', () {
      expect(ButtonComponentController().borderWidth, 1.5);
    });

    test('loads and writes the border width', () {
      final c = ButtonComponentController()
        ..initializeFromComponent(Component(type: ComponentType.button, borderWidth: 4));
      expect(c.borderWidth, 4);
      final component = Component();
      c.updateComponentFields(component);
      expect(component.borderWidth, 4);
    });

    test('0 is a border width, so no border', () {
      final c = ButtonComponentController()..borderWidth = 0;
      final component = Component();
      c.updateComponentFields(component);
      expect(component.borderWidth, 0);
    });

    testWidgets('the editor has the slider and moving it changes the preview', (tester) async {
      await _open(tester, Component(type: ComponentType.button, buttonLabel: 'Ok'));
      expect(_sliderOf('Grosime chenar'), findsOneWidget);
      await _toMax(tester, 'Grosime chenar');
      final boxes = tester.widgetList<DecoratedBox>(find.byType(DecoratedBox));
      expect(boxes.any((b) => b.decoration is BoxDecoration && (b.decoration as BoxDecoration).border?.top.width == 6), isTrue);
    });
  });
}
