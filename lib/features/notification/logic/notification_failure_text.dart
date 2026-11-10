import 'package:cloud_functions/cloud_functions.dart';

/// What to tell the organiser when a notification did not go out.
String notificationFailureText(Object error) {
  final details = error is FirebaseFunctionsException ? error.details : null;
  final reason = details is Map ? details['reason'] : null;
  return switch (reason) {
    'notOrganiser' => 'Doar organizatorii pot trimite notificări.',
    'notificationInvalid' => 'Completează titlul și mesajul.',
    'noRecipients' => 'Nimeni nu poate primi notificarea încă.',
    _ => 'Notificarea nu a putut fi trimisă. Încearcă din nou.',
  };
}
