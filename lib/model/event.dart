import 'package:cloud_firestore/cloud_firestore.dart';

import '../enums/event_type.dart';
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
  }) : missions = missions ?? [];

  Mission addMission(Mission mission) {
    missions.add(mission);
    return mission;
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    final rawType = map['type'] as String;
    final rawList = map['missions'] as List<dynamic>? ?? [];
    final missions =
        rawList.map((e) => Mission.fromMap(e as Map<String, dynamic>)).toList();
    return Event(
      eventId: map['eventId'],
      name: map['name'] as String? ?? '',
      missions: missions,
      dateEvent: (map['dateEvent'] as Timestamp).toDate(),
      dateDeadlineEnrollment:
          (map['dateDeadlineEnrollment'] as Timestamp).toDate(),
      dateStartEnrollment: (map['dateStartEnrollment'] as Timestamp).toDate(),
      location: map['location'] as String? ?? '',
      description: map['description'] as String? ?? '',
      nrMissions: map['nrMissions'] as int? ?? 0,
      type: EventType.values.byName(rawType),
      landingImageUrl: map['landingImageUrl'] as String? ?? '',
      taskBackgroundImageUrl: map['taskBackgroundImageUrl'] as String? ?? '',
      startCode: map['startCode'] as String? ?? '',
      punctDeStart: map['punctDeStart'] as String? ?? '',
      dificultate: map['dificultate'] as String? ?? '',
      durata: map['durata'] as String? ?? '',
      lungimeTraseu: map['lungimeTraseu'] as String? ?? '',
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
      'type': type!.name,
      'landingImageUrl': landingImageUrl,
      'taskBackgroundImageUrl': taskBackgroundImageUrl,
      'startCode': startCode,
      'lungimeTraseu': lungimeTraseu,
      'durata': durata,
      'dificultate': dificultate,
      'punctDeStart': punctDeStart,
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
