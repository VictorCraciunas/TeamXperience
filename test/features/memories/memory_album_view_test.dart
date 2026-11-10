import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/memories/widgets/memory_album_view.dart';
import 'package:teamxperience/features/team_photo/logic/team_album.dart';
import 'package:teamxperience/model/memory.dart';
import 'package:teamxperience/ui/components/event/event_picture.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

import '../../ui/pump_ui.dart';

final _memory = Memory(
  eventId: 'e',
  eventName: 'Moștenirea Cartografului',
  date: DateTime(2026, 11, 14, 10),
  place: 2,
  totalMinutes: 108,
);

const _album = [
  AlbumPhoto('s', label: 'Start'),
  AlbumPhoto('a', label: 'Misiunea 3'),
  AlbumPhoto('b', label: 'Misiunea 5'),
  AlbumPhoto('f', label: 'Final'),
];

void main() {
  testWidgets('the facts, and every photo with its label', (tester) async {
    await pumpUi(
      tester,
      SingleChildScrollView(child: MemoryAlbumView(memory: _memory, album: _album, teamName: 'Vulpile', onPhoto: (_) {})),
    );
    for (final text in [
      'Moștenirea Cartografului',
      'Sâm 14 nov · Echipa Vulpile',
      'Locul 2',
      'în clasament',
      '1:48',
      'timp total',
      'Pozele voastre',
      'Start',
      'Misiunea 3',
      'Misiunea 5',
      'Final',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
  });

  testWidgets('Start and Final are large, puzzle photos side by side', (tester) async {
    await pumpUi(
      tester,
      SingleChildScrollView(child: MemoryAlbumView(memory: _memory, album: _album, onPhoto: (_) {})),
    );
    final start = tester.getSize(find.byKey(const ValueKey('album-s')));
    final puzzle = tester.getSize(find.byKey(const ValueKey('album-a')));
    expect(start.height, greaterThan(puzzle.height));
    expect(start.width, greaterThan(puzzle.width));
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('album-a'))).dy,
      tester.getTopLeft(find.byKey(const ValueKey('album-b'))).dy,
    );
  });

  testWidgets('tapping a photo opens it', (tester) async {
    AlbumPhoto? opened;
    await pumpUi(
      tester,
      SingleChildScrollView(child: MemoryAlbumView(memory: _memory, album: _album, onPhoto: (p) => opened = p)),
    );
    await tester.tap(find.byKey(const ValueKey('album-a')));
    expect(opened?.url, 'a');
  });

  testWidgets('without photos: the event picture and a line', (tester) async {
    await pumpUi(tester, SingleChildScrollView(child: MemoryAlbumView(memory: _memory, album: const [], onPhoto: (_) {})));
    expect(find.byType(EventPicture), findsOneWidget);
    expect(find.text('Nicio poză la acest joc.'), findsOneWidget);
    expect(find.text('Pozele voastre'), findsNothing);
  });

  testWidgets('the team\'s part is left out when unknown', (tester) async {
    await pumpUi(tester, SingleChildScrollView(child: MemoryAlbumView(memory: _memory, album: const [], onPhoto: (_) {})));
    expect(find.text('Sâm 14 nov'), findsOneWidget);
  });

  testWidgets('the event link shows only when the event is loaded', (tester) async {
    var taps = 0;
    await pumpUi(tester, SingleChildScrollView(child: MemoryAlbumView(memory: _memory, album: const [], onPhoto: (_) {})));
    expect(find.text('Vezi pagina evenimentului'), findsNothing);

    await pumpUi(
      tester,
      SingleChildScrollView(child: MemoryAlbumView(memory: _memory, album: const [], onPhoto: (_) {}, onEvent: () => taps++)),
    );
    await tester.tap(find.text('Vezi pagina evenimentului'));
    expect(taps, 1);
  });

  testWidgets('a memory with no place or time leaves those out', (tester) async {
    await pumpUi(
      tester,
      SingleChildScrollView(child: MemoryAlbumView(memory: const Memory(eventId: 'e', eventName: 'Harta'), album: const [], onPhoto: (_) {})),
    );
    expect(find.text('în clasament'), findsNothing);
    expect(find.text('timp total'), findsNothing);
  });

  for (final theme in [AppTheme.light, AppTheme.dark]) {
    testWidgets('fits 320 px at 1.3x text (${theme.brightness.name})', (tester) async {
      await pumpUi(
        tester,
        SingleChildScrollView(
          child: MemoryAlbumView(
            memory: Memory(eventId: 'e', eventName: 'Moștenirea Cartografului din Cetatea de Pe Deal', date: DateTime(2026, 11, 14), place: 12, totalMinutes: 179),
            album: _album,
            teamName: 'Cei Mai Rapizi Exploratori Din Tot Orașul',
            onPhoto: (_) {},
            onEvent: () {},
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
