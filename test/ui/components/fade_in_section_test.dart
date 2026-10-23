import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/misc/fade_in_section.dart';

double _opacity(WidgetTester tester, String label) {
  final fade = find.ancestor(of: find.text(label), matching: find.byType(FadeTransition)).first;
  return tester.widget<FadeTransition>(fade).opacity.value;
}

double _top(WidgetTester tester, String label) => tester.getTopLeft(find.text(label)).dy;

Widget _app(Widget child, {bool disableAnimations = false}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Scaffold(body: child),
    ),
  );
}

void main() {
  testWidgets('starts invisible and fades in', (tester) async {
    await tester.pumpWidget(_app(const FadeInSection(order: 0, child: Text('unu'))));
    expect(_opacity(tester, 'unu'), 0);
    await tester.pump(); // the animation starts after the first frame
    await tester.pump(const Duration(milliseconds: 200));
    final mid = _opacity(tester, 'unu');
    expect(mid, greaterThan(0));
    expect(mid, lessThan(1));
    await tester.pumpAndSettle();
    expect(_opacity(tester, 'unu'), 1);
  });

  testWidgets('moves down into place from above (top down)', (tester) async {
    await tester.pumpWidget(_app(const FadeInSection(order: 0, child: Text('unu'))));
    final start = _top(tester, 'unu');
    await tester.pumpAndSettle();
    expect(_top(tester, 'unu'), greaterThan(start));
  });

  testWidgets('later sections start later, so they appear top to bottom', (tester) async {
    await tester.pumpWidget(
      _app(
        const Column(
          children: [
            FadeInSection(order: 0, child: Text('unu')),
            FadeInSection(order: 3, child: Text('patru')),
          ],
        ),
      ),
    );
    await tester.pump(); // the animation starts after the first frame
    await tester.pump(const Duration(milliseconds: 150));
    expect(_opacity(tester, 'unu'), greaterThan(_opacity(tester, 'patru')));
    await tester.pumpAndSettle();
    expect(_opacity(tester, 'patru'), 1);
  });

  testWidgets('does not replay when the parent rebuilds', (tester) async {
    Widget build(int tick) => _app(
          Column(
            children: [
              FadeInSection(key: const ValueKey('a'), order: 0, child: Text('unu $tick')),
            ],
          ),
        );
    await tester.pumpWidget(build(0));
    await tester.pumpAndSettle();
    await tester.pumpWidget(build(1));
    expect(_opacity(tester, 'unu 1'), 1);
  });

  testWidgets('shows everything at once when animations are disabled', (tester) async {
    await tester.pumpWidget(
      _app(const FadeInSection(order: 4, child: Text('unu')), disableAnimations: true),
    );
    expect(_opacity(tester, 'unu'), 1);
  });
  testWidgets('waits for the page transition to finish before it starts', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const Scaffold(body: FadeInSection(order: 0, child: Text('nou'))),
              ),
            ),
            child: const Text('mergi'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('mergi'));
    await tester.pump(); // route starts
    await tester.pump(const Duration(milliseconds: 100)); // still transitioning
    expect(_opacity(tester, 'nou'), 0);

    await tester.pump(const Duration(milliseconds: 400)); // transition done
    await tester.pump(const Duration(milliseconds: 150)); // fade running
    final mid = _opacity(tester, 'nou');
    expect(mid, greaterThan(0));
    expect(mid, lessThan(1));
    await tester.pumpAndSettle();
    expect(_opacity(tester, 'nou'), 1);
  });
}
