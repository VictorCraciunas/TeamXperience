/// What the `registerTeam` callable returns.
class RegisterResult {
  final String teamName;
  final String crewId;

  /// Stored without the dash, upper-case: "VLP482".
  final String inviteCode;

  /// Crew members left out because they are already in another team of the
  /// event.
  final List<String> skippedUids;

  const RegisterResult({
    required this.teamName,
    required this.crewId,
    required this.inviteCode,
    required this.skippedUids,
  });

  factory RegisterResult.fromMap(Map<String, dynamic> map) {
    final rawSkipped = map['skippedUids'] as List<dynamic>? ?? [];
    return RegisterResult(
      teamName: map['teamName'] as String? ?? '',
      crewId: map['crewId'] as String? ?? '',
      inviteCode: map['inviteCode'] as String? ?? '',
      skippedUids: rawSkipped.map((uid) => uid.toString()).toList(),
    );
  }
}
