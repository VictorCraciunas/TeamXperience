import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/screen_animation.dart';
import 'package:teamxperience/features/event_game/logic/component_fades.dart';

AnimationController _controller(WidgetTester tester) {
  final controller = AnimationController(vsync: tester, duration: const Duration(milliseconds: 2000));
  addTearDown(controller.dispose);
  return controller;
}

void main() {
  group('fade', () {
    testWidgets('starts with every component invisible', (tester) async {
      final fades = componentFades(_controller(tester), 4, ScreenAnimation.fade);
      expect(fades.map((f) => f.value), everyElement(0.0));
    });

    testWidgets('they appear one after another', (tester) async {
      final controller = _controller(tester);
      final fades = componentFades(controller, 4, ScreenAnimation.fade);

      controller.value = 0.25;
      expect(fades[0].value, 1.0);
      expect(fades[1].value, 0.0);

      controller.value = 0.5;
      expect(fades[1].value, 1.0);
      expect(fades[2].value, 0.0);

      controller.value = 1.0;
      expect(fades.map((f) => f.value), everyElement(1.0));
    });

    testWidgets('each one is half visible half way through its own turn', (tester) async {
      final controller = _controller(tester)..value = 0.125;
      final fades = componentFades(controller, 4, ScreenAnimation.fade);
      expect(fades[0].value, greaterThan(0));
      expect(fades[0].value, lessThan(1));
    });

    testWidgets('there is one fade per component', (tester) async {
      expect(componentFades(_controller(tester), 7, ScreenAnimation.fade), hasLength(7));
      expect(componentFades(_controller(tester), 0, ScreenAnimation.fade), isEmpty);
    });
  });

  group('none', () {
    testWidgets('every component is fully visible from the start', (tester) async {
      final fades = componentFades(_controller(tester), 4, ScreenAnimation.none);
      expect(fades, hasLength(4));
      expect(fades.map((f) => f.value), everyElement(1.0));
    });

    testWidgets('and stays so while the controller runs', (tester) async {
      final controller = _controller(tester);
      final fades = componentFades(controller, 3, ScreenAnimation.none);
      for (final value in [0.0, 0.3, 0.9, 1.0]) {
        controller.value = value;
        expect(fades.map((f) => f.value), everyElement(1.0));
      }
    });

    testWidgets('there is one per component', (tester) async {
      expect(componentFades(_controller(tester), 0, ScreenAnimation.none), isEmpty);
      expect(componentFades(_controller(tester), 5, ScreenAnimation.none), hasLength(5));
    });
  });

  group('starting', () {
    testWidgets('fade plays from the beginning', (tester) async {
      final controller = _controller(tester)..value = 0.7;
      startEntrance(controller, ScreenAnimation.fade);
      expect(controller.value, 0.0);
      expect(controller.isAnimating, isTrue);
      controller.stop();
    });

    testWidgets('none shows everything at once and plays nothing', (tester) async {
      final controller = _controller(tester);
      startEntrance(controller, ScreenAnimation.none);
      expect(controller.value, 1.0);
      expect(controller.isAnimating, isFalse);
    });

    testWidgets('going back to fade after none plays again', (tester) async {
      final controller = _controller(tester);
      startEntrance(controller, ScreenAnimation.none);
      startEntrance(controller, ScreenAnimation.fade);
      expect(controller.value, 0.0);
      expect(controller.isAnimating, isTrue);
      controller.stop();
    });
  });
}
