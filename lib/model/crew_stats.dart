/// What a crew has done together, kept up by the results function.
class CrewStats {
  const CrewStats({this.games = 0, this.wins = 0, this.distanceMeters = 0});

  final int games;
  final int wins;
  final double distanceMeters;

  factory CrewStats.fromMap(Object? raw) {
    if (raw is! Map) return const CrewStats();
    final games = raw['games'];
    final wins = raw['wins'];
    final distance = raw['distanceMeters'];
    return CrewStats(
      games: games is num ? games.toInt() : 0,
      wins: wins is num ? wins.toInt() : 0,
      distanceMeters: distance is num ? distance.toDouble() : 0,
    );
  }
}
