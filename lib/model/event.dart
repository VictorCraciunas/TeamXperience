import 'package:cloud_firestore/cloud_firestore.dart';

import '../enums/event_type.dart';
import 'mission.dart';

class Event {
  final String eventId;
  final String? name;
  List<Mission> missions;
  final DateTime dateEvent;
  final DateTime dateDeadlineEnrollment;
  final DateTime dateStartEnrollment;
  final String location;
  final String description;
  final int nrMissions;
  final EventType type;
   String landingImageUrl;
   String taskBackgroundImageUrl;
  final String startCode;

  Event({
    required this.eventId ,
    required this.name ,
    List<Mission>? missions,
    required this.dateEvent,
    required this.dateDeadlineEnrollment,
    required this.dateStartEnrollment,
    required this.location ,
    required this.description,
    required this.nrMissions ,
    required this.type,
    required this.landingImageUrl,
    required this.taskBackgroundImageUrl ,
    required this.startCode ,
  }) : missions = missions ?? [];


  Mission addMission(Mission mission) {
    missions.add(mission);
    return mission;
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    final rawType = map['type'] as String;
    final rawList = map['missions'] as List<dynamic>? ?? [];
    final missions = rawList.map((e) => Mission.fromMap(e as Map<String, dynamic>)).toList();
    return Event(
      eventId: map['eventId'],
      name: map['name'] as String? ?? '',
      missions:missions,
      dateEvent: (map['dateEvent'] as Timestamp).toDate(),
      dateDeadlineEnrollment: (map['dateDeadlineEnrollment'] as Timestamp).toDate(),
      dateStartEnrollment: (map['dateStartEnrollment'] as Timestamp).toDate(),
      location: map['location'] as String? ?? '',
      description: map['description'] as String? ?? '',
      nrMissions: map['nrMissions'] as int? ?? 0,
      type: EventType.values.byName(rawType),
      landingImageUrl: map['landingImageUrl'] as String? ?? '',
      taskBackgroundImageUrl: map['taskBackgroundImageUrl'] as String? ?? '',
      startCode: map['startCode'] as String? ?? '',
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
      'type': type.name,
      'landingImageUrl': landingImageUrl,
      'taskBackgroundImageUrl': taskBackgroundImageUrl,
      'startCode': startCode,
    };
  }
}