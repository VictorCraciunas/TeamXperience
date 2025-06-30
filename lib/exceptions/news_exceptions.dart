class StireServiceException implements Exception {
  final String message;

  StireServiceException(this.message);

  @override
  String toString() => 'StireServiceException: $message';
}