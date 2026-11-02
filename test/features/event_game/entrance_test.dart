import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/screen_animation.dart';
import 'package:teamxperience/features/event_game/logic/component_fades.dart';
import 'package:teamxperience/features/event_game/logic/entrance.dart';
import 'package:teamxperience/features/event_game/logic/spaced_components.dart';

void main() {
  group('the kinds of entrance', () {
    test('there are fade, none and six more', () {
      expect(ScreenAnimation.values.map((a) => a.name), [
        'fade',
        'none',
        'slideFromLeft',
        'slideFromRight',
        'slideFromBottom',
        'slideFromTop',
        'zoom',
        'bounce',
      ]);
    });

    test('each has a label for the form', () {
      for (final animation in ScreenAnimation.values) {
        expect(animation.label, isNotEmpty);
      }
      expect(ScreenAnimation.slideFromLeft.label, 'Slide din stânga');
      expect(ScreenAnimation.bounce.label, 'Bounce');
    });

    test('anything unknown is still fade', () {
      expect(ScreenAnimation.fromName('slideFromLeft'), ScreenAnimation.slideFromLeft);
      expect(ScreenAnimation.fromName('spin'), ScreenAnimation.fade);
    });
  });

  group('the position of a component during its entrance', () {
    test('every kind ends in place, fully visible, at full size', () {
      for (final mode in ScreenAnimation.values) {
        final end = entranceFrame(mode, 1.0);
        expect(end.opacity, 1.0, reason: mode.name);
        expect(end.dx, 0.0, reason: mode.name);
        expect(end.dy, 0.0, reason: mode.name);
        expect(end.scale, 1.0, reason: mode.name);
      }
    });

    test('fade only changes how visible it is', () {
      final half = entranceFrame(ScreenAnimation.fade, 0.5);
      expect(half.opacity, 0.5);
      expect(half.dx, 0);
      expect(half.dy, 0);
      expect(half.scale, 1);
      expect(entranceFrame(ScreenAnimation.fade, 0).opacity, 0);
    });

    test('none is always fully there', () {
      final start = entranceFrame(ScreenAnimation.none, 0);
      expect(start.opacity, 1);
      expect(start.dx, 0);
      expect(start.dy, 0);
      expect(start.scale, 1);
    });

    test('from the left starts to the left of its place and moves right', () {
      final start = entranceFrame(ScreenAnimation.slideFromLeft, 0);
      expect(start.dx, lessThan(0));
      expect(start.dy, 0);
      expect(start.opacity, 0);
      expect(entranceFrame(ScreenAnimation.slideFromLeft, 0.5).dx, greaterThan(start.dx));
      expect(entranceFrame(ScreenAnimation.slideFromLeft, 0.5).dx, lessThan(0));
    });

    test('from the right starts to the right of its place', () {
      expect(entranceFrame(ScreenAnimation.slideFromRight, 0).dx, greaterThan(0));
      expect(entranceFrame(ScreenAnimation.slideFromRight, 0).dy, 0);
    });

    test('from the bottom starts below its place', () {
      expect(entranceFrame(ScreenAnimation.slideFromBottom, 0).dy, greaterThan(0));
      expect(entranceFrame(ScreenAnimation.slideFromBottom, 0).dx, 0);
    });

    test('from the top starts above its place', () {
      expect(entranceFrame(ScreenAnimation.slideFromTop, 0).dy, lessThan(0));
    });

    test('the slides are of the same distance', () {
      final distance = entranceFrame(ScreenAnimation.slideFromLeft, 0).dx.abs();
      expect(entranceFrame(ScreenAnimation.slideFromRight, 0).dx, distance);
      expect(entranceFrame(ScreenAnimation.slideFromBottom, 0).dy, distance);
      expect(entranceFrame(ScreenAnimation.slideFromTop, 0).dy, -distance);
    });

    test('zoom starts small and grows to full size', () {
      final start = entranceFrame(ScreenAnimation.zoom, 0);
      expect(start.scale, lessThan(1));
      expect(start.scale, greaterThan(0));
      expect(start.opacity, 0);
      expect(entranceFrame(ScreenAnimation.zoom, 0.5).scale, inExclusiveRange(start.scale, 1));
    });

    test('bounce starts below, goes past its place and settles back', () {
      expect(entranceFrame(ScreenAnimation.bounce, 0).dy, greaterThan(0));

      final past = [for (var p = 0.0; p <= 1.0; p += 0.05) entranceFrame(ScreenAnimation.bounce, p).dy].any((dy) => dy < 0);
      expect(past, isTrue, reason: 'it overshoots');
      expect(entranceFrame(ScreenAnimation.bounce, 1).dy, 0);
    });

    test('opacity never leaves 0 to 1 and a slide moves steadily towards its place', () {
      for (final mode in ScreenAnimation.values) {
        for (var p = 0.0; p <= 1.0; p += 0.1) {
          final frame = entranceFrame(mode, p);
          expect(frame.opacity, inInclusiveRange(0, 1), reason: '${mode.name} $p');
        }
      }
      var last = double.negativeInfinity;
      for (var p = 0.0; p <= 1.0; p += 0.1) {
        final dx = entranceFrame(ScreenAnimation.slideFromLeft, p).dx;
        expect(dx, greaterThanOrEqualTo(last));
        last = dx;
      }
    });

    test('a progress outside 0 to 1 is treated as the nearest end', () {
      expect(entranceFrame(ScreenAnimation.fade, -1).opacity, 0);
      expect(entranceFrame(ScreenAnimation.fade, 2).opacity, 1);
    });
  });

  group('timing', () {
    test('left alone it is what the game always did: 2 seconds, one window each', () {
      const timing = EntranceTiming();
      expect(timing.total(4), const Duration(milliseconds: 2000));
      expect(timing.start(0, 4), 0);
      expect(timing.end(0, 4), 0.25);
      expect(timing.start(3, 4), 0.75);
      expect(timing.end(3, 4), 1.0);
    });

    test('with a duration and a delay each component starts after the one before', () {
      const timing = EntranceTiming(durationMs: 600, delayMs: 250);
      expect(timing.total(4), const Duration(milliseconds: 3 * 250 + 600));
      expect(timing.start(0, 4), 0);
      expect(timing.end(0, 4), closeTo(600 / 1350, 1e-9));
      expect(timing.start(3, 4), closeTo(750 / 1350, 1e-9));
      expect(timing.end(3, 4), 1.0);
    });

    test('with no delay everything plays together', () {
      const timing = EntranceTiming(durationMs: 500, delayMs: 0);
      expect(timing.total(5), const Duration(milliseconds: 500));
      expect(timing.start(4, 5), 0);
      expect(timing.end(4, 5), 1.0);
    });

    test('a duration alone uses the usual delay, a delay alone the usual duration', () {
      expect(const EntranceTiming(durationMs: 400).total(3), const Duration(milliseconds: 2 * 250 + 400));
      expect(const EntranceTiming(delayMs: 100).total(3), const Duration(milliseconds: 2 * 100 + 600));
    });

    test('one component is only its duration', () {
      expect(const EntranceTiming(durationMs: 800, delayMs: 300).total(1), const Duration(milliseconds: 800));
    });

    test('no components still has a usable length', () {
      expect(const EntranceTiming().total(0).inMilliseconds, greaterThan(0));
      expect(const EntranceTiming(durationMs: 400, delayMs: 100).total(0).inMilliseconds, greaterThan(0));
    });

    test('is automatic only when nothing was chosen', () {
      expect(const EntranceTiming().isAutomatic, isTrue);
      expect(const EntranceTiming(durationMs: 400).isAutomatic, isFalse);
      expect(const EntranceTiming(delayMs: 0).isAutomatic, isFalse);
    });
  });

  group('playing', () {
    AnimationController controller(WidgetTester tester) {
      final c = AnimationController(vsync: tester, duration: const Duration(milliseconds: 2000));
      addTearDown(c.dispose);
      return c;
    }

    testWidgets('the usual entrance lasts 2 seconds', (tester) async {
      final c = controller(tester);
      startEntrance(c, ScreenAnimation.fade, count: 4);
      expect(c.duration, const Duration(milliseconds: 2000));
      c.stop();
    });

    testWidgets('a chosen timing sets how long it plays', (tester) async {
      final c = controller(tester);
      startEntrance(c, ScreenAnimation.zoom, count: 4, timing: const EntranceTiming(durationMs: 600, delayMs: 250));
      expect(c.duration, const Duration(milliseconds: 1350));
      expect(c.value, 0);
      expect(c.isAnimating, isTrue);
      c.stop();
    });

    testWidgets('none still shows everything at once whatever the timing', (tester) async {
      final c = controller(tester);
      startEntrance(c, ScreenAnimation.none, count: 4, timing: const EntranceTiming(durationMs: 600, delayMs: 250));
      expect(c.value, 1);
      expect(c.isAnimating, isFalse);
    });

    testWidgets('the components follow the chosen timing', (tester) async {
      final c = controller(tester);
      const timing = EntranceTiming(durationMs: 600, delayMs: 250);
      final fades = componentFades(c, 4, ScreenAnimation.slideFromLeft, timing: timing);
      c.duration = timing.total(4);

      c.value = 300 / 1350; // half way through the first, before the second has started
      expect(fades[0].value, greaterThan(0));
      expect(fades[1].value, greaterThan(0), reason: 'the second starts after 250 ms');
      expect(fades[2].value, 0);
      expect(fades[3].value, 0);

      c.value = 1.0;
      expect(fades.map((f) => f.value), everyElement(1.0));
    });
  });

  group('drawing the components', () {
    Widget box(String label) => SizedBox(key: ValueKey(label), width: 50, height: 20, child: Text(label));

    Future<void> pumpList(WidgetTester tester, List<Widget> children) {
      return tester.pumpWidget(MaterialApp(home: Scaffold(body: Column(children: children))));
    }

    testWidgets('a fade has no movement and no scale, as always', (tester) async {
      await pumpList(tester, spacedComponents([box('a')], const [AlwaysStoppedAnimation(0.5)], const []));
      expect(find.descendant(of: find.byKey(const ValueKey('a')).first, matching: find.byType(Transform)), findsNothing);
      expect(tester.widgetList<Opacity>(find.byType(Opacity)).single.opacity, 0.5);
    });

    testWidgets('a slide from the left is moved to the left at the start and in place at the end', (tester) async {
      await pumpList(
        tester,
        spacedComponents([box('a')], const [AlwaysStoppedAnimation(0.0)], const [], mode: ScreenAnimation.slideFromLeft),
      );
      final startLeft = tester.getTopLeft(find.byKey(const ValueKey('a'))).dx;

      await pumpList(
        tester,
        spacedComponents([box('a')], const [AlwaysStoppedAnimation(1.0)], const [], mode: ScreenAnimation.slideFromLeft),
      );
      final endLeft = tester.getTopLeft(find.byKey(const ValueKey('a'))).dx;

      expect(startLeft, lessThan(endLeft));
    });

    testWidgets('a zoom is small at the start and full size at the end', (tester) async {
      await pumpList(tester, spacedComponents([box('a')], const [AlwaysStoppedAnimation(0.0)], const [], mode: ScreenAnimation.zoom));
      final small = tester.getRect(find.byKey(const ValueKey('a'))).width;
      await pumpList(tester, spacedComponents([box('a')], const [AlwaysStoppedAnimation(1.0)], const [], mode: ScreenAnimation.zoom));
      final full = tester.getRect(find.byKey(const ValueKey('a'))).width;
      expect(small, lessThan(full));
      expect(full, 50);
    });

    testWidgets('the space between components does not move with the animation', (tester) async {
      await pumpList(
        tester,
        spacedComponents([box('a'), box('b')], const [AlwaysStoppedAnimation(0.0), AlwaysStoppedAnimation(0.0)], [10, null], mode: ScreenAnimation.slideFromBottom),
      );
      final gapAtStart = tester.getTopLeft(find.byKey(const ValueKey('b'))).dy - tester.getBottomLeft(find.byKey(const ValueKey('a'))).dy;
      await pumpList(
        tester,
        spacedComponents([box('a'), box('b')], const [AlwaysStoppedAnimation(1.0), AlwaysStoppedAnimation(1.0)], [10, null], mode: ScreenAnimation.slideFromBottom),
      );
      final gapAtEnd = tester.getTopLeft(find.byKey(const ValueKey('b'))).dy - tester.getBottomLeft(find.byKey(const ValueKey('a'))).dy;
      expect(gapAtEnd, 10);
      expect(gapAtStart, 10, reason: 'the movement is only drawn, the layout does not change');
    });

    testWidgets('none draws everything in place and visible, whatever the progress', (tester) async {
      await pumpList(
        tester,
        spacedComponents([box('a')], const [AlwaysStoppedAnimation(0.0)], const [], mode: ScreenAnimation.none),
      );
      expect(tester.widgetList<Opacity>(find.byType(Opacity)).single.opacity, 1.0);
    });

    testWidgets('every kind draws without trouble', (tester) async {
      for (final mode in ScreenAnimation.values) {
        for (final progress in [0.0, 0.5, 1.0]) {
          await pumpList(
            tester,
            spacedComponents([box('a'), box('b')], [AlwaysStoppedAnimation(progress), AlwaysStoppedAnimation(progress)], const [], mode: mode),
          );
          expect(tester.takeException(), isNull, reason: '${mode.name} $progress');
        }
      }
    });
  });
}
