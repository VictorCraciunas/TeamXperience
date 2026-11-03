import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/event_game/logic/spaced_components.dart';

Future<List<double>> _gaps(WidgetTester tester, List<Widget> children) async {
  await tester.pumpWidget(
    MaterialApp(home: Scaffold(body: Column(children: children))),
  );
  return [
    for (final box in tester.widgetList<SizedBox>(find.byType(SizedBox)))
      if (box.height != null) box.height!,
  ];
}

Widget _box(String label) => SizedBox(key: ValueKey(label), width: 50, child: Text(label));

void main() {
  test('the usual gap is 40', () {
    expect(defaultComponentGap, 40);
  });

  testWidgets('with nothing set, every gap is 40 and there is none after the last', (tester) async {
    final children = spacedComponents([_box('a'), _box('b'), _box('c')], const [], const []);
    final gaps = await _gaps(tester, children);
    expect(gaps, [40, 40]);
  });

  testWidgets('a component can have its own gap below it', (tester) async {
    final children = spacedComponents([_box('a'), _box('b'), _box('c')], const [], [8, null, 90]);
    final gaps = await _gaps(tester, children);
    expect(gaps, [8, 40], reason: 'the gap after the last one is never drawn');
  });

  testWidgets('a gap of 0 puts components right next to each other', (tester) async {
    final children = spacedComponents([_box('a'), _box('b')], const [], [0, null]);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: Column(children: children))));
    final a = tester.getBottomLeft(find.byKey(const ValueKey('a'))).dy;
    final b = tester.getTopLeft(find.byKey(const ValueKey('b'))).dy;
    expect(b - a, 0);
  });

  testWidgets('a short list of gaps falls back to 40 for the rest', (tester) async {
    final children = spacedComponents([_box('a'), _box('b'), _box('c')], const [], [10]);
    final gaps = await _gaps(tester, children);
    expect(gaps, [10, 40]);
  });

  testWidgets('a long list of gaps is not a problem', (tester) async {
    final children = spacedComponents([_box('a'), _box('b')], const [], [5, 6, 7, 8]);
    final gaps = await _gaps(tester, children);
    expect(gaps, [5]);
  });

  testWidgets('gaps between components do not depend on the fade-in', (tester) async {
    const animation = AlwaysStoppedAnimation<double>(0.0);
    final children = spacedComponents([_box('a'), _box('b')], [animation, animation], [16, null]);
    final gaps = await _gaps(tester, children);
    expect(gaps, [16]);
  });

  testWidgets('the fade-in still applies to each component', (tester) async {
    final children = spacedComponents(
      [_box('a'), _box('b')],
      [const AlwaysStoppedAnimation<double>(0.25), const AlwaysStoppedAnimation<double>(1.0)],
      const [],
    );
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: Column(children: children))));
    final opacities = tester.widgetList<Opacity>(find.byType(Opacity)).map((o) => o.opacity).toList();
    expect(opacities, [0.25, 1.0]);
  });

  test('an empty list stays empty', () {
    expect(spacedComponents(const [], const [], const []), isEmpty);
  });
}
