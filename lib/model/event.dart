import 'package:cloud_firestore/cloud_firestore.dart';

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

  bool get isDraft => status == EventStatus.draft;

  static const Duration maxDuration = Duration(hours: 3);

  /// How long after the start teams can still type the start code.
  static const Duration enterWindow = Duration(minutes: 60);

  bool get hasExpired {
    final start = dateEvent;
    if (start == null) return false;
    return DateTime.now().isAfter(start.add(maxDuration));
  }

  bool get isOver => isStopped || hasExpired;

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
  }) : missions = missions ?? [];

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
