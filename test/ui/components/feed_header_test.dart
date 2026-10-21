import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/misc/feed_search_bar.dart';
import 'package:teamxperience/ui/components/misc/segmented_switch.dart';

import '../pump_ui.dart';

Widget _bar({
  bool open = false,
  bool filterActive = false,
  VoidCallback? onSearch,
  VoidCallback? onFilter,
  Widget? leading,
}) {
  return FeedSearchBar(
    isSearchOpen: open,
    searchController: TextEditingController(),
    searchFocusNode: FocusNode(),
    searchHint: 'Caută...',
    hasActiveFilters: filterActive,
    filterIcon: Icons.calendar_today_outlined,
    filterLabel: 'Alege perioada',
    onToggleSearch: onSearch ?? () {},
    onFilter: onFilter ?? () {},
    leading: leading,
  );
}

void main() {
  group('SegmentedSwitch', () {
    testWidgets('shows the labels and reports a tap on the other one', (tester) async {
      int? picked;
      await pumpUi(
        tester,
        SegmentedSwitch(labels: const ['Toate', 'Înscrise'], selectedIndex: 0, onSelected: (i) => picked = i),
      );
      expect(find.text('Toate'), findsOneWidget);
      await tester.tap(find.text('Înscrise'));
      expect(picked, 1);
    });
  });

  group('FeedSearchBar', () {
    testWidgets('closed: shows the leading widget, a search button and the filter button', (tester) async {
      var searched = 0;
      var filtered = 0;
      await pumpUi(
        tester,
        _bar(leading: const Text('lead'), onSearch: () => searched++, onFilter: () => filtered++),
      );
      expect(find.text('lead'), findsOneWidget);
      await tester.tap(find.byTooltip('Caută'));
      await tester.tap(find.byTooltip('Alege perioada'));
      expect(searched, 1);
      expect(filtered, 1);
      expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget);
    });

    testWidgets('open: shows the search field instead of the leading widget', (tester) async {
      await pumpUi(tester, _bar(open: true, leading: const Text('lead')));
      expect(find.text('lead'), findsNothing);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('an active filter shows a dot on the filter button', (tester) async {
      await pumpUi(tester, _bar(filterActive: true));
      expect(find.byKey(const ValueKey('feed-icon-active-dot')), findsOneWidget);
    });

    testWidgets('fits a narrow screen at large text', (tester) async {
      await pumpUi(
        tester,
        _bar(leading: SegmentedSwitch(labels: const ['Toate', 'Înscrise'], selectedIndex: 0, onSelected: (_) {})),
        textScale: 1.5,
        width: 320,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
