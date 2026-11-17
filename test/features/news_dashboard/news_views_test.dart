import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/backend/repo/news_category_repo.dart';
import 'package:teamxperience/enums/stire_type.dart';
import 'package:teamxperience/features/news_dashboard/controller/stiri_dashboard_controller.dart';
import 'package:teamxperience/features/news_dashboard/widgets/admin_news_view.dart';
import 'package:teamxperience/features/news_dashboard/widgets/news_featured_card.dart';
import 'package:teamxperience/features/news_dashboard/widgets/player_news_view.dart';
import 'package:teamxperience/model/newsCategory.dart';
import 'package:teamxperience/model/stire.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

class _FakeCategoryRepo extends Fake implements NewsCategoryRepo {
  @override
  Future<List<NewsCategory>> getAllCategories() async => [
    NewsCategory(id: '1', name: 'Evenimente'),
    NewsCategory(id: '2', name: 'Rezultate'),
    NewsCategory(id: '3', name: 'Fără știri'),
  ];
}

final _now = DateTime(2026, 11, 17);

Stire _s(String id, String title, String category, int day, {StireType type = StireType.PUBLICA}) => Stire(
  id: id,
  title: title,
  description: 'Douăsprezece echipe, șase misiuni și un traseu de 4,5 km prin centrul vechi al orașului.',
  category: NewsCategory(name: category),
  type: type,
  publicationDate: DateTime(2026, 11, day),
);

final _news = [
  _s('a', 'Vulpile câștigă Moștenirea Cartografului după o seară foarte lungă', 'Rezultate', 16),
  _s('b', 'Noaptea Breslelor: înscrieri deschise pentru toate echipele din oraș', 'Evenimente', 14),
  _s('c', 'Instrucțiuni pentru echipele înscrise', 'Evenimente', 12, type: StireType.PRIVATA),
  _s('d', 'Sezonul de iarnă: clasamentul echipelor', 'Rezultate', 10),
];

Future<void> _loadPoppins() async {
  for (final file in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    final loader = FontLoader('Poppins')..addFont(rootBundle.load('assets/fonts/Poppins-$file.ttf'));
    await loader.load();
  }
}

Future<StiriDashboardController> _controller() async {
  final c = StiriDashboardController(categoryRepo: _FakeCategoryRepo());
  await c.loadCategories();
  return c;
}

Future<void> _pump(WidgetTester tester, Widget Function(StiriDashboardController) view, {
  double textScale = 1,
  Size size = const Size(390, 844),
  ThemeData? theme,
  required StiriDashboardController controller,
}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: theme ?? AppTheme.light,
      builder: (context, app) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
        child: app ?? const SizedBox.shrink(),
      ),
      home: Scaffold(body: ListenableBuilder(listenable: controller, builder: (_, __) => view(controller))),
    ),
  );
  await tester.pump();
}

PlayerNewsView _player(StiriDashboardController c, {void Function(Stire)? onOpen}) => PlayerNewsView(
  controller: c,
  news: _news,
  now: _now,
  onOpen: onOpen ?? (_) {},
);

