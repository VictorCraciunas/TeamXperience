import 'package:cloud_firestore/cloud_firestore.dart';

import '../enums/event_type.dart';
import 'mission.dart';

class Event {
  final String eventId;
  final String? name;
  Map<String, Mission> missions;
  final DateTime startTime;
  final DateTime deadlineEnrollment;
  final String location;
  final String description;
  final int nrMissions;
  final EventType type;
  final String landingImageUrl;
  final String taskBackgroundImageUrl;
  final String startCode;

  Event({
    required this.eventId ,
    required this.name ,
    Map<String, Mission>? missions,
    required this.startTime,
    required this.deadlineEnrollment,
    required this.location ,
    required this.description,
    required this.nrMissions ,
    required this.type,
    required this.landingImageUrl,
    required this.taskBackgroundImageUrl ,
    required this.startCode ,
  }) : missions = missions ?? {};


  void addMission(String missionId, Mission mission) => missions[missionId] = mission;

  factory Event.fromMap(Map<String, dynamic> map) {
    final rawType = map['type'] as String;
    return Event(
      eventId: map['eventId'],
      name: map['name'] as String? ?? '',
      missions: (map['missions'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, Mission.fromMap(value as Map<String, dynamic>)),
      ) ??
          {},
      startTime: (map['startTime'] as Timestamp).toDate(),
      deadlineEnrollment: (map['deadlineEnrollment'] as Timestamp).toDate(),
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
      'missions': {for (var entry in missions.entries) entry.key: entry.value.toJson()},
      'startTime': startTime,
      'deadlineEnrollment': deadlineEnrollment,
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