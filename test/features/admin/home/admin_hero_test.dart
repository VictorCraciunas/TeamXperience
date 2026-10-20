import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/admin/home/logic/admin_hero.dart';
import 'package:teamxperience/model/event.dart';

final _now = DateTime(2026, 10, 20, 12);

Event _event(String id, Duration fromNow, {bool stopped = false, bool noDate = false}) => Event(
      eventId: id,
      name: id,
      dateEvent: noDate ? null : _now.add(fromNow),
      isStopped: stopped,
    );

void main() {
  test('a started event that is not over is live', () {
    final hero = resolveAdminHero(now: _now, events: [_event('a', const Duration(minutes: -30))]);
    expect(hero, isA<AdminLiveHero>());
    expect((hero as AdminLiveHero).event.eventId, 'a');
  });

  test('a stopped event is not live', () {
    final hero = resolveAdminHero(now: _now, events: [_event('a', const Duration(minutes: -30), stopped: true)]);
    expect(hero, isA<NoAdminHero>());
  });

  test('an event past 3 hours is not live', () {
    final hero = resolveAdminHero(now: _now, events: [_event('a', const Duration(hours: -4))]);
    expect(hero, isA<NoAdminHero>());
  });

  test('an event starting in 2 hours is starting soon', () {
    final hero = resolveAdminHero(now: _now, events: [_event('a', const Duration(hours: 2))]);
    expect(hero, isA<AdminSoonHero>());
    expect((hero as AdminSoonHero).untilStart, const Duration(hours: 2));
  });

  test('an event in 30 hours gives no hero', () {
    final hero = resolveAdminHero(now: _now, events: [_event('a', const Duration(hours: 30))]);
    expect(hero, isA<NoAdminHero>());
  });

  test('events without a date are ignored', () {
    final hero = resolveAdminHero(now: _now, events: [_event('a', Duration.zero, noDate: true)]);
    expect(hero, isA<NoAdminHero>());
  });

  test('with two live events the earliest start wins', () {
    final hero = resolveAdminHero(
      now: _now,
      events: [_event('late', const Duration(minutes: -10)), _event('early', const Duration(minutes: -60))],
    );
    expect((hero as AdminLiveHero).event.eventId, 'early');
  });

  test('live wins over starting soon, and the nearest soon event wins', () {
    final live = resolveAdminHero(
      now: _now,
      events: [_event('soon', const Duration(hours: 1)), _event('live', const Duration(minutes: -5))],
    );
    expect((live as AdminLiveHero).event.eventId, 'live');

    final soon = resolveAdminHero(
      now: _now,
      events: [_event('far', const Duration(hours: 10)), _event('near', const Duration(hours: 3))],
    );
    expect((soon as AdminSoonHero).event.eventId, 'near');
  });

  test('an empty list gives no hero', () {
    expect(resolveAdminHero(now: _now, events: const []), isA<NoAdminHero>());
  });
}
