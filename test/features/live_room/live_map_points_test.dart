import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:teamxperience/features/live_room/logic/live_map_points.dart';
import 'package:teamxperience/service/event_service/event_route.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/mission.dart';
import 'package:teamxperience/model/team.dart';

final _now = DateTime(2026, 11, 14, 12);

Team _team({
  bool started = true,
  bool finished = false,
  double lat = 45.7,
  double lng = 24.1,
  int progress = 0,
  DateTime? startedAt,
  Map<String, DateTime>? presence,
}) =>
    Team(
      name: 'A',
      teamMembers: '',
      captainName: '',
      phoneNumber: '',
      captainEmail: '',
      hasStarted: started,
      hasFinished: finished,
      latitude: lat,
      longitude: lng,
      missionProgress: progress,
      startedAt: startedAt,
      presence: presence,
    );

PinTone _tone(Team team, {bool over = false}) => pinToneOf(team, missionCount: 6, now: _now, eventOver: over);

void main() {
  group('hasPin', () {
    test('a team that has not started has none', () => expect(hasPin(_team(started: false)), isFalse));
    test('no position yet has none', () => expect(hasPin(_team(lat: 0, lng: 0)), isFalse));
    test('in play with a position has one', () => expect(hasPin(_team()), isTrue));
    test('finished keeps it', () => expect(hasPin(_team(finished: true, progress: 6)), isTrue));
    test('a position on one axis only is still a position', () => expect(hasPin(_team(lat: 0)), isTrue));
  });

  group('pinToneOf', () {
    test('in play', () => expect(_tone(_team()), PinTone.playing));
    test('finished', () => expect(_tone(_team(finished: true, progress: 6)), PinTone.finished));
    test('stopped early', () => expect(_tone(_team(finished: true, progress: 2)), PinTone.silent));
    test('stuck', () => expect(_tone(_team(startedAt: _now.subtract(const Duration(minutes: 30)))), PinTone.stuck));

    test('quiet for more than five minutes', () {
      expect(_tone(_team(presence: {'u': _now.subtract(const Duration(minutes: 6))})), PinTone.silent);
    });

    test('stuck wins over quiet', () {
      final team = _team(
        startedAt: _now.subtract(const Duration(minutes: 30)),
        presence: {'u': _now.subtract(const Duration(minutes: 6))},
      );
      expect(_tone(team), PinTone.stuck);
    });

    test('after the end a team still out there is grey', () {
      final team = _team(
        startedAt: _now.subtract(const Duration(minutes: 30)),
        presence: {'u': _now.subtract(const Duration(minutes: 6))},
      );
      expect(_tone(team, over: true), PinTone.silent);
    });
  });

  group('routePoints', () {
    Mission mission({double? lat, double? lng}) => Mission(id: 'm', latitude: lat, longitude: lng);

    test('the start, then the missions that have a pin', () {
      final event = Event(
        eventId: 'e',
        startLatitude: 1,
        startLongitude: 2,
        missions: [mission(lat: 3, lng: 4), mission(), mission(lat: 5), mission(lat: 6, lng: 7)],
      );
      expect(routePoints(event), [const LatLng(1, 2), const LatLng(3, 4), const LatLng(6, 7)]);
    });

    test('nothing set: no points', () => expect(routePoints(Event(eventId: 'e')), isEmpty));
  });
}
