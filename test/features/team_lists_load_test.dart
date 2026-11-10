import 'package:teamxperience/features/home/logic/live_texts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/event_game/logic/route_texts.dart';
import 'package:teamxperience/features/event_see_registered_teams/event_registered_teams_controller.dart';
import 'package:teamxperience/features/team_chats/controller/team_chats_controller.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';

Team _team(String name) => Team(name: name, teamMembers: '', captainName: '', phoneNumber: '', captainEmail: '');

void main() {
  final event = Event(eventId: 'e');

  group('EventRegisteredTeamsController', () {
    test('loads the teams', () async {
      final c = EventRegisteredTeamsController(event, load: (_) async => [_team('A')]);
      expect(c.isLoading, isTrue);
      await c.loadTeams();
      expect((c.isLoading, c.failed, c.teams.length), (false, false, 1));
    });

    test('a failed read stops the spinner and says so; a retry recovers', () async {
      var fail = true;
      final c = EventRegisteredTeamsController(event, load: (_) async {
        if (fail) throw Exception('offline');
        return [_team('A')];
      });
      await c.loadTeams();
      expect((c.isLoading, c.failed), (false, true));
      fail = false;
      await c.loadTeams();
      expect((c.isLoading, c.failed, c.teams.length), (false, false, 1));
    });
  });

  group('TeamChatsController', () {
    test('loads only when asked', () async {
      var loads = 0;
      final c = TeamChatsController(event: event, load: (_) async {
        loads++;
        return [_team('A')];
      });
      expect(loads, 0);
      expect(c.isLoading, isTrue);
      await c.loadTeams();
      expect((loads, c.isLoading, c.failed, c.teams.length), (1, false, false, 1));
    });

    test('a failed read stops the spinner and says so', () async {
      final c = TeamChatsController(event: event, load: (_) async => throw Exception('offline'));
      await c.loadTeams();
      expect((c.isLoading, c.failed), (false, true));
    });
  });

  group('previewLeftClock', () {
    final now = DateTime(2026, 11, 8, 12);

    test('the event duration from when the walk-through began, whatever the event date', () {
      final event = Event(eventId: 'e', durationMinutes: 90);
      expect(previewLeftClock(event, now.subtract(const Duration(minutes: 10)), now), liveClock(const Duration(minutes: 80)));
    });

    test('no start: the whole duration', () {
      expect(previewLeftClock(Event(eventId: 'e', durationMinutes: 90), null, now), liveClock(const Duration(minutes: 90)));
      expect(previewLeftClock(Event(eventId: 'e'), null, now), liveClock(Event.defaultPlayTime));
    });
  });
}
