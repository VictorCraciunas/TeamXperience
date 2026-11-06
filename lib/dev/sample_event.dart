import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/enums/difficulty.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/event_defaults.dart';
import 'package:teamxperience/model/photo_detail.dart';
import 'package:teamxperience/enums/photo_approval_status.dart';
import 'package:teamxperience/model/mission.dart';
import 'package:teamxperience/model/puzzle.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/model/team_member.dart';

/// A code puzzle built in the mockups' parchment colours, the way an
/// organiser would: the game frame takes its look from pieces like these.
List<Component> parchmentCodePieces(String question) => [
      Component(type: ComponentType.text, text: question, textColor: '#3B2A1A', fontFamily: 'Gelasio', fontSize: 16),
      Component(
        type: ComponentType.code,
        codeLength: 4,
        inputType: 'Separated',
        inputBackgroundColor: '#FBF4E4',
        colorBorderInput: '#8A3B12',
        glowColor: '#B8862B',
      ),
      Component(type: ComponentType.button, buttonLabel: 'Verifică', buttonColor: '#8A3B12', buttonTextColor: '#FBF4E4'),
    ];

/// A question in the parchment voice, as mockup 07 writes it.
Component parchmentQuestion(String text) =>
    Component(type: ComponentType.text, text: text, textColor: '#3B2A1A', fontFamily: 'Gelasio', fontSize: 14);

/// The event of mockup 01, for the gallery and the tests. Its puzzles are in
/// the parchment colours of mockups 05 to 08.
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
      startCode: 'HARTA',
      introLetter: 'Dragi exploratori, harta mea a rămas neterminată. Am ascuns bucățile ei în șase '
          'locuri pe care doar un ochi atent le găsește. Prima vă așteaptă unde treptele nu se termină niciodată.',
      introSignature: 'Cartograful',
      hintsPerMission: 1,
      finishTitle: 'Harta e completă',
      finishMessage: 'Vulpile au moștenit secretul cartografului.',
      defaults: const EventDefaults(backgroundColor: '#EADBC0', textColor: '#3B2A1A', accentColor: '#8A3B12', fontFamily: 'Gelasio'),
      missions: [
        Mission(
          id: '0',
          title: 'Scara Pasajului',
          teaser: 'Numără treptele. Nu toate sunt la vedere.',
          isTeaserPublic: true,
          puzzles: [
            Puzzle(id: '0', type: PuzzleType.code, components: parchmentCodePieces('Câte trepte are scara?')),
          ],
        ),
        Mission(
          id: '1',
          title: 'Podul Minciunilor',
          teaser: 'Cineva a mințit aici. Găsiți cine.',
          isTeaserPublic: true,
          puzzles: [Puzzle(id: '0', type: PuzzleType.imageToUpload)],
        ),
        Mission(
          id: '2',
          title: 'Turnul Sfatului',
          puzzles: [
            Puzzle(
              id: '0',
              type: PuzzleType.imageToUpload,
              components: [
                parchmentQuestion('Faceți o poză cu toată echipa sub ceasul turnului. Toți trebuie să arătați spre ora exactă.'),
              ],
            ),
          ],
        ),
        Mission(
          id: '3',
          title: 'Casa cu ochi',
          puzzles: [
            Puzzle(
              id: '0',
              type: PuzzleType.code,
              code: '1859',
              maxAttempts: 3,
              wrongAnswerMessage: 'Nu e anul ăsta. Uită-te mai sus pe ușă.',
              indiciu: 'Anul e sculptat în piatră, deasupra ferestrei din mijloc.',
              components: parchmentCodePieces('Acoperișul are ochi care nu dorm. Scrie anul de pe ușă.'),
            ),
          ],
        ),
        Mission(
          id: '4',
          title: 'Unde dorm clopotele',
          puzzles: [
            Puzzle(
              id: '0',
              type: PuzzleType.geolocation,
              latitude: 45.7978,
              longitude: 24.1525,
              radiusMeters: 30,
              indiciu: 'Clopotele dorm în turnul bisericii evanghelice.',
              components: [
                parchmentQuestion('Mergeți acolo unde clopotele se odihnesc când nu bat. Harta vă arată doar cât de aproape sunteți.'),
              ],
            ),
          ],
        ),
        Mission(id: '5', title: 'Harta completă', puzzles: [Puzzle(id: '0', type: PuzzleType.code)]),
      ],
    )..nrMissions = 6;

/// A code puzzle built in black and green, for showing that the game frame
/// dresses itself from whatever the organiser chose.
List<Component> neonCodePieces(String question) => [
      Component(type: ComponentType.text, text: question, textColor: '#B8FFC8', fontFamily: 'Monospace', fontSize: 15),
      Component(
        type: ComponentType.code,
        codeLength: 4,
        inputType: 'Separated',
        inputBackgroundColor: '#111A11',
        colorBorderInput: '#33FF66',
        glowColor: '#00CC44',
      ),
      Component(type: ComponentType.button, buttonLabel: 'Trimite', buttonColor: '#33FF66', buttonTextColor: '#0A0F0A'),
    ];

