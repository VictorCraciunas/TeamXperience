import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/model/event.dart';

void main() {
  test('an event saved without a finish pin has none', () {
    final e = Event.fromMap({'eventId': 'e'});
    expect((e.finishLatitude, e.finishLongitude, e.hasFinishPin), (null, null, false));
  });

  test('the finish pin survives saving, and whole numbers read as decimals', () {
    final saved = Event(eventId: 'e', finishLatitude: 45.8, finishLongitude: 24.2).toJson();
    final back = Event.fromMap({...saved, 'eventId': 'e'});
    expect((back.finishLatitude, back.finishLongitude, back.hasFinishPin), (45.8, 24.2, true));
    expect(Event.fromMap({'eventId': 'e', 'finishLatitude': 45, 'finishLongitude': 24}).finishLatitude, 45.0);
  });

  test('half a pin is no pin', () {
    expect(Event(eventId: 'e', finishLatitude: 45).hasFinishPin, isFalse);
  });
}
