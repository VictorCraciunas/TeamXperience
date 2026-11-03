import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/event_details/logic/signup_bar_state.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';

Event _event({bool stopped = false, int? maxTeams}) => Event(
      eventId: 'e',
      dateEvent: DateTime(2026, 11, 14, 10),
      dateStartEnrollment: DateTime(2026, 11, 1),
      dateDeadlineEnrollment: DateTime(2026, 11, 12),
      isStopped: stopped,
      maxTeams: maxTeams,
    );

Team _team({int members = 4, bool started = false, bool finished = false}) => Team(
      name: 'Vulpile',
      teamMembers: '',
      captainName: 'Victor',
      phoneNumber: '',
      captainEmail: '',
      numberOfMembers: members,
    )
      ..hasStarted = started
      ..hasFinished = finished;

void main() {
  SignupBar bar(DateTime now, {Event? e, Team? team, int teams = 12}) =>
      signupBar(event: e ?? _event(), now: now, team: team, teamsCount: teams);

  final open = DateTime(2026, 11, 7, 18);

  test('open: days left, teams registered, register', () {
    final b = bar(open);
    expect((b.title, b.detail, b.prominent, b.actionLabel, b.action),
        ('Mai sunt 5 zile', '12 echipe înscrise', true, 'Înscrie echipa', SignupAction.register));
  });

  test('open: one day, the last day, and team counts of 1 and 0', () {
    expect(bar(DateTime(2026, 11, 11)).title, 'Mai e o zi');
    expect(bar(DateTime(2026, 11, 12, 22)).title, 'Ultima zi');
    expect(bar(open, teams: 1).detail, 'o echipă înscrisă');
    expect(bar(open, teams: 0).detail, 'Fii prima echipă');
  });

  test('registered: team name, members inline, Echipa ta', () {
    final b = bar(open, team: _team());
    expect((b.title, b.detail, b.inlineDetail, b.tone, b.prominent, b.actionLabel, b.action),
        ('Vulpile', '4 membri', true, SignupTone.success, false, 'Echipa ta', SignupAction.teamDetails));
    expect(bar(open, team: _team(members: 1)).detail, '1 membru');
  });

  test('registered inside the enter window: minutes left, enter the code', () {
    final b = bar(DateTime(2026, 11, 14, 10, 18), team: _team());
    expect((b.title, b.detail, b.inlineDetail, b.tone, b.highlighted, b.actionLabel, b.action),
        ('A început', '42 min să intri', true, SignupTone.accent, true, 'Introdu codul', SignupAction.enterCode));
    expect(bar(DateTime(2026, 11, 14, 10, 18, 30), team: _team()).detail, '42 min să intri');
  });

  test('a team in play continues the game', () {
    final b = bar(DateTime(2026, 11, 14, 10, 30), team: _team(started: true));
    expect((b.title, b.tone, b.highlighted, b.actionLabel, b.action),
        ('Echipa Vulpile e în joc', SignupTone.accent, true, 'Continuă', SignupAction.continueGame));
  });

  test('a finished team before the end sees its team', () {
    expect(bar(DateTime(2026, 11, 14, 12), team: _team(started: true, finished: true)).action, SignupAction.teamDetails);
  });

  test('before enrolment opens', () {
    final b = bar(DateTime(2026, 10, 30));
    expect((b.title, b.actionLabel, b.action), ('Înscrierile se deschid pe 1 nov', null, SignupAction.none));
  });

  test('after the deadline without a team', () {
    final b = bar(DateTime(2026, 11, 13));
    expect((b.title, b.detail, b.action), ('Înscrierile s-au închis', '12 echipe înscrise', SignupAction.none));
  });

  test('no places left', () {
    final b = bar(open, e: _event(maxTeams: 12));
    expect((b.title, b.detail, b.action), ('Nu mai sunt locuri', '12 echipe înscrise', SignupAction.none));
    expect(bar(open, e: _event(maxTeams: 13)).action, SignupAction.register);
  });

  test('over: stopped, or 3 hours after the start', () {
    expect(bar(open, e: _event(stopped: true), team: _team()).title, 'Evenimentul s-a încheiat');
    expect(bar(DateTime(2026, 11, 14, 13, 1), team: _team(started: true)).action, SignupAction.none);
  });

  test('a user whose team was deleted sees the open or closed bar', () {
    expect(bar(open, team: null).action, SignupAction.register);
    expect(bar(DateTime(2026, 11, 14, 10, 18), team: null).title, 'Înscrierile s-au închis');
  });
}
