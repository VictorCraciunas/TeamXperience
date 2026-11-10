import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/notification/logic/notification_failure_text.dart';

FirebaseFunctionsException _refused(String reason) => FirebaseFunctionsException(
      message: reason,
      code: 'failed-precondition',
      details: {'reason': reason},
    );

void main() {
  test('each refusal says what happened', () {
    expect(notificationFailureText(_refused('notOrganiser')), 'Doar organizatorii pot trimite notificări.');
    expect(notificationFailureText(_refused('notificationInvalid')), 'Completează titlul și mesajul.');
    expect(notificationFailureText(_refused('noRecipients')), 'Nimeni nu poate primi notificarea încă.');
  });

  test('anything else gets the general text, never the raw error', () {
    const general = 'Notificarea nu a putut fi trimisă. Încearcă din nou.';
    expect(notificationFailureText(_refused('somethingNew')), general);
    expect(notificationFailureText(Exception('socket')), general);
  });
}
