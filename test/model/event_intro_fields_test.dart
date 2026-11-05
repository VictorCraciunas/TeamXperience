import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/event_look.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/ui/theme/app_colors.dart';
import 'package:teamxperience/ui/theme/event_palette.dart';

void main() {
  test('the intro fields, hints, enter window and look round-trip', () {
    final event = Event(
      eventId: 'e1',
      introLetter: 'Dragi exploratori…',
      introSignature: 'Cartograful',
      hintsPerMission: 2,
      enterWindowMinutes: 30,
      look: EventLook.parchment,
    );
    final json = event.toJson();
    expect(json['look'], 'parchment');
    final back = Event.fromMap({...json, 'dateEvent': null});
    expect(back.introLetter, 'Dragi exploratori…');
    expect(back.introSignature, 'Cartograful');
    expect(back.hintsPerMission, 2);
    expect(back.enterWindowMinutes, 30);
    expect(back.look, EventLook.parchment);
  });

  test('old events get one hint, a 60-minute window and the app look', () {
    final event = Event.fromMap({'eventId': 'e1'});
    expect(event.introLetter, isNull);
    expect(event.hintsPerMission, 1);
    expect(event.enterWindowMinutes, 60);
    expect(event.look, EventLook.app);
  });

  test('an unknown look reads as the app look', () {
    expect(Event.fromMap({'eventId': 'e1', 'look': 'neon'}).look, EventLook.app);
  });

  test('the enter window is the event\'s own', () {
    expect(Event(eventId: 'e1', enterWindowMinutes: 30).enterWindow, const Duration(minutes: 30));
    expect(Event(eventId: 'e1').enterWindow, const Duration(minutes: 60));
  });

  group('Team.startedAt', () {
    Map<String, dynamic> base() => {'name': 'Vulpile'};

    test('read from a Timestamp', () {
      final at = DateTime(2026, 11, 14, 10, 12);
      expect(Team.fromMap({...base(), 'startedAt': Timestamp.fromDate(at)}).startedAt, at);
    });

    test('null while pending or missing', () {
      expect(Team.fromMap({...base(), 'startedAt': null}).startedAt, isNull);
      expect(Team.fromMap(base()).startedAt, isNull);
    });

    test('never written by toJson', () {
      final team = Team.fromMap({...base(), 'startedAt': Timestamp.now()});
      expect(team.toJson().containsKey('startedAt'), isFalse);
    });
  });

  test('paletteFor picks the look', () {
    expect(paletteFor(EventLook.parchment, AppColors.light), EventPalette.parchment);
    expect(paletteFor(EventLook.app, AppColors.light), EventPalette.fromApp(AppColors.light));
  });
}
