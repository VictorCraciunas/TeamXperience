/// What can be wrong with a team name; the Dart twin of the rules in
/// `functions/src/teams/names.ts`, so the app can tell before it asks the server.
enum TeamNameProblem { short, long, characters }

/// Trims and collapses inner whitespace.
String cleanTeamName(String input) =>
    input.trim().replaceAll(RegExp(r'\s+'), ' ');

/// What is wrong with the cleaned name, or null when it is fine.
TeamNameProblem? teamNameProblem(String name) {
  final cleaned = cleanTeamName(name);
  if (cleaned.length < 2) return TeamNameProblem.short;
  if (cleaned.length > 30) return TeamNameProblem.long;
  if (cleaned.contains('/') ||
      cleaned.startsWith('.') ||
      cleaned.endsWith('.') ||
      cleaned.contains('__')) {
    return TeamNameProblem.characters;
  }
  return null;
}
