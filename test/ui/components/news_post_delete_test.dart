import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/news/news_post_card.dart';
import 'package:teamxperience/ui/theme/app_colors.dart';

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

  testWidgets('a small red x sits at the end of the category and date row', (tester) async {
    var deletes = 0;
    var opens = 0;
    await pumpUi(tester, _card(onDelete: () => deletes++, onTap: () => opens++));

    final x = find.byTooltip('Șterge știrea');
    expect(x, findsOneWidget);

    final category = tester.getCenter(find.text('Anunț'));
    final date = tester.getCenter(find.text('20 oct 2026'));
    final xCenter = tester.getCenter(x);
    final card = tester.getRect(find.byType(NewsPostCard));

    expect(xCenter.dy, closeTo(category.dy, 6), reason: 'same row as the category');
    expect(xCenter.dx, greaterThan(date.dx), reason: 'after the date');
    expect(xCenter.dx, greaterThan(card.right - 60), reason: 'at the end of the row');

    final icon = tester.widget<Icon>(find.descendant(of: x, matching: find.byType(Icon)));
    expect(icon.color, AppColors.light.danger);
    expect(icon.size, lessThanOrEqualTo(20), reason: 'small');

    await tester.tap(x);
    expect(deletes, 1);
    expect(opens, 0, reason: 'the x must not open the post');
  });

  testWidgets('the red x stays easy to hit', (tester) async {
    await pumpUi(tester, _card(onDelete: () {}));
    final size = tester.getSize(find.byTooltip('Șterge știrea'));
    expect(size.width, greaterThanOrEqualTo(36));
    expect(size.height, greaterThanOrEqualTo(36));
  });

  testWidgets('the tag stays in the top right of the image, away from the x', (tester) async {
    await pumpUi(tester, _card(onDelete: () {}, tag: 'Privată'));
    final tag = tester.getCenter(find.text('Privată'));
    final card = tester.getRect(find.byType(NewsPostCard));
    expect(tag.dx, greaterThan(card.center.dx));
    final x = tester.getCenter(find.byTooltip('Șterge știrea'));
    expect(tag.dy, greaterThan(x.dy), reason: 'the tag is on the image, below the row');
  });
}
