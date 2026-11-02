import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/screen_animation.dart';
import 'package:teamxperience/model/event.dart';

void main() {
  group('ScreenAnimation', () {
    test('has fade and none', () {
      expect(ScreenAnimation.values.map((a) => a.name), ['fade', 'none']);
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

    test('an event saved before the option existed fades', () {
      final event = Event.fromMap({'eventId': 'old', 'name': 'x'});
      expect(event.screenAnimation, ScreenAnimation.fade);
    });
  });
}
