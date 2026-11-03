import 'package:teamxperience/enums/difficulty.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/mission.dart';
import 'package:teamxperience/model/puzzle.dart';

/// The event of mockup 01, for the gallery and the tests.
Event sampleEvent() => Event(
      eventId: 'sample',
      name: 'Moștenirea Cartografului',
      location: 'Sibiu',
      area: 'Orașul de Sus',
      description: 'O hartă neterminată, șase locuri din Orașul de Sus.',
      story: 'Un cartograf a lăsat o hartă neterminată ascunsă în zidurile orașului. '
          'Echipa care o completează prima moștenește secretul lui.',
      dateEvent: DateTime(2026, 11, 14, 10),
      dateStartEnrollment: DateTime(2026, 11, 1),
      dateDeadlineEnrollment: DateTime(2026, 11, 12),
      punctDeStart: 'Piața Mare',
      finishPoint: 'Turnul Sfatului',
      routeLengthKm: 4.5,
      durationMinutes: 120,
      difficulty: Difficulty.medium,
      startLatitude: 45.7971,
      startLongitude: 24.1520,
      meetingPointNote: 'Piața Mare, lângă fântână',
      whatToBring: ['Telefon încărcat', 'încălțări comode'],
      missions: [
        Mission(
          id: '0',
          title: 'Scara Pasajului',
          teaser: 'Numără treptele. Nu toate sunt la vedere.',
          isTeaserPublic: true,
          puzzles: [Puzzle(id: '0', type: PuzzleType.code)],
        ),
        Mission(
          id: '1',
          title: 'Podul Minciunilor',
          teaser: 'Cineva a mințit aici. Găsiți cine.',
          isTeaserPublic: true,
          puzzles: [Puzzle(id: '0', type: PuzzleType.imageToUpload)],
        ),
        Mission(id: '2', title: 'Turnul Sfatului', puzzles: [Puzzle(id: '0', type: PuzzleType.imageToUpload)]),
        Mission(id: '3', title: 'Casa cu ochi', puzzles: [Puzzle(id: '0', type: PuzzleType.code)]),
        Mission(id: '4', title: 'Unde dorm clopotele', puzzles: [Puzzle(id: '0', type: PuzzleType.geolocation)]),
        Mission(id: '5', title: 'Harta completă', puzzles: [Puzzle(id: '0', type: PuzzleType.code)]),
      ],
    )..nrMissions = 6;