void main() {
  setUpAll(_loadPoppins);

  group('player', () {
    testWidgets('fits a small phone at text size 2.0', (tester) async {
      final c = await _controller();
      await _pump(tester, _player, controller: c, textScale: 2, size: const Size(320, 640));
      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(ListView), const Offset(0, -2000));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('the newest is featured with its reading time; chips filter by category', (tester) async {
      final c = await _controller();
      Stire? opened;
      await _pump(tester, (c) => _player(c, onOpen: (s) => opened = s), controller: c);

      final featured = find.byType(NewsFeaturedCard);
      expect(find.descendant(of: featured, matching: find.text(_news.first.title ?? '')), findsOneWidget);
      expect(find.text('16 nov · 1 min de citit'), findsOneWidget);
      expect(find.text('Evenimente · Privată'), findsOneWidget);
      // A saved category with no news gets no chip.
      expect(find.text('Fără știri'), findsNothing);

      await tester.tap(find.text('Evenimente').first);
      await tester.pump();
      expect(find.descendant(of: find.byType(NewsFeaturedCard), matching: find.text(_news[1].title ?? '')), findsOneWidget);
      expect(find.text(_news.first.title ?? ''), findsNothing);

      await tester.tap(find.byType(NewsFeaturedCard));
      expect(opened?.id, 'b');
    });

    testWidgets('no search or period buttons, as in the design', (tester) async {
      final c = await _controller();
      await _pump(tester, _player, controller: c);
      expect(find.byTooltip('Caută'), findsNothing);
      expect(find.byTooltip('Alege perioada'), findsNothing);
    });

    testWidgets('a back arrow only when the page was pushed', (tester) async {
      final c = await _controller();
      await _pump(tester, _player, controller: c);
      expect(find.byTooltip('Înapoi'), findsNothing);

      final nav = tester.state<NavigatorState>(find.byType(Navigator));
      nav.push(MaterialPageRoute<void>(builder: (_) => Scaffold(body: _player(c))));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Înapoi'), findsOneWidget);
    });
  });

  group('organiser', () {
    AdminNewsView admin(
      StiriDashboardController c, {
      void Function(Stire)? onEdit,
      void Function(Stire)? onDelete,
      VoidCallback? onCreate,
      VoidCallback? onCategories,
    }) => AdminNewsView(
      controller: c,
      news: _news,
      now: _now,
      onOpen: (_) {},
      onEdit: onEdit ?? (_) {},
      onDelete: onDelete ?? (_) {},
      onCreate: onCreate ?? () {},
      onCategories: onCategories ?? () {},
    );

    for (final (name, theme) in [('light', AppTheme.light), ('dark', AppTheme.dark)]) {
      testWidgets('fits a small phone at text size 2.0 with edit and delete on every row ($name)', (tester) async {
        final c = await _controller();
        await _pump(tester, admin, controller: c, textScale: 2, size: const Size(320, 640), theme: theme);
        expect(tester.takeException(), isNull);
        expect(find.byTooltip('Editează știrea'), findsWidgets);
        expect(find.byTooltip('Șterge știrea'), findsWidgets);
        expect(tester.getSize(find.byTooltip('Șterge știrea').first), const Size(44, 44));
        await tester.drag(find.byType(ListView), const Offset(0, -2000));
        await tester.pump();
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('no search or filter buttons, as in the design', (tester) async {
      final c = await _controller();
      await _pump(tester, admin, controller: c);
      expect(find.byTooltip('Caută'), findsNothing);
      expect(find.byTooltip('Filtrează'), findsNothing);
    });

    testWidgets('counts, type chips, edit, delete (trash and long press), new news and categories', (tester) async {
      final c = await _controller();
      final edited = <String?>[];
      final deleted = <String?>[];
      var created = 0;
      var categories = 0;
      await _pump(
        tester,
        (c) => admin(
          c,
          onEdit: (s) => edited.add(s.id),
          onDelete: (s) => deleted.add(s.id),
          onCreate: () => created++,
          onCategories: () => categories++,
        ),
        controller: c,
      );

      expect(find.text('4 știri · 3 categorii'), findsOneWidget);
      expect(find.text('Toate · 4'), findsOneWidget);
      expect(find.text('Publice · 3'), findsOneWidget);
      expect(find.text('Private · 1'), findsOneWidget);
      expect(find.text('Privată'), findsOneWidget);
      expect(find.text('Rezultate · 16 nov'), findsOneWidget);

      await tester.tap(find.text('Private · 1'));
      await tester.pump();
      expect(find.byTooltip('Editează știrea'), findsOneWidget);

      await tester.tap(find.byTooltip('Editează știrea'));
      expect(edited, ['c']);

      await tester.tap(find.byTooltip('Șterge știrea'));
      expect(deleted, ['c']);

      await tester.longPress(find.text(_news[2].title ?? ''));
      expect(deleted, ['c', 'c']);

      await tester.tap(find.text('Știre nouă'));
      await tester.tap(find.text('Categorii'));
      expect(created, 1);
      expect(categories, 1);
    });
  });
}
