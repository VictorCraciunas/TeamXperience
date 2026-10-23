import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/misc/feed_search_bar.dart';

import '../pump_ui.dart';

/// Hosts the bar and lets the test open and close the search like a screen does.
class _Host extends StatefulWidget {
  const _Host();

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  bool open = false;
  final controller = TextEditingController();
  final focus = FocusNode();

  @override
  void dispose() {
    controller.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FeedSearchBar(
      isSearchOpen: open,
      searchController: controller,
      searchFocusNode: focus,
      searchHint: 'Caută...',
      hasActiveFilters: false,
      onToggleSearch: () => setState(() => open = !open),
      onFilter: () {},
      leading: Container(key: const ValueKey('lead'), color: Colors.red, height: 48),
    );
  }
}

double _fieldWidth(WidgetTester tester) => tester.getSize(find.byKey(const ValueKey('feed-search-field'))).width;
double _leadWidth(WidgetTester tester) => tester.getSize(find.byKey(const ValueKey('feed-search-leading'))).width;

void main() {
  const rowWidth = 360.0;

  Future<void> pumpHost(WidgetTester tester) => pumpUi(tester, const _Host(), width: rowWidth);

  testWidgets('closed: the search is a round button the size of the filter button', (tester) async {
    await pumpHost(tester);
    expect(_fieldWidth(tester), 48);
    expect(_leadWidth(tester), greaterThan(150));
  });

  testWidgets('opening grows the field step by step until it fills the row', (tester) async {
    await pumpHost(tester);
    await tester.tap(find.byTooltip('Caută'));
    await tester.pump(); // starts the animation

    final widths = <double>[];
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 60));
      widths.add(_fieldWidth(tester));
    }
    // Still growing in the middle of the animation, never jumping to the end.
    expect(widths.first, greaterThan(48));
    expect(widths.first, lessThan(rowWidth - 56));
    for (var i = 1; i < widths.length; i++) {
      expect(widths[i], greaterThanOrEqualTo(widths[i - 1]));
    }

    await tester.pumpAndSettle();
    expect(_fieldWidth(tester), rowWidth - 56);
  });

  testWidgets('opening squeezes the leading widget down to nothing', (tester) async {
    await pumpHost(tester);
    final before = _leadWidth(tester);
    await tester.tap(find.byTooltip('Caută'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final mid = _leadWidth(tester);
    expect(mid, lessThan(before));
    await tester.pumpAndSettle();
    expect(_leadWidth(tester), 0);
  });

  testWidgets('closing shrinks the field back step by step', (tester) async {
    await pumpHost(tester);
    await tester.tap(find.byTooltip('Caută'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Închide căutarea'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final mid = _fieldWidth(tester);
    expect(mid, lessThan(rowWidth - 56));
    expect(mid, greaterThan(48));

    await tester.pumpAndSettle();
    expect(_fieldWidth(tester), 48);
    expect(_leadWidth(tester), greaterThan(150));
  });

  testWidgets('typing works once open and the field takes focus', (tester) async {
    await pumpHost(tester);
    await tester.tap(find.byTooltip('Caută'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'sibiu');
    expect(find.text('sibiu'), findsOneWidget);
  });

  testWidgets('the animation does not overflow on a narrow screen', (tester) async {
    await pumpUi(tester, const _Host(), width: 280, textScale: 1.5);
    await tester.tap(find.byTooltip('Caută'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
