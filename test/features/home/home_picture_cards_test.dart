import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/dev/sample_event.dart';
import 'package:teamxperience/features/home/widgets/events_grid_section.dart';
import 'package:teamxperience/features/home/widgets/finished_card.dart';
import 'package:teamxperience/features/home/widgets/greeting_stats.dart';
import 'package:teamxperience/features/home/widgets/home_memory_card.dart';
import 'package:teamxperience/features/home/widgets/home_news_card.dart';
import 'package:teamxperience/features/home/widgets/home_season_card.dart';
import 'package:teamxperience/features/home/widgets/how_it_works_sheet.dart';
import 'package:teamxperience/features/home/widgets/new_player_greeting.dart';
import 'package:teamxperience/features/home/widgets/next_game_card.dart';
import 'package:teamxperience/features/home/widgets/nothing_open_banner.dart';
import 'package:teamxperience/features/home/widgets/recommended_card.dart';
import 'package:teamxperience/features/team_photo/logic/team_album.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/memory.dart';
import 'package:teamxperience/model/season_standing.dart';
import 'package:teamxperience/model/stire.dart';
import 'package:teamxperience/ui/components/event/event_grid_card.dart';
import 'package:teamxperience/ui/components/event/event_picture.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

import '../../ui/pump_ui.dart';

final _memory = Memory(eventId: 'e', eventName: 'Comoara Bastionului', place: 2, totalMinutes: 108);
const _standing = SeasonStanding(crewId: 'c', crewName: 'Vulpile', points: 135, games: 2);

