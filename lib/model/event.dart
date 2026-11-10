import 'package:cloud_firestore/cloud_firestore.dart';

import '../enums/difficulty.dart';
import '../enums/event_status.dart';
import '../enums/screen_animation.dart';
import '../enums/event_type.dart';
import 'event_defaults.dart';
import 'mission.dart';

class Event {
  String eventId;
  String? name;
  List<Mission> missions;
  DateTime? dateEvent;
  DateTime? dateDeadlineEnrollment;
  DateTime? dateStartEnrollment;
  String? location;
  String? description;
  int nrMissions;
  EventType? type;
  String? landingImageUrl;
  String? taskBackgroundImageUrl;
  String? startCode;
  String? punctDeStart;
  String? lungimeTraseu;
  String? durata;
  String? dificultate;
  bool isStopped;

  /// A draft is only visible to organisers. Events without a status are published.
  EventStatus status;

  /// The wizard step a draft was left at, so it can be resumed there.
  int wizardStep;

  /// When the event was last saved by an organiser.
  DateTime? updatedAt;

  /// The look every new component starts with.
  EventDefaults? defaults;

  /// How the components of every puzzle appear when it opens.
  ScreenAnimation screenAnimation;

  /// How long, in milliseconds, one component takes to come in (200 to 1500),
  /// and how long after the one before the next starts (0 to 600). Null means
  /// automatic: 2 seconds for the whole puzzle.
  int? animationDuration;
  int? animationDelay;

  /// The part of town under the city ("Orașul de Sus").
  String? area;

  /// Where the route ends ("Turnul Sfatului").
  String? finishPoint;

  /// The route as numbers; old events keep them as text in [lungimeTraseu],
  /// [durata] and [dificultate], read through the `effective*` getters.
  double? routeLengthKm;
  int? durationMinutes;
  Difficulty? difficulty;

  int teamSizeMin;
  int teamSizeMax;

  /// How many teams can register; null means no limit.
  int? maxTeams;

  double? startLatitude;
  double? startLongitude;

  /// Where the route ends, on the map. Optional; [finishPoint] is its name.
  double? finishLatitude;
  double? finishLongitude;

  /// Where exactly teams meet ("Piața Mare, lângă fântână").
  String? meetingPointNote;

  /// How many minutes before the start teams should be there.
  int arriveMinutesBefore;
  List<String> whatToBring;

  /// The long story of the event page; [description] stays the short text of cards.
  String? story;

  /// Who runs the event; blank means TeamXperience.
  String? organiserName;

  /// The letter teams read before the first mission, and who signs it
  /// ("Cartograful").
  String? introLetter;
  String? introSignature;

  /// What the finish screen says once the route is done ("Harta e
  /// completă" / "Vulpile au moștenit secretul cartografului."); defaults
  /// when empty.
  String? finishTitle;
  String? finishMessage;

  /// How many hints a team may open in each mission.
  int hintsPerMission;

  /// How long after the start teams can still type the start code.
  int enterWindowMinutes;

  bool get isDraft => status == EventStatus.draft;

  /// How long a game lasts when the event has no duration (older events).
  static const Duration defaultPlayTime = Duration(hours: 3);

  /// How long the game lasts: the event's duration; the game ends for every
  /// team that long after the start.
  Duration get playTime {
    final minutes = durationMinutes;
    return minutes != null && minutes > 0 ? Duration(minutes: minutes) : defaultPlayTime;
  }

  /// When the game ends; null without a date.
  DateTime? get endsAt => dateEvent?.add(playTime);

  /// How long after the start teams can still type the start code, never
  /// past the end of the game.
  Duration get enterWindow {
    final window = Duration(minutes: enterWindowMinutes);
    return window > playTime ? playTime : window;
  }

  /// Stopped, or its time ran out by [now].
  bool isOverAt(DateTime now) {
    if (isStopped) return true;
    final end = endsAt;
    return end != null && now.isAfter(end);
  }

  bool get hasExpired => !isStopped && isOverAt(DateTime.now());

  bool get isOver => isOverAt(DateTime.now());

  /// The route length, from [routeLengthKm] or the first number in
  /// [lungimeTraseu] ("4,5 km", "3.5km", "500 m").
  double? get effectiveRouteKm {
    final km = routeLengthKm;
    if (km != null) return km;
    final match = RegExp(r'(\d+(?:[.,]\d+)?)\s*(km|m(?![a-z]))?').firstMatch((lungimeTraseu ?? '').toLowerCase());
    final value = _number(match?.group(1));
    if (match == null || value == null) return null;
    return match.group(2) == 'm' ? value / 1000 : value;
  }

