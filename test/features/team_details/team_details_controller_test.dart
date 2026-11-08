import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/team_details/controller/team_details_controller.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/model/team_member.dart';
import 'package:teamxperience/model/user.dart';
import 'package:teamxperience/service/team_service/team_service.dart';

class _FakeTeams extends Fake implements TeamService {
  String phone = '0722 000 000';
  Object? saveFailure;
  final saved = <({String eventId, String teamName, String phone})>[];

  Team get team => Team(
    name: 'Vulpile',
    teamMembers: '',
    captainName: 'Victor C',
    phoneNumber: phone,
    captainEmail: 'v@example.com',
    captainUid: 'u1',
    crewId: 'c1',
    members: const [
      TeamMember(uid: 'u1', displayName: 'Victor C', initials: 'VC'),
    ],
    userIds: ['u1'],
  );

  @override
  Future<Team?> getUserTeamForEvent(String eventId, String userId) async =>
      team;

  final codesAsked = <String>[];

  @override
  Future<String?> crewInviteCode(String crewId) async {
    codesAsked.add(crewId);
    return 'VLP482';
  }

  @override
  Future<List<Team>> getTeams(String eventId) async => [team];

  @override
  Future<void> updateTeamPhone(
    String eventId,
    String teamName,
    String phone,
  ) async {
    final error = saveFailure;
    if (error != null) throw error;
    saved.add((eventId: eventId, teamName: teamName, phone: phone));
    this.phone = phone;
  }
}

AppUser _user() => AppUser(
  email: 'v@example.com',
  firstName: 'Victor',
  lastName: 'C',
  uid: 'u1',
  fcmToken: '',
);

Future<TeamControllerDetails> _controller(_FakeTeams teams) async {
  final controller = TeamControllerDetails(
    _user(),
    Event(eventId: 'e1', name: 'Eveniment', dateEvent: DateTime(2030, 1, 1)),
    teamService: teams,
  );
  await controller.initializeTeam();
  controller.populateControllers();
  return controller;
}

void main() {
  test('editing fills in only the phone', () async {
    final controller = await _controller(_FakeTeams());
    expect(controller.phoneController.text, '0722 000 000');
    controller.disposeControllers();
  });

  test(
    'saving writes only the phone, trimmed, and shows it afterwards',
    () async {
      final teams = _FakeTeams();
      final controller = await _controller(teams);
      controller.phoneController.text = ' 0733 111 111 ';

      expect(await controller.savePhone(), isTrue);

      expect(teams.saved, [
        (eventId: 'e1', teamName: 'Vulpile', phone: '0733 111 111'),
      ]);
      expect(controller.team?.phoneNumber, '0733 111 111');
      controller.disposeControllers();
    },
  );

  test('a failed save returns false and keeps the old phone', () async {
    final teams = _FakeTeams()..saveFailure = Exception('offline');
    final controller = await _controller(teams);
    controller.phoneController.text = '0733 111 111';

    expect(await controller.savePhone(), isFalse);

    expect(teams.saved, isEmpty);
    expect(controller.team?.phoneNumber, '0722 000 000');
    controller.disposeControllers();
  });

  test('only the captain gets the invite code', () async {
    final controller = await _controller(_FakeTeams());
    expect(controller.showsInviteCode, isTrue);
    expect(controller.displayInviteCode, 'VLP-482');
    controller.disposeControllers();

    final others = _FakeTeams();
    final other = TeamControllerDetails(
      AppUser(
        email: 'a@example.com',
        firstName: 'Ana',
        lastName: 'M',
        uid: 'u2',
        fcmToken: '',
      ),
      Event(eventId: 'e1', name: 'Eveniment', dateEvent: DateTime(2030, 1, 1)),
      teamService: others,
    );
    await other.initializeTeam();
    expect(other.showsInviteCode, isFalse);
    expect(others.codesAsked, isEmpty, reason: 'only a captain reads it');
    other.disposeControllers();
  });
}
