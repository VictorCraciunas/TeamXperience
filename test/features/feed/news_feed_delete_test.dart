import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/news_dashboard/widgets/news_feed.dart';
import 'package:teamxperience/model/stire.dart';

import '../../ui/pump_ui.dart';

void _tall(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

final _news = [
  Stire(id: '1', title: 'Prima', description: 'Text.'),
  Stire(id: '2', title: 'A doua', description: 'Alt text.'),
];

void main() {
  testWidgets('without onDelete (players) no post has an x', (tester) async {
    _tall(tester);
    await pumpUi(
      tester,
      SizedBox(height: 2400, child: NewsFeed(news: _news, onTap: (_) {}, onShare: (_) {})),
    );
    expect(find.byTooltip('Șterge știrea'), findsNothing);
  });

  testWidgets('with onDelete (admins) every post has an x that reports its news', (tester) async {
    _tall(tester);
    final deleted = <String?>[];
    await pumpUi(
      tester,
      SizedBox(
        height: 2400,
        child: NewsFeed(
          news: _news,
          onTap: (_) {},
          onShare: (_) {},
          onDelete: (s) => deleted.add(s.id),
        ),
      ),
    );
    expect(find.byTooltip('Șterge știrea'), findsNWidgets(2));
    await tester.tap(find.byTooltip('Șterge știrea').last);
    expect(deleted, ['2']);
  });
}
