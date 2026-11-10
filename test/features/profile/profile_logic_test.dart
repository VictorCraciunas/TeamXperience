import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/home/logic/home_texts.dart';
import 'package:teamxperience/features/profile/logic/badge_catalog.dart';
import 'package:teamxperience/features/profile/logic/profile_texts.dart';
import 'package:teamxperience/model/memory.dart';

void main() {
  test('memoryLine uses the album count when given', () {
    const memory = Memory(eventId: 'e', eventName: 'Joc', place: 2, totalMinutes: 108, photoUrls: ['a']);
    expect(memoryLine(memory, photoCount: 3), 'Locul 2 · 1:48 · 3 poze');
    expect(memoryLine(memory, photoCount: 0), 'Locul 2 · 1:48');
    expect(memoryLine(memory), 'Locul 2 · 1:48 · 1 poză');
  });

  group('levelInfo', () {
    test('the start', () {
      final info = levelInfo(0);
      expect((info.name, info.nextAt, info.nextName), ('Începător', 500, 'Explorator'));
      expect((info.progress, info.share), (0, 0));
    });

    test('just under a level', () {
      final info = levelInfo(499);
      expect(info.name, 'Începător');
      expect(info.progress, closeTo(0.998, 0.001));
      expect(info.share, closeTo(0.998, 0.001));
    });

    test('exactly on a level', () {
      final info = levelInfo(500);
      expect(info.name, 'Explorator');
      expect((info.progress, info.share), (0, 0.5));
      expect(levelInfo(1000).name, 'Cartograf');
    });

    test('the mockup\'s 640 XP: progress through the level and the share of the next', () {
      final info = levelInfo(640);
      expect((info.name, info.nextAt, info.nextName), ('Explorator', 1000, 'Cartograf'));
      expect(info.progress, closeTo(0.28, 0.0001));
      expect(info.share, closeTo(0.64, 0.0001));
    });

    test('last step before the top, and the top', () {
      expect(levelInfo(2499).name, 'Cartograf');
      for (final xp in [2500, 3100]) {
        final info = levelInfo(xp);
        expect((info.name, info.nextAt, info.nextName, info.progress, info.share), ('Legendă', null, null, 1, 1));
      }
    });

    test('negative XP counts as zero; both numbers always stay within 0 to 1', () {
      expect(levelInfo(-40).name, 'Începător');
      for (final xp in [-40, 0, 1, 499, 500, 999, 1000, 2499, 2500, 99999]) {
        final info = levelInfo(xp);
        expect(info.progress, inInclusiveRange(0, 1), reason: '$xp');
        expect(info.share, inInclusiveRange(0, 1), reason: '$xp');
      }
    });

    test('agrees with the Home greeting\'s level', () {
      for (final xp in [0, 499, 500, 640, 1000, 2500]) {
        expect(levelInfo(xp).name, levelFor(xp).name);
        expect(levelInfo(xp).progress, levelFor(xp).progress);
      }
    });
  });

  group('level lines', () {
    test('before the top', () {
      expect(levelLine(levelInfo(640)), 'Explorator · 640 / 1000 XP');
      expect(nextLevelLine(levelInfo(640)), 'Următorul: Cartograf');
      expect(levelLine(levelInfo(0)), 'Începător · 0 / 500 XP');
    });

    test('at the top', () {
      expect(levelLine(levelInfo(3100)), 'Legendă · 3100 XP');
      expect(nextLevelLine(levelInfo(3100)), 'Nivel maxim');
    });
  });

  test('which user document to follow: the signed-in account first, never an empty id', () {
    expect(profileDocId('abc', 'xyz'), 'abc');
    expect(profileDocId(null, 'xyz'), 'xyz');
    expect(profileDocId('', 'xyz'), 'xyz');
    expect(profileDocId(null, ''), isNull);
    expect(profileDocId('', ''), isNull);
  });

  test('the theme\'s name', () {
    expect(themeLabel(ThemeMode.system), 'Sistem');
    expect(themeLabel(ThemeMode.light), 'Luminos');
    expect(themeLabel(ThemeMode.dark), 'Întunecat');
  });

  test('initials', () {
    expect(initialsOf('Victor Crăciunaș'), 'VC');
    expect(initialsOf('Ana'), 'A');
    expect(initialsOf('  '), '');
    expect(initialsOf('ana maria popescu'), 'AM');
    expect(initialsOf('😀 Ion'), '😀I', reason: 'an emoji is not cut in half');
  });

  test('stat labels agree with their number', () {
    expect(statLabel('games', 1), 'joc');
    expect(statLabel('games', 3), 'jocuri');
    expect(statLabel('games', 0), 'jocuri');
    expect(statLabel('missions', 1), 'misiune');
    expect(statLabel('missions', 17), 'misiuni');
    expect(statLabel('podiums', 1), 'podium');
    expect(statLabel('podiums', 2), 'podiumuri');
  });

  group('memoryLine', () {
    Memory memory({int? place, int? minutes, int photos = 0}) => Memory(
          eventId: 'e1',
          eventName: 'Joc',
          place: place,
          totalMinutes: minutes,
          photoUrls: [for (var i = 0; i < photos; i++) 'https://x/$i.jpg'],
        );

    test('the mockup\'s line', () {
      expect(memoryLine(memory(place: 2, minutes: 108, photos: 6)), 'Locul 2 · 1:48 · 6 poze');
    });

    test('leaves out what is not known', () {
      expect(memoryLine(memory(minutes: 108, photos: 6)), '1:48 · 6 poze');
      expect(memoryLine(memory(place: 2, photos: 6)), 'Locul 2 · 6 poze');
      expect(memoryLine(memory(place: 2, minutes: 108)), 'Locul 2 · 1:48');
      expect(memoryLine(memory()), '');
    });

    test('one photo', () {
      expect(memoryLine(memory(photos: 1)), '1 poză');
    });

    test('minutes under an hour', () {
      expect(memoryLine(memory(minutes: 45)), '0:45');
    });
  });

  group('badge catalogue', () {
    test('twelve badges with unique ids, titles and rules', () {
      expect(badgeCatalog, hasLength(12));
      expect({for (final b in badgeCatalog) b.id}, hasLength(12));
      for (final b in badgeCatalog) {
        expect(b.title.trim(), isNotEmpty, reason: b.id);
        expect(b.rule.trim(), isNotEmpty, reason: b.id);
      }
    });

    test('the mockup\'s four are there', () {
      final titles = {for (final b in badgeCatalog) b.title};
      expect(titles, containsAll(['Primii 10 km', 'Fără indicii', 'Joc nocturn', 'Câștigă un joc']));
    });

    test('nothing earned: the first four, locked', () {
      final row = badgesRow(const []);
      expect([for (final b in row) b.id], [for (final b in badgeCatalog.take(4)) b.id]);
    });

    test('earned first (in catalogue order), then locked ones', () {
      final row = badgesRow(const ['noHints', 'km10']);
      expect([for (final b in row) b.id].take(2), ['km10', 'noHints']);
      expect(row, hasLength(4));
      expect(row.skip(2).every((b) => b.id != 'km10' && b.id != 'noHints'), isTrue);
    });

    test('more than four earned: the first four earned', () {
      final ids = [for (final b in badgeCatalog.skip(2).take(6)) b.id];
      final row = badgesRow(ids);
      expect([for (final b in row) b.id], ids.take(4).toList());
    });

    test('unknown ids are ignored and not counted', () {
      expect(earnedCount(const ['km10', 'zzz']), 1);
      expect(earnedCount(const []), 0);
      expect(badgesRow(const ['zzz']).map((b) => b.id), [for (final b in badgeCatalog.take(4)) b.id]);
    });
  });
}
