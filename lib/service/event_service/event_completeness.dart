import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/mission.dart';
import 'package:teamxperience/model/puzzle.dart';

/// What can be missing from a puzzle. The hint is optional and not checked.
enum PuzzleIssue {
  noType('lipsește tipul'),
  noAnswer('lipsește răspunsul'),
  noLocation('lipsește locația'),
  noComponents('nu are nimic pe ecran');

  const PuzzleIssue(this.label);

  final String label;
}

List<PuzzleIssue> puzzleIssues(Puzzle puzzle) {
  final issues = <PuzzleIssue>[];
  final type = puzzle.type;

  if (type == null) {
    issues.add(PuzzleIssue.noType);
  } else if (type == PuzzleType.code) {
    if ((puzzle.code ?? '').trim().isEmpty) issues.add(PuzzleIssue.noAnswer);
  } else if (type == PuzzleType.geolocation) {
    if (!_validCoordinates(puzzle.latitude, puzzle.longitude)) {
      issues.add(PuzzleIssue.noLocation);
    }
  }

  if (puzzle.components.isEmpty) issues.add(PuzzleIssue.noComponents);
  return issues;
}

bool _validCoordinates(double? lat, double? lng) {
  if (lat == null || lng == null) return false;
  return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
}

/// One thing to fix in a mission, worded for the mission card.
class MissionProblem {
  const MissionProblem(this.text, {this.puzzleIndex});

  /// For example `Puzzle 2: lipsește răspunsul`.
  final String text;

  /// The puzzle it is about, or null when it is about the mission itself.
  final int? puzzleIndex;
}

List<MissionProblem> missionProblems(Mission mission) {
  final problems = <MissionProblem>[
    if (_blank(mission.title)) const MissionProblem('Nu are titlu'),
  ];
  if (mission.puzzles.isEmpty) {
    return [...problems, const MissionProblem('Nu are puzzle-uri')];
  }

  for (var i = 0; i < mission.puzzles.length; i++) {
    for (final issue in puzzleIssues(mission.puzzles[i])) {
      problems.add(MissionProblem('Puzzle ${i + 1}: ${issue.label}', puzzleIndex: i));
    }
  }
  return problems;
}

bool isMissionComplete(Mission mission) => missionProblems(mission).isEmpty;

/// What can be missing from the event's own details (not its missions).
enum EventIssue {
  noName('Lipsește numele evenimentului'),
  noDescription('Lipsește descrierea'),
  noLocation('Lipsește locația'),
  noStartPoint('Lipsește punctul de start'),
  noDate('Lipsește data evenimentului'),
  noEnrollmentDates('Lipsesc datele de înscriere'),
  enrollmentOrder('Înscrierile se deschid după ce se închid'),
  enrollmentAfterEvent('Înscrierile trebuie să se închidă înainte de eveniment'),
  noType('Lipsește tipul evenimentului'),
  noStartCode('Lipsește codul de start'),
  noRoute('Lipsește lungimea traseului'),
  noDuration('Lipsește durata'),
  noDifficulty('Lipsește dificultatea'),
  noStartPin('Lipsește locul de start pe hartă'),
  noFinishPoint('Lipsește punctul de final'),
  noMissions('Evenimentul nu are misiuni');

  const EventIssue(this.label);

  final String label;
}

bool _blank(String? value) => (value ?? '').trim().isEmpty;

/// Images are optional; everything the form used to require is checked.
List<EventIssue> eventIssues(Event event) {
  final issues = <EventIssue>[];

  if (_blank(event.name)) issues.add(EventIssue.noName);
  if (_blank(event.description)) issues.add(EventIssue.noDescription);
  if (_blank(event.location)) issues.add(EventIssue.noLocation);
  if (_blank(event.punctDeStart)) issues.add(EventIssue.noStartPoint);

  final day = event.dateEvent;
  final opens = event.dateStartEnrollment;
  final closes = event.dateDeadlineEnrollment;

  if (day == null) issues.add(EventIssue.noDate);
  if (opens == null || closes == null) {
    issues.add(EventIssue.noEnrollmentDates);
  } else {
    if (opens.isAfter(closes)) {
      issues.add(EventIssue.enrollmentOrder);
    } else if (day != null && closes.isAfter(day)) {
      issues.add(EventIssue.enrollmentAfterEvent);
    }
  }

  if (event.type == null) issues.add(EventIssue.noType);
  if (_blank(event.startCode)) issues.add(EventIssue.noStartCode);
  if (event.effectiveRouteKm == null) issues.add(EventIssue.noRoute);
  if (event.effectiveDurationMinutes == null) issues.add(EventIssue.noDuration);
  if (event.effectiveDifficulty == null) issues.add(EventIssue.noDifficulty);
  if (!event.hasStartPin) issues.add(EventIssue.noStartPin);
  if (_blank(event.finishPoint)) issues.add(EventIssue.noFinishPoint);
  if (event.missions.isEmpty) issues.add(EventIssue.noMissions);

  return issues;
}

/// One line of the publish checklist.
class PublishProblem {
  const PublishProblem(this.text, {this.missionIndex});

  final String text;

  /// The mission it is about, or null for the event details.
  final int? missionIndex;
}

/// Everything that stops the event from being published: the details first,
/// then each mission.
List<PublishProblem> publishProblems(Event event) {
  final problems = <PublishProblem>[
    for (final issue in eventIssues(event)) PublishProblem(issue.label),
  ];

  for (var i = 0; i < event.missions.length; i++) {
    for (final problem in missionProblems(event.missions[i])) {
      problems.add(PublishProblem('Misiunea ${i + 1}: ${problem.text}', missionIndex: i));
    }
  }
  return problems;
}

bool canPublish(Event event) => publishProblems(event).isEmpty;

/// How far along a draft is, from 0 (nothing filled in) to 1 (ready to
/// publish). Each detail counts once, and each mission counts once.
double draftProgress(Event event) {
  const enrollment = {
    EventIssue.noEnrollmentDates,
    EventIssue.enrollmentOrder,
    EventIssue.enrollmentAfterEvent,
  };

  // The enrolment checks are one detail, everything else is its own.
  final detailChecks = EventIssue.values.length - enrollment.length + 1;
  final failedDetails = <Object>{
    for (final issue in eventIssues(event)) enrollment.contains(issue) ? 'enrollment' : issue,
  };

  final missions = event.missions;
  final failedMissions = missions.where((m) => !isMissionComplete(m)).length;

  final total = detailChecks + missions.length;
  final failed = failedDetails.length + failedMissions;
  return (1 - failed / total).clamp(0.0, 1.0);
}

/// One line for a draft card: the first thing to do, or that it is ready.
String draftSummary(Event event, {bool withCount = false}) {
  final problems = publishProblems(event);
  if (problems.isEmpty) return 'Gata de publicat';

  final first = problems.first.text;
  if (withCount && problems.length > 1) {
    return '$first · încă ${problems.length - 1}';
  }
  return first;
}
