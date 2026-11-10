/// One crew's place in a season, written by the results function.
class SeasonStanding {
  const SeasonStanding({required this.crewId, required this.crewName, required this.points, this.games = 0});

  final String crewId;
  final String crewName;
  final int points;
  final int games;

  factory SeasonStanding.fromMap(String crewId, Map<String, dynamic> map) {
    final points = map['points'];
    final games = map['games'];
    return SeasonStanding(
      crewId: crewId,
      crewName: map['crewName'] as String? ?? '',
      points: points is num ? points.toInt() : 0,
      games: games is num ? games.toInt() : 0,
    );
  }
}

/// A season's document id and name: the same calendar as the results function
/// (`functions/src/results/season.ts`). December opens a winter named for its
/// year, so January and February belong to the year before.
({String id, String name}) seasonOf(DateTime date) {
  final month = date.month;
  final year = date.year;
  if (month >= 3 && month <= 5) return (id: '$year-spring', name: 'Primăvara $year');
  if (month >= 6 && month <= 8) return (id: '$year-summer', name: 'Vara $year');
  if (month >= 9 && month <= 11) return (id: '$year-autumn', name: 'Toamna $year');
  final winter = month == 12 ? year : year - 1;
  return (id: '$winter-winter', name: 'Iarna $winter');
}
