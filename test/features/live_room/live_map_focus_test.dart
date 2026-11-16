import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:teamxperience/features/live_room/logic/live_map_focus.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';

Team _team(String name, {bool started = true, double lat = 45.8, double lng = 24.1}) => Team(
      name: name,
      teamMembers: '',
      captainName: '',
      phoneNumber: '',
      captainEmail: '',
      hasStarted: started,
      latitude: lat,
      longitude: lng,
    );

void main() {
  final event = Event(eventId: 'e', name: 'Harta', dateEvent: DateTime(2026, 11, 14, 12));

  group('the big map\'s arguments', () {
    test('a bare event, as Admin Home and "Hartă mare" push it, has no focus', () {
      final args = liveMapArgsOf(event);
      expect(args?.event, same(event));
      expect(args?.focusTeam, isNull);
    });

    test('the team sheet\'s "Hartă" names the team', () {
      final args = liveMapArgsOf(LiveMapArgs(event, focusTeam: 'Lupii'));
      expect(args?.event, same(event));
      expect(args?.focusTeam, 'Lupii');
    });

    test('anything else opens nothing', () {
      expect(liveMapArgsOf(null), isNull);
      expect(liveMapArgsOf('Lupii'), isNull);
    });
  });

  group('where the map centres', () {
    final teams = [_team('Vulpile', lat: 45.79, lng: 24.13), _team('Lupii', lat: 45.80, lng: 24.14), _team('Pisicile', started: false, lat: 0, lng: 0)];

    test('on the focused team\'s last position', () {
      expect(focusPointOf(TeamFocus('Lupii'), teams), const LatLng(45.80, 24.14));
    });

    test('nowhere without a focus, or for a team with no pin', () {
      expect(focusPointOf(null, teams), isNull);
      expect(focusPointOf(TeamFocus('Pisicile'), teams), isNull);
      expect(focusPointOf(TeamFocus('Nimeni'), teams), isNull);
    });

    test('each request is new, so asking for the same team again moves the map back', () {
      expect(TeamFocus('Lupii') == TeamFocus('Lupii'), isFalse);
    });
  });
}
