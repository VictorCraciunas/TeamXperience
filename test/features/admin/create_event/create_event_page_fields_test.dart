import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/difficulty.dart';
import 'package:teamxperience/features/admin/create_event/create_event_landing/controller/create_event_controller.dart';
import 'package:teamxperience/model/event.dart';

Event _full() => Event(
      eventId: 'e1',
      area: 'Orașul de Sus',
      finishPoint: 'Turnul Sfatului',
      routeLengthKm: 4.5,
      durationMinutes: 120,
      difficulty: Difficulty.medium,
      teamSizeMin: 3,
      teamSizeMax: 5,
      maxTeams: 14,
      startLatitude: 45.7971,
      startLongitude: 24.152,
      meetingPointNote: 'Piața Mare, lângă fântână',
      arriveMinutesBefore: 20,
      whatToBring: ['Telefon încărcat', 'încălțări comode'],
      story: 'Un cartograf a lăsat o hartă.',
      organiserName: 'Asociația Sibiu',
    );

void main() {
  test('an event with every page field loads into the form', () {
    final c = CreateEventController(_full());
    expect(c.areaController.text, 'Orașul de Sus');
    expect(c.finishPointController.text, 'Turnul Sfatului');
    expect(c.routeKmController.text, '4,5');
    expect(c.durationController.text, '120');
    expect(c.difficulty, Difficulty.medium);
    expect(c.teamSizeMinController.text, '3');
    expect(c.teamSizeMaxController.text, '5');
    expect(c.maxTeamsController.text, '14');
    expect(c.startPinController.text, '45.7971, 24.1520');
    expect(c.meetingNoteController.text, 'Piața Mare, lângă fântână');
    expect(c.arriveBeforeController.text, '20');
    expect(c.whatToBringController.text, 'Telefon încărcat\nîncălțări comode');
    expect(c.storyController.text, 'Un cartograf a lăsat o hartă.');
    expect(c.organiserController.text, 'Asociația Sibiu');
  });

  test('the form gives the same values back', () {
    final e = CreateEventController(_full()).buildNewEvent();
    expect(e.area, 'Orașul de Sus');
    expect(e.finishPoint, 'Turnul Sfatului');
    expect(e.routeLengthKm, 4.5);
    expect(e.durationMinutes, 120);
    expect(e.difficulty, Difficulty.medium);
    expect((e.teamSizeMin, e.teamSizeMax, e.maxTeams), (3, 5, 14));
    expect((e.startLatitude, e.startLongitude), (45.7971, 24.152));
    expect(e.meetingPointNote, 'Piața Mare, lângă fântână');
    expect(e.arriveMinutesBefore, 20);
    expect(e.whatToBring, ['Telefon încărcat', 'încălțări comode']);
    expect(e.story, 'Un cartograf a lăsat o hartă.');
    expect(e.organiserName, 'Asociația Sibiu');
  });

  test('the old text fields are still written for the screens that read them', () {
    final e = CreateEventController(_full()).buildNewEvent();
    expect((e.lungimeTraseu, e.durata, e.dificultate), ('4,5 km', '2 h', 'Medie'));
  });

  test('an old event fills the new fields from its text', () {
    final c = CreateEventController(Event(eventId: 'o', lungimeTraseu: '4.5 km', durata: '2 ore', dificultate: 'Medie'));
    expect(c.routeKmController.text, '4,5');
    expect(c.durationController.text, '120');
    expect(c.difficulty, Difficulty.medium);
  });

  test('a comma in the km field is read as a decimal point', () {
    final c = CreateEventController(null)..routeKmController.text = '4,5';
    expect(c.buildNewEvent().routeLengthKm, 4.5);
  });

  test('empty fields give null, or the defaults for team size and arrive-before', () {
    final c = CreateEventController(null);
    expect((c.teamSizeMinController.text, c.teamSizeMaxController.text, c.arriveBeforeController.text), ('2', '6', '15'));
    c
      ..teamSizeMinController.text = ''
      ..teamSizeMaxController.text = 'x'
      ..arriveBeforeController.text = '';
    final e = c.buildNewEvent();
    expect((e.teamSizeMin, e.teamSizeMax, e.arriveMinutesBefore), (2, 6, 15));
    expect(e.routeLengthKm, isNull);
    expect(e.durationMinutes, isNull);
    expect(e.maxTeams, isNull);
    expect(e.startLatitude, isNull);
    expect(e.area, isNull);
    expect(e.whatToBring, isEmpty);
    expect((e.lungimeTraseu, e.durata, e.dificultate), ('', '', ''));
  });

  test('blank lines in what to bring are dropped', () {
    final c = CreateEventController(null)..whatToBringController.text = ' Telefon \n\n apă ';
    expect(c.buildNewEvent().whatToBring, ['Telefon', 'apă']);
  });

  test('the start pin field is checked', () {
    expect(CreateEventController.startPinProblem(''), isNull);
    expect(CreateEventController.startPinProblem('45.79, 24.15'), isNull);
    expect(CreateEventController.startPinProblem('Piața Mare'), 'Coordonate greșite');
  });

  test('old text the form cannot read is kept when the field stays empty', () {
    final old = Event(eventId: 'o', lungimeTraseu: 'tot centrul', durata: 'o după-amiază', dificultate: 'pentru toți');
    final saved = CreateEventController(old).applyToOriginal();
    expect((saved.lungimeTraseu, saved.durata, saved.dificultate), ('tot centrul', 'o după-amiază', 'pentru toți'));
  });
}