/// The sample event with its code puzzles rebuilt in black and green.
Event neonSampleEvent() {
  final event = sampleEvent()
    ..defaults = const EventDefaults(backgroundColor: '#0A0F0A', textColor: '#B8FFC8', accentColor: '#33FF66', fontFamily: 'Monospace');
  for (final mission in event.missions) {
    for (final puzzle in mission.puzzles) {
      if (puzzle.type == PuzzleType.code) {
        puzzle.components = neonCodePieces('Introdu codul de acces.');
      } else {
        for (final piece in puzzle.components) {
          piece
            ..textColor = '#B8FFC8'
            ..fontFamily = 'Monospace';
        }
      }
    }
  }
  return event;
}

/// The other events of mockup 03 ("Deschise pentru înscriere").
List<Event> sampleOpenEvents() => [
      Event(
        eventId: 'cerber',
        name: 'Protocolul Cerber',
        location: 'Sibiu',
        dateEvent: DateTime(2026, 11, 21, 10),
        dateStartEnrollment: DateTime(2026, 11, 1),
        dateDeadlineEnrollment: DateTime(2026, 11, 19),
        routeLengthKm: 3.2,
        durationMinutes: 90,
        difficulty: Difficulty.hard,
        maxTeams: 12,
        startLatitude: 45.7983,
        startLongitude: 24.1517,
      ),
      Event(
        eventId: 'muzee',
        name: 'Noaptea muzeelor',
        location: 'Sibiu',
        dateEvent: DateTime(2026, 12, 5, 19),
        dateStartEnrollment: DateTime(2026, 11, 1),
        dateDeadlineEnrollment: DateTime(2026, 12, 3),
        routeLengthKm: 2.8,
        durationMinutes: 120,
        difficulty: Difficulty.easy,
      ),
    ];

/// The players of mockup 02's team Vulpile.
const sampleMembers = [
  TeamMember(uid: 'vc', displayName: 'Victor Crăciunaș', initials: 'VC'),
  TeamMember(uid: 'am', displayName: 'Ana Moldovan', initials: 'AM'),
  TeamMember(uid: 'ir', displayName: 'Ioana Rus', initials: 'IR'),
  TeamMember(uid: 'dp', displayName: 'Dan Popa', initials: 'DP'),
];

/// Mockup 08's Vulpile at the finish: 1:48 played, 4,7 km walked, the
/// fastest mission the second (6 min), two hints, six approved photos. With
/// [solved] below 6, the event ended first.
Team sampleFinishedTeam({int solved = 6}) {
  final start = DateTime(2026, 11, 14, 10, 2);
  final minutes = [20, 26, 44, 63, 84, 108];
  return Team(
    name: 'Vulpile',
    teamMembers: '',
    captainName: 'Victor',
    phoneNumber: '',
    captainEmail: '',
    members: sampleMembers,
    hasStarted: true,
    hasFinished: true,
    missionProgress: solved,
    startedAt: start,
    finishedAt: solved >= 6 ? start.add(const Duration(minutes: 108)) : null,
    walked: {'vc': 4712, 'am': 4630},
    missionCompletedAt: {for (var i = 0; i < solved; i++) i: start.add(Duration(minutes: minutes[i]))},
    hintsUsed: {'1_0': true, '3_0': true},
    photoDetails: {
      for (var i = 0; i < 6; i++)
        '${i}_0_1': PhotoDetail(status: PhotoApprovalStatus.approved, url: 'https://example.com/poza$i.jpg'),
    },
  );
}

/// Mockup 02's team before the game: four of four, registered.
Team sampleTeam() => Team(
      name: 'Vulpile',
      teamMembers: '',
      captainName: 'Victor',
      phoneNumber: '',
      captainEmail: '',
      numberOfMembers: 4,
      members: sampleMembers,
    );

/// Mockup 02's live board at [now]: Bufnițele on mission 5, Vulpile (three
/// players here, a mission solved 6 min ago) and Lupii de Cetate on 4.
List<Team> sampleLiveTeams(DateTime now) {
  Team team(String name, int progress, DateTime last, {List<TeamMember> members = const [], Map<String, DateTime>? presence}) => Team(
        name: name,
        teamMembers: '',
        captainName: '',
        phoneNumber: '',
        captainEmail: '',
        numberOfMembers: 4,
        missionProgress: progress,
        hasStarted: true,
        members: members,
        presence: presence,
        missionCompletedAt: {progress - 1: last},
      );
  return [
    team('Bufnițele', 4, now.subtract(const Duration(minutes: 3))),
    team(
      'Vulpile',
      3,
      now.subtract(const Duration(minutes: 6)),
      members: sampleMembers,
      presence: {for (final m in sampleMembers.take(3)) m.uid: now.subtract(const Duration(seconds: 40))},
    ),
    team('Lupii de Cetate', 3, now.subtract(const Duration(minutes: 2))),
  ];
}
