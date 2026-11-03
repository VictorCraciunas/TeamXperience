import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/event_details/logic/hero_badge.dart';
import 'package:teamxperience/model/event.dart';

Event _event({bool stopped = false, bool noEnrolment = false}) => Event(
      eventId: 'e',
      dateEvent: DateTime(2026, 11, 14, 10),
      dateStartEnrollment: noEnrolment ? null : DateTime(2026, 11, 1),
      dateDeadlineEnrollment: noEnrolment ? null : DateTime(2026, 11, 12),
      isStopped: stopped,
    );

void main() {
  (HeroBadgeKind, String)? at(DateTime now, {Event? e}) {
    final badge = heroBadge(e ?? _event(), now);
    return badge == null ? null : (badge.kind, badge.label);
  }

  test('open with days left', () {
    expect(at(DateTime(2026, 11, 7, 18)), (HeroBadgeKind.open, 'Înscrieri deschise · încă 5 zile'));
  });

  test('one day left, and the last day', () {
    expect(at(DateTime(2026, 11, 11, 9)), (HeroBadgeKind.open, 'Înscrieri deschise · încă o zi'));
    expect(at(DateTime(2026, 11, 12, 23)), (HeroBadgeKind.open, 'Înscrieri deschise · ultima zi'));
  });

  test('before enrolment opens', () {
    expect(at(DateTime(2026, 10, 30)), (HeroBadgeKind.soon, 'Înscrieri de pe 1 nov'));
  });

  test('after the deadline, before the event', () {
    expect(at(DateTime(2026, 11, 13)), (HeroBadgeKind.closed, 'Înscrieri închise'));
  });

  test('live from the start to the end of the enter window', () {
    expect(at(DateTime(2026, 11, 14, 10)), (HeroBadgeKind.live, 'LIVE'));
    expect(at(DateTime(2026, 11, 14, 11)), (HeroBadgeKind.live, 'LIVE'));
  });

  test('no badge once the event is over', () {
    expect(at(DateTime(2026, 11, 14, 13, 1)), isNull);
    expect(at(DateTime(2026, 11, 7), e: _event(stopped: true)), isNull);
  });

  test('an event without enrolment dates is open until it starts', () {
    expect(at(DateTime(2026, 11, 13), e: _event(noEnrolment: true))?.$1, HeroBadgeKind.open);
  });

  test('the badge closes at the exact deadline time', () {
    final e = _event()..dateDeadlineEnrollment = DateTime(2026, 11, 12, 18);
    expect(at(DateTime(2026, 11, 12, 17), e: e), (HeroBadgeKind.open, 'Înscrieri deschise · ultima zi'));
    expect(at(DateTime(2026, 11, 12, 19), e: e), (HeroBadgeKind.closed, 'Înscrieri închise'));
  });
}