void main() {
  testWidgets('no picture: the fill shows and nothing throws', (tester) async {
    await pumpUi(tester, const EventPicture(url: null, height: 100));
    await pumpUi(tester, const EventPicture(url: '', height: 100, topLeft: Text('sus')));
    expect(find.text('sus'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('RecommendedCard: badge, name, day line, button', (tester) async {
    var taps = 0;
    await pumpUi(tester, RecommendedCard(event: sampleEvent(), onRegister: () => taps++));
    expect(find.text('Recomandat pentru tine'), findsOneWidget);
    expect(find.text('Moștenirea Cartografului'), findsOneWidget);
    expect(find.byType(EventPicture), findsOneWidget);
    await tester.tap(find.text('Înscrie-ți echipa'));
    expect(taps, 1);
  });

  testWidgets('NextGameCard: a picture, and the countdown and preparation stay', (tester) async {
    await pumpUi(
      tester,
      NextGameCard(event: sampleEvent(), left: const Duration(days: 4), now: DateTime(2026, 11, 10), team: sampleTeam(), onTap: () {}),
    );
    expect(find.byType(EventPicture), findsOneWidget);
    expect(find.text('Următorul tău joc'), findsOneWidget);
    expect(find.text('Pregătirea echipei Vulpile'), findsOneWidget);
    expect(find.text('zile'), findsOneWidget);
  });

  testWidgets('FinishedCard says when results come', (tester) async {
    var taps = 0;
    await pumpUi(tester, FinishedCard(event: sampleEvent(), onOpen: () => taps++));
    expect(find.text('Ați terminat'), findsOneWidget);
    expect(find.text('Rezultatele, kilometrii și XP-ul apar când se încheie evenimentul.'), findsOneWidget);
    await tester.tap(find.text('Vezi clasamentul'));
    expect(taps, 1);
  });

  testWidgets('NothingOpenBanner says so', (tester) async {
    await pumpUi(tester, const NothingOpenBanner());
    expect(find.text('Niciun joc deschis acum'), findsOneWidget);
    expect(find.text('Jocurile noi apar aici imediat ce se deschid înscrierile.'), findsOneWidget);
  });

  group('EventsGridSection', () {
    testWidgets('a card per event, the link and a tap', (tester) async {
      Event? opened;
      var all = 0;
      await pumpUi(
        tester,
        EventsGridSection(
          title: 'Evenimente noi',
          link: 'Vezi toate',
          onLink: () => all++,
          events: sampleOpenEvents(),
          onTap: (e) => opened = e,
        ),
      );
      expect(find.byType(EventGridCard), findsNWidgets(sampleOpenEvents().length));
      await tester.tap(find.text('Protocolul Cerber'));
      await tester.tap(find.text('Vezi toate'));
      expect(opened?.eventId, 'cerber');
      expect(all, 1);
    });

    testWidgets('nothing without events', (tester) async {
      await pumpUi(tester, EventsGridSection(title: 'Evenimente noi', events: const [], onTap: (_) {}));
      expect(find.text('Evenimente noi'), findsNothing);
    });
  });

  group('HomeMemoryCard', () {
    testWidgets('large: the strip and Vezi pozele', (tester) async {
      var opens = 0;
      await pumpUi(
        tester,
        HomeMemoryCard(
          memory: _memory,
          album: const [AlbumPhoto('a', label: 'Start'), AlbumPhoto('b', label: 'Final')],
          large: true,
          onOpen: () => opens++,
          onAll: () {},
        ),
      );
      expect(find.text('Start'), findsOneWidget);
      expect(find.text('Locul 2 · 1:48 · 2 poze'), findsOneWidget);
      await tester.tap(find.text('Vezi pozele'));
      expect(opens, 1);
    });

    testWidgets('large without photos: no strip and no button', (tester) async {
      await pumpUi(tester, HomeMemoryCard(memory: _memory, album: const [], large: true, onOpen: () {}, onAll: () {}));
      expect(find.text('Vezi pozele'), findsNothing);
      expect(find.text('Comoara Bastionului'), findsOneWidget);
    });

    testWidgets('small: a row that opens, and Toate', (tester) async {
      var opens = 0;
      var all = 0;
      await pumpUi(
        tester,
        HomeMemoryCard(memory: _memory, album: const [AlbumPhoto('a')], large: false, onOpen: () => opens++, onAll: () => all++),
      );
      expect(find.text('Vezi pozele'), findsNothing);
      await tester.tap(find.text('Comoara Bastionului'));
      await tester.tap(find.text('Toate'));
      expect((opens, all), (1, 1));
    });

    testWidgets('no photos and no event picture: the icon', (tester) async {
      await pumpUi(tester, HomeMemoryCard(memory: _memory, album: const [], large: false, onOpen: () {}, onAll: () {}));
      expect(find.byIcon(TablerIcons.map_2), findsOneWidget);
    });
  });

  testWidgets('HomeSeasonCard: place, crew and line', (tester) async {
    var taps = 0;
    await pumpUi(tester, HomeSeasonCard(seasonName: 'Toamna 2026', place: 3, standing: _standing, onOpen: () => taps++));
    expect(find.text('Sezonul tău'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Toamna 2026 · 135 p · 2 jocuri'), findsOneWidget);
    await tester.tap(find.text('Clasament'));
    expect(taps, 1);
  });

  testWidgets('HomeNewsCard: title, and opening', (tester) async {
    var opens = 0;
    var all = 0;
    await pumpUi(
      tester,
      HomeNewsCard(
        stire: Stire(id: 's', title: 'Sezonul de iarnă', publicationDate: DateTime(2026, 11, 3)),
        onOpen: () => opens++,
        onAll: () => all++,
      ),
    );
    expect(find.text('3 nov'), findsOneWidget);
    await tester.tap(find.text('Sezonul de iarnă'));
    await tester.tap(find.text('Toate'));
    expect((opens, all), (1, 1));
  });

  testWidgets('a new player gets the line and the link, which opens the steps', (tester) async {
    await pumpUi(
      tester,
      Builder(builder: (context) => NewPlayerGreeting(firstName: 'Ana', onHow: () => showHowItWorksSheet(context))),
    );
    expect(find.text('Salut, Ana'), findsOneWidget);
    expect(find.text('Mergeți prin oraș, rezolvați indicii, descoperiți povestea.'), findsOneWidget);
    await tester.tap(find.text('Cum funcționează'));
    await tester.pumpAndSettle();
    for (final line in ['Înscrie-ți echipa', 'Primești codul de start', 'Rezolvați misiunile prin oraș']) {
      expect(find.text(line), findsOneWidget);
    }
  });

  testWidgets('one game says "joc"', (tester) async {
    await pumpUi(tester, const GreetingStats(firstName: 'Ana', games: 1, distanceMeters: 0, xp: 350));
    expect(find.text('joc'), findsOneWidget);
    expect(find.text('jocuri'), findsNothing);
  });

  for (final theme in [AppTheme.light, AppTheme.dark]) {
    testWidgets('every new card fits 320 px at 1.3x text with long names (${theme.brightness.name})', (tester) async {
      final long = sampleEvent()
        ..name = 'Moștenirea Cartografului din Cetatea de Pe Deal a Sibiului'
        ..punctDeStart = 'Piața Mare, lângă Turnul Sfatului';
      final longMemory = Memory(eventId: 'e', eventName: long.name ?? '', place: 12, totalMinutes: 179);
      await pumpUi(
        tester,
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NewPlayerGreeting(firstName: 'Victor-Alexandru-Constantin', onHow: () {}),
              RecommendedCard(event: long, onRegister: () {}),
              NextGameCard(event: long, left: const Duration(days: 4), now: DateTime(2026, 11, 10), team: sampleTeam(), onTap: () {}),
              FinishedCard(event: long, onOpen: () {}),
              const NothingOpenBanner(),
              EventsGridSection(title: 'Evenimente noi', link: 'Vezi toate', onLink: () {}, events: [long, long, long], onTap: (_) {}),
              HomeMemoryCard(
                memory: longMemory,
                album: const [AlbumPhoto('a', label: 'Misiunea 12'), AlbumPhoto('b', label: 'Misiunea 13'), AlbumPhoto('c', label: 'Final')],
                large: true,
                onOpen: () {},
                onAll: () {},
              ),
              HomeMemoryCard(memory: longMemory, album: const [], large: false, onOpen: () {}, onAll: () {}),
              HomeSeasonCard(seasonName: 'Primăvara 2027', place: 10, standing: const SeasonStanding(crewId: 'c', crewName: 'Cei Mai Rapizi Exploratori Din Tot Orașul', points: 1350, games: 12), onOpen: () {}),
              HomeNewsCard(stire: Stire(id: 's', title: long.name, publicationDate: DateTime(2026, 11, 3)), onOpen: () {}, onAll: () {}),
            ],
          ),
        ),
        width: 320,
        textScale: 1.3,
        theme: theme,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
