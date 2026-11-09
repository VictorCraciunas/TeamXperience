import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/home/widgets/home_news_carousel.dart';
import 'package:teamxperience/model/newsCategory.dart';
import 'package:teamxperience/model/stire.dart';
import 'package:teamxperience/ui/components/misc/carousel_dots.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

import '../../ui/pump_ui.dart';

Stire _stire(String title) => Stire(id: title, title: title, publicationDate: DateTime(2026, 11, 3));

Future<void> _pump(
  WidgetTester tester,
  List<Stire> items, {
  void Function(Stire)? onOpen,
  VoidCallback? onAll,
  double width = 360,
  double textScale = 1,
  ThemeData? theme,
}) {
  return pumpUi(
    tester,
    Align(
      alignment: Alignment.topCenter,
      child: HomeNewsCarousel(items: items, onOpen: onOpen ?? (_) {}, onAll: onAll ?? () {}),
    ),
    width: width,
    textScale: textScale,
    theme: theme,
  );
}

int _active(WidgetTester tester) => tester.widget<CarouselDots>(find.byType(CarouselDots)).current;

void main() {
  testWidgets('a card per item, with the title and date, and a dot per item', (tester) async {
    await _pump(tester, [_stire('Prima'), _stire('A doua'), _stire('A treia')]);
    expect(find.text('Știri'), findsOneWidget);
    expect(find.text('Prima'), findsOneWidget);
    expect(find.text('3 nov'), findsWidgets);
    final dots = tester.widget<CarouselDots>(find.byType(CarouselDots));
    expect((dots.count, dots.current), (3, 0));
  });

  testWidgets('the next card peeks in, so it is clear there is more', (tester) async {
    await _pump(tester, [_stire('Prima'), _stire('A doua')]);
    expect(find.text('A doua'), findsOneWidget);
    expect(tester.getTopLeft(find.text('A doua')).dx, lessThan(360));
  });

  testWidgets('swiping moves the dots, all the way to the last card and back', (tester) async {
    await _pump(tester, [_stire('Prima'), _stire('A doua'), _stire('A treia')]);
    await tester.drag(find.text('Prima'), const Offset(-300, 0));
    await tester.pumpAndSettle();
    expect(_active(tester), 1);

    await tester.drag(find.text('A doua'), const Offset(-300, 0));
    await tester.pumpAndSettle();
    expect(_active(tester), 2);

    await tester.drag(find.text('A treia'), const Offset(300, 0));
    await tester.pumpAndSettle();
    expect(_active(tester), 1);
  });

  testWidgets('the cards keep the screen margin at both ends', (tester) async {
    await _pump(tester, [_stire('Prima'), _stire('A doua')]);
    final first = find.ancestor(of: find.text('Prima'), matching: find.byKey(const ValueKey('news-card'))).first;
    expect(tester.getTopLeft(first).dx, 14);

    await tester.drag(find.text('Prima'), const Offset(-300, 0));
    await tester.pumpAndSettle();
    final last = find.ancestor(of: find.text('A doua'), matching: find.byKey(const ValueKey('news-card'))).first;
    expect(tester.getTopRight(last).dx, 360 - 14);
  });

  testWidgets('tapping a card opens it, and Toate opens the list', (tester) async {
    Stire? opened;
    var all = 0;
    await _pump(tester, [_stire('Prima'), _stire('A doua')], onOpen: (s) => opened = s, onAll: () => all++);
    await tester.tap(find.text('Prima'));
    await tester.tap(find.text('Toate'));
    expect(opened?.title, 'Prima');
    expect(all, 1);
  });

  testWidgets('one item fills the width, with no dots and no swiping', (tester) async {
    await _pump(tester, [_stire('Singura')]);
    expect(find.byType(CarouselDots), findsNothing);
    expect(find.byType(PageView), findsNothing);
    final card = find.ancestor(of: find.text('Singura'), matching: find.byKey(const ValueKey('news-card'))).first;
    expect(tester.getSize(card).width, 360 - 28);
  });

  testWidgets('the category shows on the picture when there is one', (tester) async {
    final item = Stire(id: 'a', title: 'Prima', category: NewsCategory(id: 'c', name: 'Noutăți'));
    await _pump(tester, [item]);
    expect(find.text('Noutăți'), findsOneWidget);
  });

  testWidgets('no picture: a flat block with an icon, and nothing throws', (tester) async {
    await _pump(tester, [Stire(id: 'a', title: 'Fără poză'), _stire('A doua')]);
    expect(find.byKey(const ValueKey('news-no-picture')), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a long title stops at two lines', (tester) async {
    await _pump(tester, [_stire('Un titlu foarte foarte lung ' * 8), _stire('A doua')]);
    final title = tester.widget<Text>(find.textContaining('Un titlu'));
    expect(title.maxLines, 2);
    expect(tester.takeException(), isNull);
  });

  group('CarouselDots', () {
    testWidgets('says where you are to a screen reader', (tester) async {
      await pumpUi(tester, const CarouselDots(count: 3, current: 1));
      expect(find.bySemanticsLabel('2 din 3'), findsOneWidget);
    });

    testWidgets('the current dot stands out', (tester) async {
      await pumpUi(tester, const CarouselDots(count: 3, current: 1));
      expect(find.byKey(const ValueKey('dot-current')), findsOneWidget);
    });
  });

  for (final theme in [AppTheme.light, AppTheme.dark]) {
    testWidgets('fits 320 px at 1.3x text with long text (${theme.brightness.name})', (tester) async {
      final long = 'Un titlu foarte foarte lung pentru o știre din oraș ' * 3;
      await _pump(tester, [_stire(long), _stire('A doua'), _stire('A treia')], width: 320, textScale: 1.3, theme: theme);
      expect(tester.takeException(), isNull);
      await _pump(tester, [_stire(long)], width: 320, textScale: 1.3, theme: theme);
      expect(tester.takeException(), isNull);
    });
  }
}
