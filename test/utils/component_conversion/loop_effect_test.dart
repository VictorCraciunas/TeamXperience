import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/enums/loop_effect.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/utils/component_conversion/component_to_widget.dart';
import 'package:teamxperience/utils/component_conversion/loop_effect_widget.dart';

import '../../ui/pump_ui.dart';

void main() {
  group('the effects', () {
    test('are pulse, float, shake, flicker and glitch', () {
      expect(LoopEffect.values.map((e) => e.name), ['pulse', 'float', 'shake', 'flicker', 'glitch']);
    });

    test('each has a label and a length of one round', () {
      for (final effect in LoopEffect.values) {
        expect(effect.label, isNotEmpty);
        expect(effect.cycle.inMilliseconds, inInclusiveRange(1000, 3000), reason: effect.name);
      }
      expect(LoopEffect.pulse.label, 'Pulse');
    });

    test('are read from their name, and anything unknown is none', () {
      expect(LoopEffect.fromName('shake'), LoopEffect.shake);
      expect(LoopEffect.fromName(null), isNull);
      expect(LoopEffect.fromName(''), isNull);
      expect(LoopEffect.fromName('spin'), isNull);
    });
  });

  group('how a component moves', () {
    test('every effect starts and ends a round in place, so the loop has no jump', () {
      for (final effect in LoopEffect.values) {
        for (final t in [0.0, 1.0]) {
          final frame = loopFrame(effect, t);
          expect(frame.dx, closeTo(0, 1e-9), reason: '${effect.name} $t');
          expect(frame.dy, closeTo(0, 1e-9), reason: '${effect.name} $t');
          expect(frame.scale, closeTo(1, 1e-9), reason: '${effect.name} $t');
          expect(frame.opacity, closeTo(1, 1e-9), reason: '${effect.name} $t');
        }
      }
    });

    test('pulse grows a little and comes back', () {
      final top = loopFrame(LoopEffect.pulse, 0.5).scale;
      expect(top, closeTo(1.07, 0.001));
      expect(loopFrame(LoopEffect.pulse, 0.25).scale, inExclusiveRange(1, top));
      expect(loopFrame(LoopEffect.pulse, 0.5).dx, 0);
    });

    test('float rises and comes back', () {
      expect(loopFrame(LoopEffect.float, 0.5).dy, closeTo(-7, 0.001));
      expect(loopFrame(LoopEffect.float, 0.25).dy, inExclusiveRange(-7, 0));
      expect(loopFrame(LoopEffect.float, 0.5).dx, 0);
    });

    test('shake goes left and right for a moment, then rests', () {
      final during = [for (var t = 0.0; t <= 0.25; t += 0.01) loopFrame(LoopEffect.shake, t).dx];
      expect(during.any((dx) => dx < -3), isTrue);
      expect(during.any((dx) => dx > 3), isTrue);
      expect(during.every((dx) => dx.abs() <= 9), isTrue);

      final resting = [for (var t = 0.3; t <= 1.0; t += 0.05) loopFrame(LoopEffect.shake, t).dx];
      expect(resting, everyElement(0.0));
    });

    test('flicker dims and comes back, never fully invisible', () {
      final values = [for (var t = 0.0; t <= 1.0; t += 0.01) loopFrame(LoopEffect.flicker, t).opacity];
      expect(values.reduce((a, b) => a < b ? a : b), lessThan(0.5));
      expect(values.reduce((a, b) => a < b ? a : b), greaterThan(0.2));
      expect(values.every((v) => v <= 1), isTrue);
      expect(loopFrame(LoopEffect.flicker, 0.5).dx, 0);
    });

    test('glitch is still most of the time and jumps for a moment near the end', () {
      for (final t in [0.0, 0.2, 0.5, 0.8, 0.88]) {
        final frame = loopFrame(LoopEffect.glitch, t);
        expect(frame.dx, 0, reason: '$t');
        expect(frame.dy, 0, reason: '$t');
      }
      final jumps = [for (var t = 0.9; t <= 1.0; t += 0.005) loopFrame(LoopEffect.glitch, t).dx];
      expect(jumps.any((dx) => dx.abs() >= 3), isTrue);
      expect(jumps.any((dx) => dx < 0) && jumps.any((dx) => dx > 0), isTrue, reason: 'it jumps both ways');
    });

    test('a time outside one round counts from the start of the round', () {
      for (final effect in LoopEffect.values) {
        final a = loopFrame(effect, 0.3);
        final b = loopFrame(effect, 1.3);
        expect(b.dx, closeTo(a.dx, 1e-9), reason: effect.name);
        expect(b.scale, closeTo(a.scale, 1e-9), reason: effect.name);
      }
    });
  });

  group('the widget', () {
    Widget child() => const SizedBox(key: ValueKey('c'), width: 100, height: 40);

    Future<void> pump(WidgetTester tester, LoopEffect? effect, {bool disableAnimations = false}) {
      return tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: disableAnimations),
            child: Scaffold(body: Align(alignment: Alignment.topLeft, child: LoopEffectWidget(effect: effect, child: child()))),
          ),
        ),
      );
    }

    testWidgets('without an effect it is just the component', (tester) async {
      await pump(tester, null);
      expect(find.descendant(of: find.byType(LoopEffectWidget), matching: find.byType(Transform)), findsNothing);
      expect(find.byKey(const ValueKey('c')), findsOneWidget);
    });

    testWidgets('pulse makes it grow and shrink, drawn only, the layout stays', (tester) async {
      await pump(tester, LoopEffect.pulse);
      final size = tester.getSize(find.byKey(const ValueKey('c')));
      final start = tester.getRect(find.byKey(const ValueKey('c'))).width;

      await tester.pump(LoopEffect.pulse.cycle ~/ 2);
      final top = tester.getRect(find.byKey(const ValueKey('c'))).width;
      expect(top, greaterThan(start));
      expect(tester.getSize(find.byKey(const ValueKey('c'))), size);

      await tester.pump(LoopEffect.pulse.cycle ~/ 2);
      expect(tester.getRect(find.byKey(const ValueKey('c'))).width, closeTo(start, 0.5));
    });

    testWidgets('float moves it up', (tester) async {
      await pump(tester, LoopEffect.float);
      final start = tester.getTopLeft(find.byKey(const ValueKey('c'))).dy;
      await tester.pump(LoopEffect.float.cycle ~/ 2);
      expect(tester.getTopLeft(find.byKey(const ValueKey('c'))).dy, lessThan(start));
    });

    testWidgets('shake moves it sideways at the start of each round', (tester) async {
      await pump(tester, LoopEffect.shake);
      final start = tester.getTopLeft(find.byKey(const ValueKey('c'))).dx;
      var moved = false;
      for (var i = 0; i < 25; i++) {
        await tester.pump(const Duration(milliseconds: 20));
        if ((tester.getTopLeft(find.byKey(const ValueKey('c'))).dx - start).abs() > 3) moved = true;
      }
      expect(moved, isTrue);
    });

    testWidgets('flicker makes it see-through now and then', (tester) async {
      await pump(tester, LoopEffect.flicker);
      var dimmed = false;
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 40));
        final opacity = tester.widgetList<Opacity>(find.descendant(of: find.byType(LoopEffectWidget), matching: find.byType(Opacity)));
        if (opacity.any((o) => o.opacity < 0.6)) dimmed = true;
      }
      expect(dimmed, isTrue);
    });

    testWidgets('it keeps going round after round', (tester) async {
      await pump(tester, LoopEffect.float);
      await tester.pump(LoopEffect.float.cycle * 3 + LoopEffect.float.cycle ~/ 2);
      final start = tester.getTopLeft(find.byKey(const ValueKey('c'))).dy;
      expect(start, lessThan(1), reason: 'half way through a round it is up, so above where it started at 0');
    });

    testWidgets('with animations switched off in the phone settings it stands still', (tester) async {
      await pump(tester, LoopEffect.pulse, disableAnimations: true);
      final start = tester.getRect(find.byKey(const ValueKey('c'))).width;
      await tester.pump(LoopEffect.pulse.cycle ~/ 2);
      expect(tester.getRect(find.byKey(const ValueKey('c'))).width, start);
    });

    testWidgets('changing the effect changes the motion, removing it stops it', (tester) async {
      await pump(tester, LoopEffect.float);
      await tester.pump(LoopEffect.float.cycle ~/ 2);
      await pump(tester, null);
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.getTopLeft(find.byKey(const ValueKey('c'))).dy, 0);
    });

    testWidgets('leaving the screen disposes it without trouble', (tester) async {
      await pump(tester, LoopEffect.glitch);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });
  });

  group('on every kind of component', () {
    Component component(ComponentType type, {LoopEffect? effect}) => Component(
          type: type,
          text: 'Salut',
          buttonLabel: 'OK',
          codeLength: 4,
          inputType: 'Separated',
          loopEffect: effect,
        );

    for (final type in ComponentType.values) {
      testWidgets('${type.name}: every effect draws and moves round after round', (tester) async {
        for (final effect in LoopEffect.values) {
          await pumpUi(tester, Column(children: [ComponentToWidget().convert(component(type, effect: effect))]), width: 360);
          for (var i = 0; i < 6; i++) {
            await tester.pump(effect.cycle ~/ 3);
          }
          expect(tester.takeException(), isNull, reason: '${type.name} ${effect.name}');
        }
      });

      testWidgets('${type.name}: without an effect there is nothing added', (tester) async {
        await pumpUi(tester, Column(children: [ComponentToWidget().convert(component(type))]), width: 360);
        final widget = tester.widgetList<LoopEffectWidget>(find.byType(LoopEffectWidget));
        expect(widget.where((w) => w.effect != null), isEmpty);
      });
    }

    testWidgets('a text with an effect and a typewriter does both', (tester) async {
      await pumpUi(
        tester,
        Column(children: [ComponentToWidget().convert(Component(type: ComponentType.text, text: 'Salut', loopEffect: LoopEffect.float))]),
        width: 360,
      );
      expect(find.byType(LoopEffectWidget), findsOneWidget);
    });
  });
}
