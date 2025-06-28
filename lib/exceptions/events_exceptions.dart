class EventServiceException implements Exception {
  final String message;
  const EventServiceException(this.message);

  @override
  String toString() => 'EventServiceException: $message';
}