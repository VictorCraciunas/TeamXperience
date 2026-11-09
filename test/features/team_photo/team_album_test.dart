import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/finish/logic/finish_recap.dart';
import 'package:teamxperience/features/team_photo/logic/team_album.dart';
import 'package:teamxperience/model/memory.dart';
import 'package:teamxperience/model/team.dart';

Team _team({String? start, String? finish, Map<String, String> approved = const {}, Map<String, String> pending = const {}}) =>
    Team.fromMap({
      'name': 'Vulpile',
      'teamPhotos': {
        if (start != null) 'start': {'url': start},
        if (finish != null) 'finish': {'url': finish},
      },
      'photoApprovals': {
        for (final e in approved.entries) e.key: {'status': 'approved', 'url': e.value},
        for (final e in pending.entries) e.key: {'status': 'pending', 'url': e.value},
      },
    });

Memory _memory(List<String> photos) => Memory(eventId: 'e', eventName: 'Harta', photoUrls: photos);

void main() {
  group('teamAlbum', () {
    test('start, puzzle photos by mission, final, with labels', () {
      final album = teamAlbum(_team(start: 's', finish: 'f', approved: {'2_0_1': 'b', '0_1_5': 'a'}));
      expect(album.map((p) => p.url), ['s', 'a', 'b', 'f']);
      expect(album.map((p) => p.label), ['Start', 'Misiunea 1', 'Misiunea 3', 'Final']);
    });

    test('only what exists', () {
      expect(teamAlbum(_team(finish: 'f')).map((p) => p.label), ['Final']);
      expect(teamAlbum(_team()), isEmpty);
    });

    test('photos waiting for the organiser stay out', () {
      expect(teamAlbum(_team(pending: {'0_0_1': 'x'})), isEmpty);
    });

    test('the latest approved try of a puzzle', () {
      expect(teamAlbum(_team(approved: {'0_0_1': 'old', '0_0_2': 'new'})).single.url, 'new');
    });
  });

  test('approvedPhotos keeps its order', () {
    expect(approvedPhotos(_team(approved: {'2_0_1': 'b', '0_1_5': 'a', '0_0_1': 'c'})), ['c', 'a', 'b']);
  });

  group('memoryAlbum', () {
    test('the team\'s album when it has one', () async {
      final album = await memoryAlbum(_memory(['x']), (_) async => _team(start: 's'));
      expect(album.single.url, 's');
      expect(album.single.label, 'Start');
    });

    test('the team has none: the memory photos, without labels', () async {
      final album = await memoryAlbum(_memory(['x']), (_) async => _team());
      expect(album.single.url, 'x');
      expect(album.single.label, isNull);
    });

    test('the team cannot be read: the memory photos, without throwing', () async {
      final album = await memoryAlbum(_memory(['x']), (_) async => throw Exception('offline'));
      expect(album.single.url, 'x');
    });

    test('no team: the memory photos', () async {
      expect((await memoryAlbum(_memory(['x']), (_) async => null)).length, 1);
    });

    test('nothing anywhere: empty', () async {
      expect(await memoryAlbum(_memory(const []), (_) async => null), isEmpty);
    });
  });

  test('thumbnail: first photo, then the event picture, then nothing', () {
    expect(memoryThumbnail(const [AlbumPhoto('a'), AlbumPhoto('b')], 'e'), 'a');
    expect(memoryThumbnail(const [], 'e'), 'e');
    expect(memoryThumbnail(const [], null), isNull);
    expect(memoryThumbnail(const [], ''), isNull);
  });
}
