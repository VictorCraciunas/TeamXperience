import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/event/countdown_box.dart';
import 'package:teamxperience/ui/components/inputs/code_boxes_input.dart';
import 'package:teamxperience/ui/components/misc/pulse_dot.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

Widget _app(Widget child, {bool still = false}) => MaterialApp(
      theme: AppTheme.light,
      builder: (context, app) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: still),
        child: app ?? const SizedBox.shrink(),
      ),
      home: Scaffold(body: Center(child: child)),
    );

Widget _boxes({bool error = false}) => CodeBoxesInput(length: 5, onChanged: (_) {}, error: error);

double _boxLeft(WidgetTester tester) => tester.getTopLeft(find.byKey(const ValueKey('code-box-0'))).dx;

void main() {
  group('PulseDot', () {
    FadeTransition fade(WidgetTester tester) => tester.widget(find.byKey(const ValueKey('pulse-dot')));

    testWidgets('breathes', (tester) async {
      await tester.pumpWidget(_app(const PulseDot(colour: Colors.red)));
      final first = fade(tester).opacity.value;
      await tester.pump(const Duration(milliseconds: 500));
      expect(fade(tester).opacity.value, isNot(first));
    });

    testWidgets('reduced motion: stands still, and nothing keeps running', (tester) async {
      await tester.pumpWidget(_app(const PulseDot(colour: Colors.red), still: true));
      expect(fade(tester).opacity.value, 1);
      await tester.pumpAndSettle();
    });

    testWidgets('stops when it leaves', (tester) async {
      await tester.pumpWidget(_app(const PulseDot(colour: Colors.red)));
      await tester.pumpWidget(_app(const SizedBox.shrink()));
      await tester.pumpAndSettle();
    });
  });

  group('CodeBoxesInput', () {
    testWidgets('a wrong code shakes once and ends in place', (tester) async {
      await tester.pumpWidget(_app(_boxes()));
      final home = _boxLeft(tester);
      await tester.pumpWidget(_app(_boxes(error: true)));
      await tester.pump(const Duration(milliseconds: 60));
      expect(_boxLeft(tester), isNot(home));
      await tester.pumpAndSettle();
      expect(_boxLeft(tester), home);
    });

    testWidgets('staying wrong does not shake again', (tester) async {
      await tester.pumpWidget(_app(_boxes(error: true)));
      final home = _boxLeft(tester);
      await tester.pumpWidget(_app(_boxes(error: true)));
      await tester.pump(const Duration(milliseconds: 60));
      expect(_boxLeft(tester), home);
    });

    testWidgets('reduced motion: no shake', (tester) async {
      await tester.pumpWidget(_app(_boxes(), still: true));
      final home = _boxLeft(tester);
      await tester.pumpWidget(_app(_boxes(error: true), still: true));
      await tester.pump(const Duration(milliseconds: 60));
      expect(_boxLeft(tester), home);
    });
  });

  group('CountdownBox', () {
    Widget box(int value) => SizedBox(width: 60, child: CountdownBox(value: value, label: 'min'));

    testWidgets('a new value slides in, and settles', (tester) async {
      await tester.pumpWidget(_app(box(5)));
      await tester.pumpWidget(_app(box(4)));
      await tester.pump(const Duration(milliseconds: 60));
      expect(find.text('5'), findsOneWidget, reason: 'the old value is on its way out');
      expect(find.text('4'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('5'), findsNothing);
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('reduced motion: it just changes', (tester) async {
      await tester.pumpWidget(_app(box(5), still: true));
      await tester.pumpWidget(_app(box(4), still: true));
      await tester.pump();
      expect(find.text('5'), findsNothing);
    });
  });
}
