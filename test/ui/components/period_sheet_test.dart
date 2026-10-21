import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/misc/period_selection.dart';
import 'package:teamxperience/ui/components/misc/period_sheet.dart';

import '../pump_ui.dart';

final _now = DateTime(2026, 10, 20, 12);

Finder _day(int month, int day) => find.byKey(ValueKey('period-day-2026-$month-$day'));

/// Opens the sheet from a button and records what it returns.
class _Harness {
  PeriodSelection? result;
  bool returned = false;
}

Future<_Harness> _open(
  WidgetTester tester, {
  PeriodSelection initial = const PeriodSelection(),
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
          harness.result = await showPeriodSheet(context, initial: initial, now: _now);
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
  testWidgets('shows the title, the presets and the current month', (tester) async {
    await _open(tester);
    expect(find.text('Selectează perioada'), findsOneWidget);
    expect(find.text('Luna asta'), findsOneWidget);
    expect(find.text('OCTOMBRIE 2026'), findsOneWidget);
  });

  testWidgets('the save button is disabled until a full range is chosen', (tester) async {
    await _open(tester);
    AppButtonFinder button() => AppButtonFinder(tester);
    expect(button().isEnabled, isFalse);
    await tester.tap(_day(10, 22));
    await tester.pump();
    expect(button().isEnabled, isFalse);
    await tester.tap(_day(10, 27));
    await tester.pump();
    expect(button().isEnabled, isTrue);
  });

  testWidgets('tapping two days and saving returns that range', (tester) async {
    final h = await _open(tester);
    await tester.tap(_day(10, 22));
    await tester.tap(_day(10, 27));
    await tester.pump();
    await tester.tap(find.text('Salvează perioada'));
    await tester.pumpAndSettle();
    expect(h.returned, isTrue);
    expect(h.result?.start, DateTime(2026, 10, 22));
    expect(h.result?.end, DateTime(2026, 10, 27));
  });

  testWidgets('a preset fills the range and can be saved', (tester) async {
    final h = await _open(tester);
    await tester.tap(find.text('Luna asta'));
    await tester.pump();
    await tester.tap(find.text('Salvează perioada'));
    await tester.pumpAndSettle();
    expect(h.result?.start, DateTime(2026, 10, 1));
    expect(h.result?.end, DateTime(2026, 10, 31));
  });

  testWidgets('Oricând clears an existing period', (tester) async {
    final h = await _open(
      tester,
      initial: PeriodSelection(start: DateTime(2026, 10, 20), end: DateTime(2026, 10, 30)),
    );
    expect(find.text('20 oct 2026 - 30 oct 2026'), findsOneWidget);
    await tester.tap(find.text('Oricând'));
    await tester.pump();
    await tester.tap(find.text('Salvează perioada'));
    await tester.pumpAndSettle();
    expect(h.returned, isTrue);
    expect(h.result?.isEmpty, isTrue);
  });

  testWidgets('dismissing the sheet returns null', (tester) async {
    final h = await _open(tester);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(h.returned, isTrue);
    expect(h.result, isNull);
  });

  testWidgets('fits a narrow screen at large text', (tester) async {
    await _open(tester);
    expect(tester.takeException(), isNull);
  });
}

/// Reads whether the "Salvează perioada" button can be pressed.
class AppButtonFinder {
  AppButtonFinder(this.tester);

  final WidgetTester tester;

  bool get isEnabled {
    final inkWell = find.ancestor(
      of: find.text('Salvează perioada'),
      matching: find.byType(InkWell),
    );
    return tester.widget<InkWell>(inkWell.first).onTap != null;
  }
}
