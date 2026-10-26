import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/create_components/add_component_widget.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/create_components/space_below_slider.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/model/puzzle.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

Future<void> _pump(WidgetTester tester, Widget child) {
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  return tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: Scaffold(body: SingleChildScrollView(child: child))));
}

void main() {
  group('slider', () {
    testWidgets('shows the usual 40 when nothing was chosen', (tester) async {
      await _pump(tester, SpaceBelowSlider(value: null, onChanged: (_) {}));
      expect(find.text('Spațiu sub componentă'), findsOneWidget);
      expect(find.text('40 px (implicit)'), findsOneWidget);
    });

    testWidgets('shows the chosen value', (tester) async {
      await _pump(tester, SpaceBelowSlider(value: 15, onChanged: (_) {}));
      expect(find.text('15 px'), findsOneWidget);
    });

    testWidgets('moving it reports a value in steps of 5 from 0 to 120', (tester) async {
      double? reported;
      await _pump(tester, SpaceBelowSlider(value: 40, onChanged: (v) => reported = v));

      await tester.drag(find.byType(Slider), const Offset(-2000, 0));
      await tester.pump();
      expect(reported, 0);

      await tester.drag(find.byType(Slider), const Offset(2000, 0));
      await tester.pump();
      expect(reported, 120);
    });

    testWidgets('the slider range is 0 to 120', (tester) async {
      await _pump(tester, SpaceBelowSlider(value: 40, onChanged: (_) {}));
      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.min, 0);
      expect(slider.max, 120);
      expect(slider.divisions, 24);
    });
  });

  group('in the component editor', () {
    Future<Component> open(WidgetTester tester, Component component) async {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: AddComponentWidget(puzzle: Puzzle(id: '0'), refreshUI: (_) {}, component: component, edit: true),
        ),
      );
      return component;
    }

    testWidgets('every kind of component has the slider', (tester) async {
      for (final type in ComponentType.values) {
        await open(tester, Component(type: type));
        expect(find.byType(SpaceBelowSlider), findsOneWidget, reason: type.name);
      }
    });

    testWidgets('changing it writes the value onto the component', (tester) async {
      final component = await open(tester, Component(type: ComponentType.text, text: 'Salut'));
      expect(component.spaceBelow, isNull);

      await tester.drag(find.byType(Slider).first, const Offset(-2000, 0));
      await tester.pump();
      expect(component.spaceBelow, 0);
    });

    testWidgets('not touching it leaves the component without a value', (tester) async {
      final component = await open(tester, Component(type: ComponentType.button, buttonLabel: 'Ok'));
      expect(component.spaceBelow, isNull);
    });

    testWidgets('a component that already has a value shows it', (tester) async {
      await open(tester, Component(type: ComponentType.text, text: 'Salut', spaceBelow: 70));
      expect(find.text('70 px'), findsOneWidget);
    });
  });
}
