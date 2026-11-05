import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/dev/sample_event.dart';
import 'package:teamxperience/features/home/logic/home_hero.dart';
import 'package:teamxperience/features/home/logic/live_watch.dart';

void main() {
  final event = sampleEvent();
  final live = LiveHero(event, sampleTeam());

  test('a live game on a visible Home is watched', () {
    expect(liveEventToWatch(live, visible: true)?.eventId, event.eventId);
  });

  test('nothing while Home is hidden (another tab, or a page over the shell)', () {
    expect(liveEventToWatch(live, visible: false), isNull);
  });

  test('nothing without a live game', () {
    expect(liveEventToWatch(UpcomingHero(event, const Duration(days: 1)), visible: true), isNull);
    expect(liveEventToWatch(const NoHero(), visible: true), isNull);
  });
}
