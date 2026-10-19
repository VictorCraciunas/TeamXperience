import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';

class PreparationStep {
  const PreparationStep({
    required this.title,
    required this.subtitle,
    required this.done,
  });

  final String title;
  final String subtitle;
  final bool done;
}

/// The three things a team does before an event: register, complete its
/// details, and receive the start code on the day of the event.
List<PreparationStep> preparationSteps(Event event, Team? team, DateTime now) {
  final registered = team != null;
  final detailsComplete = team != null &&
      team.name.trim().isNotEmpty &&
      team.captainName.trim().isNotEmpty &&
      team.phoneNumber.trim().isNotEmpty &&
      team.captainEmail.trim().isNotEmpty;

  final start = event.dateEvent;
  final eventDay = start == null ? null : DateTime(start.year, start.month, start.day);
  final codeAvailable = eventDay != null && !now.isBefore(eventDay);

  return [
    PreparationStep(
      title: 'Înscriere confirmată',
      subtitle: team == null
          ? 'Nu ai înscris încă o echipă'
          : '${team.name} · ${team.numberOfMembers} membri',
      done: registered,
    ),
    PreparationStep(
      title: 'Detalii echipă complete',
      subtitle: 'Căpitan, telefon și email',
      done: detailsComplete,
    ),
    PreparationStep(
      title: 'Codul de start',
      subtitle: codeAvailable
          ? 'Îl primești de la organizatori'
          : 'Îl primești în ziua evenimentului',
      done: codeAvailable,
    ),
  ];
}
