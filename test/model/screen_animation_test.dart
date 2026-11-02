import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/screen_animation.dart';
import 'package:teamxperience/model/event.dart';

void main() {
  group('ScreenAnimation', () {
    test('starts with fade and none, the two it had first', () {
      expect(ScreenAnimation.values.take(2).map((a) => a.name), ['fade', 'none']);
    });

    test('is read from its name', () {
      expect(ScreenAnimation.fromName('fade'), ScreenAnimation.fade);
      expect(ScreenAnimation.fromName('none'), ScreenAnimation.none);
    });

    test('anything missing or unknown is fade, as before the option existed', () {
      expect(ScreenAnimation.fromName(null), ScreenAnimation.fade);
      expect(ScreenAnimation.fromName(''), ScreenAnimation.fade);
      expect(ScreenAnimation.fromName('slide'), ScreenAnimation.fade);
    });

    test('has a label for the form', () {
      expect(ScreenAnimation.fade.label, 'Fade (implicit)');
      expect(ScreenAnimation.none.label, 'Fără animație');
    });
  });

  group('Event', () {
    test('fades by default', () {
      expect(Event(eventId: 'e').screenAnimation, ScreenAnimation.fade);
    });

    test('is written and read back', () {
      final event = Event(eventId: 'e', screenAnimation: ScreenAnimation.none);
      expect(event.toJson()['screenAnimation'], 'none');
      expect(Event.fromMap({...event.toJson(), 'eventId': 'e'}).screenAnimation, ScreenAnimation.none);
    });

    test('has no chosen timing unless asked', () {
      final event = Event(eventId: 'e');
      expect(event.animationDuration, isNull);
      expect(event.animationDelay, isNull);
    });

    test('the timing is written and read back, a delay of 0 included', () {
      final event = Event(eventId: 'e', animationDuration: 800, animationDelay: 0);
      final back = Event.fromMap({...event.toJson(), 'eventId': 'e'});
      expect(back.animationDuration, 800);
      expect(back.animationDelay, 0);
    });

    test('a timing saved as a decimal is read as a whole number', () {
      final back = Event.fromMap({'eventId': 'e', 'animationDuration': 600.0, 'animationDelay': 250.0});
      expect(back.animationDuration, 600);
      expect(back.animationDelay, 250);
    });

    test('an event saved before the option existed fades', () {
      final event = Event.fromMap({'eventId': 'old', 'name': 'x'});
      expect(event.screenAnimation, ScreenAnimation.fade);
    });
  });
}
