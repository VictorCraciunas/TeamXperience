import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/buttons/sticky_action_bar.dart';

import '../pump_ui.dart';

void main() {
  for (final prominent in [false, true]) {
    testWidgets('as a page\'s bottom bar it stays a bar (prominent: $prominent)', (tester) async {
      await pumpUi(
        tester,
        Scaffold(
          body: const SizedBox.expand(key: ValueKey('page')),
          bottomNavigationBar: StickyActionBar(
            title: 'ECHIPA 1',
            detail: '3 membri',
            inlineDetail: true,
            prominent: prominent,
            actionLabel: 'Echipa ta',
            onAction: () {},
          ),
        ),
      );
      expect(tester.getSize(find.byType(StickyActionBar)).height, lessThan(100));
      expect(tester.getSize(find.byKey(const ValueKey('page'))).height, greaterThan(400));
    });
  }

  testWidgets('the link sits at the right end of the bar', (tester) async {
    await pumpUi(
      tester,
      Scaffold(
        body: const SizedBox.expand(),
        bottomNavigationBar: StickyActionBar(
          title: 'ECHIPA 1',
          detail: '3 membri',
          inlineDetail: true,
          leadingIcon: Icons.check_circle_outline,
          prominent: false,
          actionLabel: 'Echipa ta',
          onAction: () {},
        ),
      ),
    );
    final bar = tester.getRect(find.byType(StickyActionBar));
    final link = tester.getRect(find.text('Echipa ta'));
    expect(bar.right - link.right, lessThanOrEqualTo(16));
  });
}