  /// The duration in minutes, from [durationMinutes] or [durata] ("2 h",
  /// "2 ore", "1,5 ore", "2-3 ore", "1h30", "1 oră 30 min", "aprox. 90 min").
  /// A bare number reads as nothing: it could be hours or minutes.
  int? get effectiveDurationMinutes {
    final minutes = durationMinutes;
    if (minutes != null) return minutes;
    // A range counts from its start: "2-3 ore" is 2 hours.
    final text = (durata ?? '').toLowerCase().replaceAllMapped(RegExp(r'(\d+)\s*[-–]\s*\d+'), (m) => m.group(1) ?? '');
    final hours = RegExp(r'(\d+(?:[.,]\d+)?)\s*(?:ore|oră|ora|h)').firstMatch(text);
    final hourValue = _number(hours?.group(1));
    if (hours != null && hourValue != null) {
      final rest = _number(RegExp(r'(\d+)').firstMatch(text.substring(hours.end))?.group(1)) ?? 0;
      return (hourValue * 60 + rest).round();
    }
    return _number(RegExp(r'(\d+)\s*(?:de\s+)?min').firstMatch(text)?.group(1))?.round();
  }

  static double? _number(String? text) => text == null ? null : double.tryParse(text.replaceAll(',', '.'));

  /// The difficulty, from [difficulty] or the words in [dificultate].
  Difficulty? get effectiveDifficulty {
    final value = difficulty;
    if (value != null) return value;
    final text = _plain(dificultate ?? '');
    if (text.contains('usor') || text.contains('usoar')) return Difficulty.easy;
    if (text.contains('medi')) return Difficulty.medium;
    if (text.contains('grea') || text.contains('greu') || text.contains('dific')) return Difficulty.hard;
    return null;
  }

  /// The event page story, or the short description when there is none.
  String get storyText {
    final text = story;
    return text != null && text.trim().isNotEmpty ? text : (description ?? '');
  }

  bool get hasStartPin => startLatitude != null && startLongitude != null;

  bool get hasFinishPin => finishLatitude != null && finishLongitude != null;

  static String _plain(String text) => text
      .toLowerCase()
      .replaceAll(RegExp('[ăâ]'), 'a')
      .replaceAll('î', 'i')
      .replaceAll(RegExp('[șş]'), 's')
      .replaceAll(RegExp('[țţ]'), 't');

  Event({
    required this.eventId,
    this.name,
    List<Mission>? missions,
    this.dateEvent,
    this.dateDeadlineEnrollment,
    this.dateStartEnrollment,
    this.location,
    this.description,
    this.nrMissions = 0,
    this.type,
    this.landingImageUrl,
    this.taskBackgroundImageUrl,
    this.startCode,
    this.punctDeStart,
    this.dificultate,
    this.lungimeTraseu,
    this.durata,
    this.isStopped = false,
    this.status = EventStatus.published,
    this.wizardStep = 0,
    this.updatedAt,
    this.defaults,
    this.screenAnimation = ScreenAnimation.fade,
    this.animationDuration,
    this.animationDelay,
    this.area,
    this.finishPoint,
    this.routeLengthKm,
    this.durationMinutes,
    this.difficulty,
    this.teamSizeMin = 2,
    this.teamSizeMax = 6,
    this.maxTeams,
    this.startLatitude,
    this.startLongitude,
    this.finishLatitude,
    this.finishLongitude,
    this.meetingPointNote,
    this.arriveMinutesBefore = 15,
    List<String>? whatToBring,
    this.story,
    this.organiserName,
    this.introLetter,
    this.introSignature,
    this.finishTitle,
    this.finishMessage,
    this.hintsPerMission = 1,
    this.enterWindowMinutes = 60,
  })  : missions = missions ?? [],
        whatToBring = whatToBring ?? [];

