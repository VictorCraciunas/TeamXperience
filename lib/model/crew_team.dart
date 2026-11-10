/// A crew's link to one of its teams: the event and the team's name there.
class CrewTeam {
  final String eventId;
  final String teamName;

  const CrewTeam({required this.eventId, required this.teamName});

  /// Null for a link without an event or a name.
  static CrewTeam? fromMap(Object? raw) {
    if (raw is! Map) return null;
    final eventId = raw['eventId'];
    final teamName = raw['teamName'];
    if (eventId is! String || teamName is! String || eventId.isEmpty || teamName.isEmpty) return null;
    return CrewTeam(eventId: eventId, teamName: teamName);
  }
}
