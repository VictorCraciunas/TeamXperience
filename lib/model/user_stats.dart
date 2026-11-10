/// A player's totals over every game, written by the end-of-event function
/// (step 7c); zero until then.
/// A count read from a document: a finite number, else 0.
int readCount(Object? value) => value is num && value.isFinite ? value.toInt() : 0;

class UserStats {
  const UserStats({this.games = 0, this.distanceMeters = 0, this.missions = 0, this.podiums = 0});

  final int games;
  final double distanceMeters;
  final int missions;

  /// Games finished in the first three places.
  final int podiums;


  factory UserStats.fromMap(Object? raw) {
    if (raw is! Map) return const UserStats();
    final km = raw['distanceMeters'];
    return UserStats(
      games: readCount(raw['games']),
      distanceMeters: km is num && km.isFinite ? km.toDouble() : 0,
      missions: readCount(raw['missions']),
      podiums: readCount(raw['podiums']),
    );
  }

  Map<String, dynamic> toJson() =>
      {'games': games, 'distanceMeters': distanceMeters, 'missions': missions, 'podiums': podiums};
}
