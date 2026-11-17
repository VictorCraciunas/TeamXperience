/// One team's chat with the organiser. Team documents are keyed by name, so a
/// renamed team is a new chat.
class ChatKey {
  const ChatKey(this.eventId, this.teamName);

  final String eventId;
  final String teamName;

  @override
  bool operator ==(Object other) => other is ChatKey && other.eventId == eventId && other.teamName == teamName;

  @override
  int get hashCode => Object.hash(eventId, teamName);

  @override
  String toString() => 'ChatKey($eventId, $teamName)';
}
