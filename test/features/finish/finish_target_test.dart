import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/finish/controller/finish_controller.dart';
import 'package:teamxperience/features/finish/logic/finish_target.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/mission.dart';
import 'package:teamxperience/model/team.dart';

final _event = Event(
  eventId: 'e1',
  name: 'Moștenirea Cartografului',
  dateEvent: DateTime(2026, 11, 14, 10),
  missions: [for (var i = 0; i < 6; i++) Mission(id: '$i')],
);

Team _team(String name, {int progress = 6, bool finished = false}) => Team(
      name: name,
      teamMembers: '',
      captainName: '',
      phoneNumber: '',
      captainEmail: '',
      missionProgress: progress,
      hasStarted: true,
      hasFinished: finished,
    );

void main() {
  group('showFinish', () {
    test('after the last mission, when the event ended, or for a finished team', () {
      expect(showFinish(_event, _team('V'), eventEnded: false), isTrue);
      expect(showFinish(_event, _team('V', progress: 3), eventEnded: true), isTrue);
      expect(showFinish(_event, _team('V', progress: 3, finished: true), eventEnded: false), isTrue);
    });

    test('not in the middle of the game', () {
      expect(showFinish(_event, _team('V', progress: 3), eventEnded: false), isFalse);
    });
  });

  group('FinishController', () {
    late StreamController<List<Team>> teams;
    late StreamController<Team> own;
    late List<int> saved;
    late bool failSave;

    FinishController make() {
      teams = StreamController<List<Team>>();
      own = StreamController<Team>();
      saved = [];
      failSave = false;
      return FinishController(
        event: _event,
        team: _team('Vulpile'),
        teams: teams.stream,
        teamStream: own.stream,
        saveRating: (stars) async {
          saved.add(stars);
          if (failSave) throw Exception('offline');
        },
        clock: () => DateTime(2026, 11, 14, 12),
      );
    }

    test('the place appears when the teams arrive', () async {
      final c = make();
      expect(c.place, isNull);
      teams.add([_team('Bufnițele', progress: 6), _team('Vulpile', progress: 6), _team('Lupii', progress: 2)]);
      await Future<void>.delayed(Duration.zero);
      expect(c.place?.teams, 3);
      expect(c.place?.place, isNotNull);
      expect(c.ranked, hasLength(3));
      c.dispose();
    });

    test('a rating is saved, and kept here even when the save fails', () async {
      final c = make();
      await c.rate(4);
      expect(saved, [4]);
      expect(c.rating, 4);
      failSave = true;
      await c.rate(5);
      expect(c.rating, 5);
      c.dispose();
    });

    test('the share text names the place once known', () async {
      final c = make();
      expect(c.shareText, isNot(contains('locul')));
      teams.add([_team('Vulpile', progress: 6)]);
      await Future<void>.delayed(Duration.zero);
      expect(c.shareText, contains('pe locul 1 din 1'));
      c.dispose();
    });

    test('a fresher team doc replaces the one it opened with', () async {
      final c = make();
      own.add(_team('Vulpile', progress: 6, finished: true));
      await Future<void>.delayed(Duration.zero);
      expect(c.team.hasFinished, isTrue);
      c.dispose();
    });
  });
}
