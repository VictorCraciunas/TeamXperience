/// Publishing was refused because the event is not complete.
class EventNotPublishableException implements Exception {
  const EventNotPublishableException(this.problems);

  /// Everything that is missing, worded for the organiser.
  final List<String> problems;

  @override
  String toString() => 'EventNotPublishableException: ${problems.join('; ')}';
}

class EventServiceException implements Exception {
  final String message;
  const EventServiceException(this.message);

  @override
  String toString() => 'EventServiceException: $message';
}