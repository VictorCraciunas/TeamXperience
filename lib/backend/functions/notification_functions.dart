import 'package:cloud_functions/cloud_functions.dart';

/// The organiser's push callable. Failures surface as
/// `FirebaseFunctionsException`.
class NotificationFunctions {
  NotificationFunctions({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;

  /// To the event's registered players, or to everyone without an [eventId].
  Future<void> send({
    required String title,
    required String description,
    String? eventId,
  }) async {
    await _functions.httpsCallable('sendNotification').call<Object?>({
      'title': title,
      'description': description,
      if (eventId != null) 'eventId': eventId,
    });
  }
}
