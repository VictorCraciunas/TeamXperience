import 'package:teamxperience/model/crew.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';

/// What the form shows for a crew signing up again: its name, and the size and
/// phone of its last sign-up ([last], null while unknown).
typedef CrewPrefill = ({String name, int size, String phone});

/// The fewest a team can be: room for every player of [crew] (none for a new
/// team) and at least the event's minimum.
int crewSizeMin(Crew? crew, Event event) {
  final players = crew?.members.length ?? 0;
  return players > event.teamSizeMin ? players : event.teamSizeMin;
}

/// The size never drops below the crew's players nor the event's minimum, and
/// never passes the event's maximum. Without a last sign-up it is [fallback].
CrewPrefill crewPrefill({required Crew crew, required Event event, required int fallback, Team? last}) {
  final min = crewSizeMin(crew, event);
  final size = (last?.numberOfMembers ?? fallback).clamp(min, event.teamSizeMax);
  return (name: crew.name, size: size, phone: last?.phoneNumber.trim() ?? '');
}
