import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';

/// The three things a team gets ready before its event, as on the next-game
/// card: registered, a full team, and the start code (handed out on the day).
const List<String> preparationLabels = ['Înscriși', 'Echipă completă', 'Cod de start'];

/// How far a team has got with [preparationLabels].
class PreparationTrail {
  const PreparationTrail({required this.teamName, required this.done});

  final String teamName;

  /// How many of the steps are done, counted from the first, so a later step
  /// never shows done before an earlier one.
  final int done;
}

PreparationTrail preparationTrail(Event event, Team team, DateTime now) {
  final complete = team.numberOfMembers > 0 && team.memberList.length >= team.numberOfMembers;
  final start = event.dateEvent;
  final eventDay = start == null ? null : DateTime(start.year, start.month, start.day);
  final codeDay = eventDay != null && !now.isBefore(eventDay);

  var done = 1;
  if (complete) {
    done = 2;
    if (codeDay) done = 3;
  }
  return PreparationTrail(teamName: team.name, done: done);
}
