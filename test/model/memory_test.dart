import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/model/memory.dart';

void main() {
  test('a full memory', () {
    final date = DateTime(2026, 11, 14, 10);
    final memory = Memory.fromMap('e1', {
      'eventName': 'Moștenirea Cartografului',
      'date': Timestamp.fromDate(date),
      'place': 2,
      'totalTime': 108,
      'photoUrls': ['https://x/1.jpg', 'https://x/2.jpg'],
    });
    expect(memory.eventId, 'e1');
    expect(memory.eventName, 'Moștenirea Cartografului');
    expect(memory.date, date);
    expect(memory.place, 2);
    expect(memory.totalMinutes, 108);
    expect(memory.photoUrls, ['https://x/1.jpg', 'https://x/2.jpg']);
  });

  test('a memory with only a name', () {
    final memory = Memory.fromMap('e1', {'eventName': 'Joc'});
    expect((memory.date, memory.place, memory.totalMinutes), (null, null, null));
    expect(memory.photoUrls, isEmpty);
  });

  test('bad values are left out', () {
    final memory = Memory.fromMap('e1', {
      'eventName': 7,
      'date': 'ieri',
      'place': 'doi',
      'totalTime': 1.5,
      'photoUrls': ['https://x/1.jpg', 3, null],
    });
    expect(memory.eventName, '');
    expect((memory.date, memory.place, memory.totalMinutes), (null, null, null));
    expect(memory.photoUrls, ['https://x/1.jpg']);
  });

  test('a photo list that is not a list is empty', () {
    expect(Memory.fromMap('e1', {'photoUrls': 'x'}).photoUrls, isEmpty);
  });
}
