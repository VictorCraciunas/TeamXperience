class Team {
  final String name;
  final String teamMembers;
  final String captainName;
  final String phoneNumber;
  final String captainEmail;
  int missionProgress;
  int puzzleNumber;
  List<String> userIds;
  bool hasStarted;
  bool hasFinished;
  double latitude;
  double longitude;
  int numberOfMembers;

  Team({
    required this.name,
    required this.teamMembers,
    required this.captainName,
    required this.phoneNumber,
    required this.captainEmail,
    this.missionProgress = 0,
    this.puzzleNumber = 0,
    List<String>? userIds,
    this.hasStarted = false,
    this.hasFinished = false,
    this.latitude = 0,
    this.longitude = 0,
    this.numberOfMembers = 0,
  }) : userIds = userIds ?? [];

  factory Team.fromMap(Map<String, dynamic> map) {
    final rawUserIds = map['userIds'] as List<dynamic>? ?? [];
    final userIdsList = rawUserIds.map((id) => id.toString()).toList();

    return Team(
      name: map['name'] as String? ?? '',
      teamMembers: map['teamMembers'] as String? ?? '',
      captainName: map['captainName'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      captainEmail: map['captainEmail'] as String? ?? '',
      missionProgress: map['missionProgress'] as int? ?? 0,
      puzzleNumber: map['puzzleNumber'] as int? ?? 0,
      userIds: userIdsList,
      hasStarted: map['hasStarted'] as bool? ?? false,
      hasFinished: map['hasFinished'] as bool? ?? false,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      numberOfMembers: map['numberOfMembers'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'teamMembers': teamMembers,
      'captainName': captainName,
      'phoneNumber': phoneNumber,
      'captainEmail': captainEmail,
      'missionProgress': missionProgress,
      'puzzleNumber': puzzleNumber,
      'userIds': userIds,
      'hasStarted': hasStarted,
      'hasFinished': hasFinished,
      'latitude': latitude,
      'longitude': longitude,
      'numberOfMembers': numberOfMembers,
    };
  }

}