  Mission addMission(Mission mission) {
    missions.add(mission);
    return mission;
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    // A draft can be saved half way, so most fields may be missing.
    final rawType = map['type'] as String?;
    final rawList = map['missions'] as List<dynamic>? ?? [];
    final missions =
        rawList.map((e) => Mission.fromMap(e as Map<String, dynamic>)).toList();
    return Event(
      eventId: map['eventId'],
      name: map['name'] as String? ?? '',
      missions: missions,
      dateEvent: (map['dateEvent'] as Timestamp?)?.toDate(),
      dateDeadlineEnrollment:
          (map['dateDeadlineEnrollment'] as Timestamp?)?.toDate(),
      dateStartEnrollment: (map['dateStartEnrollment'] as Timestamp?)?.toDate(),
      location: map['location'] as String? ?? '',
      description: map['description'] as String? ?? '',
      nrMissions: map['nrMissions'] as int? ?? 0,
      type: rawType == null ? null : EventType.values.byName(rawType),
      landingImageUrl: map['landingImageUrl'] as String? ?? '',
      taskBackgroundImageUrl: map['taskBackgroundImageUrl'] as String? ?? '',
      startCode: map['startCode'] as String? ?? '',
      punctDeStart: map['punctDeStart'] as String? ?? '',
      dificultate: map['dificultate'] as String? ?? '',
      durata: map['durata'] as String? ?? '',
      lungimeTraseu: map['lungimeTraseu'] as String? ?? '',
      isStopped: map['isStopped'] as bool? ?? false,
      status: EventStatus.fromName(map['status'] as String?),
      wizardStep: map['wizardStep'] as int? ?? 0,
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      defaults: EventDefaults.fromMap(
        (map['defaults'] as Map?)?.cast<String, dynamic>(),
      ),
      screenAnimation: ScreenAnimation.fromName(map['screenAnimation'] as String?),
      animationDuration: (map['animationDuration'] as num?)?.toInt(),
      animationDelay: (map['animationDelay'] as num?)?.toInt(),
      area: map['area'] as String?,
      finishPoint: map['finishPoint'] as String?,
      routeLengthKm: (map['routeLengthKm'] as num?)?.toDouble(),
      durationMinutes: (map['durationMinutes'] as num?)?.toInt(),
      difficulty: Difficulty.fromName(map['difficulty'] as String?),
      teamSizeMin: (map['teamSizeMin'] as num?)?.toInt() ?? 2,
      teamSizeMax: (map['teamSizeMax'] as num?)?.toInt() ?? 6,
      maxTeams: (map['maxTeams'] as num?)?.toInt(),
      startLatitude: (map['startLatitude'] as num?)?.toDouble(),
      startLongitude: (map['startLongitude'] as num?)?.toDouble(),
      finishLatitude: (map['finishLatitude'] as num?)?.toDouble(),
      finishLongitude: (map['finishLongitude'] as num?)?.toDouble(),
      meetingPointNote: map['meetingPointNote'] as String?,
      arriveMinutesBefore: (map['arriveMinutesBefore'] as num?)?.toInt() ?? 15,
      whatToBring: [for (final item in map['whatToBring'] as List<dynamic>? ?? []) item.toString()],
      story: map['story'] as String?,
      organiserName: map['organiserName'] as String?,
      introLetter: map['introLetter'] as String?,
      introSignature: map['introSignature'] as String?,
      finishTitle: map['finishTitle'] as String?,
      finishMessage: map['finishMessage'] as String?,
      hintsPerMission: (map['hintsPerMission'] as num?)?.toInt() ?? 1,
      enterWindowMinutes: (map['enterWindowMinutes'] as num?)?.toInt() ?? 60,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'name': name,
      'missions': missions.map((m) => m.toJson()).toList(),
      'dateEvent': dateEvent,
      'dateDeadlineEnrollment': dateDeadlineEnrollment,
      'dateStartEnrollment': dateStartEnrollment,
      'location': location,
      'description': description,
      'nrMissions': nrMissions,
      'type': type?.name,
      'landingImageUrl': landingImageUrl,
      'taskBackgroundImageUrl': taskBackgroundImageUrl,
      'startCode': startCode,
      'lungimeTraseu': lungimeTraseu,
      'durata': durata,
      'dificultate': dificultate,
      'punctDeStart': punctDeStart,
      'isStopped': isStopped,
      'status': status.name,
      'wizardStep': wizardStep,
      'updatedAt': updatedAt,
      'defaults': defaults?.toJson(),
      'screenAnimation': screenAnimation.name,
      'animationDuration': animationDuration,
      'animationDelay': animationDelay,
      'area': area,
      'finishPoint': finishPoint,
      'routeLengthKm': routeLengthKm,
      'durationMinutes': durationMinutes,
      'difficulty': difficulty?.name,
      'teamSizeMin': teamSizeMin,
      'teamSizeMax': teamSizeMax,
      'maxTeams': maxTeams,
      'startLatitude': startLatitude,
      'startLongitude': startLongitude,
      'finishLatitude': finishLatitude,
      'finishLongitude': finishLongitude,
      'meetingPointNote': meetingPointNote,
      'arriveMinutesBefore': arriveMinutesBefore,
      'whatToBring': whatToBring,
      'story': story,
      'organiserName': organiserName,
      'introLetter': introLetter,
      'introSignature': introSignature,
      'finishTitle': finishTitle,
      'finishMessage': finishMessage,
      'hintsPerMission': hintsPerMission,
      'enterWindowMinutes': enterWindowMinutes,
    };
  }

  @override
  String toString() {
    //   return 'Event(eventId: $eventId, name: $name, missions: [${missions.join(', ')}], '
    //       'dateEvent: $dateEvent, dateDeadlineEnrollment: $dateDeadlineEnrollment, '
    //       'dateStartEnrollment: $dateStartEnrollment, location: $location, '
    //       'description: $description, nrMissions: $nrMissions, '
    //       'type: ${type != null ? type!.name : null.toString()}, '
    //       'landingImageUrl: $landingImageUrl, taskBackgroundImageUrl: $taskBackgroundImageUrl, '
    //       'startCode: $startCode, punctDeStart: $punctDeStart, '
    //       'lungimeTraseu: $lungimeTraseu, durata: $durata, dificultate: $dificultate)';
    // }
    return 'landingImageUrl: $landingImageUrl, taskBackgroundImageUrl: $taskBackgroundImageUrl';
  }
}
