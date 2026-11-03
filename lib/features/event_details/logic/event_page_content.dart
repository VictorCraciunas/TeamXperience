import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/model/event.dart';

/// A mission shown on the event page before the game.
class MissionTeaser {
  const MissionTeaser({required this.number, required this.title, required this.teaser});

  /// Its place in the route, from 1.
  final int number;
  final String title;
  final String teaser;
}

/// The public missions with a title, and how many others stay secret.
({List<MissionTeaser> shown, int secret}) missionTeasers(Event e) {
  final shown = <MissionTeaser>[];
  for (var i = 0; i < e.missions.length; i++) {
    final mission = e.missions[i];
    final title = mission.title?.trim() ?? '';
    if (!mission.isTeaserPublic || title.isEmpty) continue;
    shown.add(MissionTeaser(number: i + 1, title: title, teaser: mission.teaser?.trim() ?? ''));
  }
  return (shown: shown, secret: e.missions.length - shown.length);
}

/// "Încă 4 misiuni secrete", or "4 misiuni secrete" when [alone] (no public
/// mission above it).
String secretMissionsLine(int n, {bool alone = false}) {
  if (alone) return n == 1 ? 'O misiune secretă' : '$n misiuni secrete';
  return n == 1 ? 'Încă o misiune secretă' : 'Încă $n misiuni secrete';
}

/// The kinds of puzzle the chips under the missions name.
enum PuzzleKind { codes, photos, places }

/// The kinds the event's puzzles use, in a fixed order.
List<PuzzleKind> puzzleKinds(Event e) {
  final types = {for (final m in e.missions) for (final p in m.puzzles) p.type};
  return [
    if (types.contains(PuzzleType.code)) PuzzleKind.codes,
    if (types.contains(PuzzleType.imageToUpload)) PuzzleKind.photos,
    if (types.contains(PuzzleType.geolocation)) PuzzleKind.places,
  ];
}

String puzzleKindLabel(PuzzleKind k) => switch (k) {
      PuzzleKind.codes => 'Coduri',
      PuzzleKind.photos => 'Fotografii',
      PuzzleKind.places => 'Locuri pe hartă',
    };

/// The organiser of events without a name.
const defaultOrganiser = 'TeamXperience';

String _organiserOf(String? name) {
  final trimmed = name?.trim() ?? '';
  return trimmed.isEmpty ? defaultOrganiser : trimmed;
}

/// How many of [published] the organiser named [name] runs.
int organiserEventsCount(List<Event> published, String? name) {
  final wanted = _organiserOf(name);
  return published.where((e) => _organiserOf(e.organiserName) == wanted).length;
}
