import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/news/news_post_card.dart';

import '../pump_ui.dart';

NewsPostCard _card({VoidCallback? onDelete, VoidCallback? onTap, String? tag}) {
  return NewsPostCard(
    title: 'Rezultatele ediției',
    preview: 'Echipa Vulturii a câștigat.',
    categoryLabel: 'Anunț',
    dateLabel: '20 oct 2026',
    tag: tag,
    onTap: onTap ?? () {},
    onShare: () {},
    onDelete: onDelete,
  );
}

void main() {
  testWidgets('players see no delete button', (tester) async {
    await pumpUi(tester, _card());
    expect(find.byTooltip('Șterge știrea'), findsNothing);
  });

  testWidgets('a small x sits in the top right of the image and reports taps', (tester) async {
    var deletes = 0;
    var opens = 0;
    await pumpUi(tester, _card(onDelete: () => deletes++, onTap: () => opens++));

    final x = find.byTooltip('Șterge știrea');
    expect(x, findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);

    final card = tester.getRect(find.byType(NewsPostCard));
    final center = tester.getCenter(x);
    expect(center.dx, greaterThan(card.center.dx), reason: 'right half');
    expect(center.dy, lessThan(card.top + 140), reason: 'near the top of the card');

    await tester.tap(x);
    expect(deletes, 1);
    expect(opens, 0, reason: 'the x must not open the post');
  });

  testWidgets('the delete button is at least 40 px so it can be hit', (tester) async {
    await pumpUi(tester, _card(onDelete: () {}));
    final size = tester.getSize(find.byTooltip('Șterge știrea'));
    expect(size.width, greaterThanOrEqualTo(40));
    expect(size.height, greaterThanOrEqualTo(40));
  });

  testWidgets('the tag moves to the left so it does not sit under the x', (tester) async {
    await pumpUi(tester, _card(onDelete: () {}, tag: 'Privată'));
    final tag = tester.getCenter(find.text('Privată'));
    final x = tester.getCenter(find.byTooltip('Șterge știrea'));
    expect(tag.dx, lessThan(x.dx));
  });
}
