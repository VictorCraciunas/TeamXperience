import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/misc/filter_sheet.dart';
import 'package:teamxperience/ui/components/misc/period_selection.dart';

import '../pump_ui.dart';

final _now = DateTime(2026, 10, 20, 12);

const _groups = [
  FilterGroup(
    id: 'type',
    title: 'Tip',
    options: [FilterOption('public', 'Publice'), FilterOption('private', 'Private')],
  ),
  FilterGroup(
    id: 'status',
    title: 'Stare',
    options: [FilterOption('upcoming', 'Viitoare'), FilterOption('past', 'Trecute')],
  ),
];

class _Harness {
  FilterSheetResult? result;
  bool returned = false;
}

Future<_Harness> _open(
  WidgetTester tester, {
  PeriodSelection period = const PeriodSelection(),
  Map<String, String> selected = const {},
}) async {
  tester.view.physicalSize = const Size(400, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final harness = _Harness();
  await pumpUi(
    tester,
    Builder(
      builder: (context) => TextButton(
        onPressed: () async {
          harness.result = await showFilterSheet(
            context,
            groups: _groups,
            period: period,
            selected: selected,
            now: _now,
          );
          harness.returned = true;
        },
        child: const Text('deschide'),
      ),
    ),
  );
  await tester.tap(find.text('deschide'));
  await tester.pumpAndSettle();
  return harness;
}

void main() {
  testWidgets('shows the title, the period choices and every group', (tester) async {
    await _open(tester);
    expect(find.text('Filtre'), findsOneWidget);
    expect(find.text('Perioadă'), findsOneWidget);
    expect(find.text('Luna asta'), findsOneWidget);
    expect(find.text('Personalizat…'), findsOneWidget);
    expect(find.text('Tip'), findsOneWidget);
    expect(find.text('Publice'), findsOneWidget);
    expect(find.text('Stare'), findsOneWidget);
    expect(find.text('Trecute'), findsOneWidget);
    expect(find.text('Toate'), findsNWidgets(2)); // one per group
  });

  testWidgets('applying with nothing chosen returns an empty result', (tester) async {
    final h = await _open(tester);
    await tester.tap(find.text('Aplică'));
    await tester.pumpAndSettle();
    expect(h.returned, isTrue);
    expect(h.result?.period.isEmpty, isTrue);
    expect(h.result?.selected, isEmpty);
  });

  testWidgets('several options and a period can be combined', (tester) async {
    final h = await _open(tester);
    await tester.tap(find.text('Private'));
    await tester.tap(find.text('Trecute'));
    await tester.tap(find.text('Luna asta'));
    await tester.pump();
    await tester.tap(find.text('Aplică'));
    await tester.pumpAndSettle();
    expect(h.result?.selected, {'type': 'private', 'status': 'past'});
    expect(h.result?.period.start, DateTime(2026, 10, 1));
    expect(h.result?.period.end, DateTime(2026, 10, 31));
  });

  testWidgets('choosing Toate again clears that group only', (tester) async {
    final h = await _open(tester, selected: {'type': 'private', 'status': 'past'});
    await tester.tap(find.text('Toate').first);
    await tester.pump();
    await tester.tap(find.text('Aplică'));
    await tester.pumpAndSettle();
    expect(h.result?.selected, {'status': 'past'});
  });

  testWidgets('Șterge filtrele resets everything but keeps the sheet open', (tester) async {
    final h = await _open(
      tester,
      period: PeriodSelection(start: DateTime(2026, 10, 1), end: DateTime(2026, 10, 31)),
      selected: {'type': 'public'},
    );
    await tester.tap(find.text('Șterge filtrele'));
    await tester.pump();
    expect(h.returned, isFalse);
    await tester.tap(find.text('Aplică'));
    await tester.pumpAndSettle();
    expect(h.result?.period.isEmpty, isTrue);
    expect(h.result?.selected, isEmpty);
  });

  testWidgets('Personalizat… opens the calendar sheet and keeps the chosen range', (tester) async {
    final h = await _open(tester);
    await tester.tap(find.text('Personalizat…'));
    await tester.pumpAndSettle();
    expect(find.text('Selectează perioada'), findsOneWidget);
    // The presets exist in both sheets; the calendar sheet is on top (last).
    await tester.tap(find.text('Luna asta').last);
    await tester.pump();
    await tester.tap(find.text('Salvează perioada'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aplică'));
    await tester.pumpAndSettle();
    expect(h.result?.period.start, DateTime(2026, 10, 1));
  });

  testWidgets('dismissing the sheet returns null', (tester) async {
    final h = await _open(tester);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(h.returned, isTrue);
    expect(h.result, isNull);
  });
}
