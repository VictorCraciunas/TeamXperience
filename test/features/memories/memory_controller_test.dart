import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/memories/controller/memories_controller.dart';
import 'package:teamxperience/features/memories/controller/memory_controller.dart';
import 'package:teamxperience/model/memory.dart';
import 'package:teamxperience/model/team.dart';

const _memory = Memory(eventId: 'e', eventName: 'Harta', photoUrls: ['stored']);

void main() {
  group('MemoryController', () {
    test('loads the album and the team name', () async {
      final c = MemoryController(
        memory: _memory,
        findTeam: (_) async => Team.fromMap({'name': 'Vulpile', 'teamPhotos': {'start': {'url': 's'}}}),
      );
      expect(c.loading, isTrue);
      await c.load();
      expect(c.loading, isFalse);
      expect(c.album.single.url, 's');
      expect(c.teamName, 'Vulpile');
    });

    test('stops loading even when the team cannot be read', () async {
      final c = MemoryController(memory: _memory, findTeam: (_) async => throw Exception('offline'));
      await c.load();
      expect(c.loading, isFalse);
      expect(c.album.single.url, 'stored');
      expect(c.teamName, isNull);
    });

    test('closing during the read does not throw', () async {
      final c = MemoryController(memory: _memory, findTeam: (_) async => null);
      final loading = c.load();
      c.dispose();
      await loading;
    });
  });

  group('MemoriesController', () {
    test('gives the memories it streams', () async {
      final c = MemoriesController(stream: Stream.value(const [_memory]));
      await Future<void>.delayed(Duration.zero);
      expect(c.loading, isFalse);
      expect(c.memories.single.eventName, 'Harta');
      c.dispose();
    });

    test('says when they cannot be read', () async {
      final c = MemoriesController(stream: Stream.error(Exception('denied')));
      await Future<void>.delayed(Duration.zero);
      expect(c.failed, isTrue);
      expect(c.loading, isFalse);
      c.dispose();
    });
  });
}
