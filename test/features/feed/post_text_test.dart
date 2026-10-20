import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/feed/logic/post_text.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/stire.dart';

void main() {
  final event = Event(
    eventId: 'e1',
    name: 'Xtreme Challenge',
    location: 'Sibiu, zona centrală',
    dateEvent: DateTime(2026, 10, 24, 14),
    lungimeTraseu: '4 km',
  );

  test('the poster date is day and short month', () {
    expect(eventPosterDate(event), '24 OCT');
  });

  test('details join the day, time and route', () {
    final details = eventPostDetails(event);
    expect(details, contains('14:00'));
    expect(details, contains('4 km'));
  });

  test('details leave out an empty route', () {
    final bare = Event(eventId: 'e2', name: 'x', dateEvent: DateTime(2026, 10, 24, 14));
    expect(eventPostDetails(bare), isNot(contains('km')));
    expect(eventPostDetails(bare), isNot(endsWith('· ')));
  });

  test('event share text names the event, place and date', () {
    final text = eventShareText(event);
    expect(text, contains('Xtreme Challenge'));
    expect(text, contains('Sibiu, zona centrală'));
    expect(text, contains('24'));
  });

  test('a news preview is trimmed to one clean line', () {
    final stire = Stire(title: 'T', description: 'Prima linie.\n\nA doua linie   cu spații.');
    expect(newsPreview(stire), 'Prima linie. A doua linie cu spații.');
    expect(newsPreview(Stire(title: 'T')), '');
  });

  test('news share text has the title and the preview', () {
    final stire = Stire(title: 'Rezultate', description: 'Vulturii au câștigat.');
    expect(newsShareText(stire), contains('Rezultate'));
    expect(newsShareText(stire), contains('Vulturii au câștigat.'));
  });
}
