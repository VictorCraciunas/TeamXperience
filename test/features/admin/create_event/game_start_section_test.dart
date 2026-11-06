import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/admin/create_event/create_event_landing/controller/create_event_controller.dart';
import 'package:teamxperience/features/admin/create_event/create_event_landing/widgets/game_start_section.dart';
import 'package:teamxperience/model/event.dart';

import '../../../ui/pump_ui.dart';

void main() {
  group('the controller', () {
    test('loads the intro fields from the event', () {
      final c = CreateEventController(Event(
        eventId: 'e1',
        introLetter: 'Dragi exploratori…',
        introSignature: 'Cartograful',
        hintsPerMission: 2,
        enterWindowMinutes: 30,
      ));
      expect(c.introLetterController.text, 'Dragi exploratori…');
      expect(c.introSignatureController.text, 'Cartograful');
      expect(c.hintsPerMissionController.text, '2');
      expect(c.enterWindowController.text, '30');
    });

    test('the end texts load and save; empty is none', () {
      final c = CreateEventController(Event(eventId: 'e1', finishTitle: 'Harta e completă', finishMessage: 'Bravo.'));
      expect(c.finishTitleController.text, 'Harta e completă');
      expect(c.finishMessageController.text, 'Bravo.');
      c
        ..finishTitleController.text = '  Gata  '
        ..finishMessageController.text = ' ';
      final e = c.buildNewEvent();
      expect(e.finishTitle, 'Gata');
      expect(e.finishMessage, isNull);
    });

    test('writes them back, trimmed', () {
      final c = CreateEventController(null)
        ..introLetterController.text = '  Dragi exploratori…  '
        ..introSignatureController.text = ' Cartograful '
        ..hintsPerMissionController.text = '0'
        ..enterWindowController.text = '90';
      final e = c.buildNewEvent();
      expect(e.introLetter, 'Dragi exploratori…');
      expect(e.introSignature, 'Cartograful');
      expect(e.hintsPerMission, 0);
      expect(e.enterWindowMinutes, 90);
    });

    test('empty or out of range gives the defaults', () {
      final c = CreateEventController(null);
      expect((c.hintsPerMissionController.text, c.enterWindowController.text), ('1', '60'));
      c
        ..hintsPerMissionController.text = ''
        ..enterWindowController.text = '5';
      final e = c.buildNewEvent();
      expect(e.introLetter, isNull);
      expect(e.hintsPerMission, 1);
      expect(e.enterWindowMinutes, 60);
      c.hintsPerMissionController.text = '9';
      expect(c.buildNewEvent().hintsPerMission, 1);
    });

    test('the checks', () {
      expect(CreateEventController.hintsProblem(''), isNull);
      expect(CreateEventController.hintsProblem('3'), isNull);
      expect(CreateEventController.hintsProblem('6'), isNotNull);
      expect(CreateEventController.enterWindowProblem('180'), isNull);
      expect(CreateEventController.enterWindowProblem('9'), isNotNull);
      expect(CreateEventController.enterWindowProblem('o oră'), isNotNull);
    });
  });

  testWidgets('the section shows the four fields', (tester) async {
    final c = CreateEventController(null);
    await pumpUi(
      tester,
      SingleChildScrollView(
        child: GameStartSection(
          letter: c.introLetterController,
          signature: c.introSignatureController,
          hintsPerMission: c.hintsPerMissionController,
          enterWindow: c.enterWindowController,
          finishTitle: c.finishTitleController,
          finishMessage: c.finishMessageController,
        ),
      ),
    );
    expect(find.text('Sfârșitul jocului'), findsOneWidget);
    expect(find.text('Titlul de final'), findsOneWidget);
    expect(find.text('Mesajul de final'), findsOneWidget);
    expect(find.text('Începutul jocului'), findsOneWidget);
    expect(find.text('Scrisoarea de început'), findsOneWidget);
    expect(find.text('Semnătura'), findsOneWidget);
    expect(find.text('Indicii pe misiune'), findsOneWidget);
    expect(find.text('Minute pentru codul de start'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Ex. Cartograful'), 'Cartograful');
    expect(c.introSignatureController.text, 'Cartograful');
  });
}
