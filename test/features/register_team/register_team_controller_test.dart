import 'package:teamxperience/model/team_member.dart';
import 'package:teamxperience/model/user.dart';
import 'package:teamxperience/model/crew.dart';
import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/features/register_team/controller/register_team_controller.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/service/share_service.dart';
import 'package:teamxperience/service/team_service/register_result.dart';
import 'package:teamxperience/service/team_service/team_service.dart';
import 'package:teamxperience/state_management/user_provider.dart';
import 'package:teamxperience/ui/components/feedback/field_status_line.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

class _FakeTeams extends Fake implements TeamService {
  bool? free = true;
  Object? failure;
  Completer<void>? hold;
  final registered = <Map<String, Object?>>[];
  List<Crew> crews = const [];

  @override
  Stream<List<Crew>> streamUserCrews(String uid) => Stream.value(crews);

  @override
  Future<bool?> isTeamNameFree(String eventId, String name) async => free;

  @override
  Future<RegisterResult> registerTeam({
    required String eventId,
    required String name,
    required int size,
    required String phone,
    required bool rulesAccepted,
    required bool photoConsent,
    String? crewId,
  }) async {
    registered.add({
      'eventId': eventId,
      'name': name,
      'size': size,
      'phone': phone,
      'rules': rulesAccepted,
      'photo': photoConsent,
      if (crewId != null) 'crewId': crewId,
    });
    await hold?.future;
    final error = failure;
    if (error != null) throw error;
    return const RegisterResult(
      teamName: 'Vulpile',
      crewId: 'c1',
      inviteCode: 'VLP482',
      skippedUids: [],
    );
  }
}

class _FakeShare extends Fake implements ShareService {
  final shared = <({String code, String teamName, String eventName})>[];

  @override
  Future<void> shareInvite(
    BuildContext context, {
    required String code,
    required String teamName,
    required String eventName,
  }) async {
    shared.add((code: code, teamName: teamName, eventName: eventName));
  }
}

class _RecordingUser extends UserProvider {
  final added = <String>[];

  @override
  void addRegisteredEvent(String eventId) => added.add(eventId);

  @override
  AppUser? get currentUser =>
      AppUser(email: 'a@b.ro', firstName: 'A', lastName: 'B', uid: 'u1', fcmToken: '');
}

Crew _crew(String id, {String captain = 'u1', int members = 2}) => Crew(
  id: id,
  name: 'Crew $id',
  captainUid: captain,
  memberUids: [for (var i = 0; i < members; i++) 'u$i'],
  members: [
    for (var i = 0; i < members; i++)
      TeamMember(uid: 'u$i', displayName: 'P $i', initials: 'P'),
  ],
  inviteCode: 'VLP482',
);

Event _event({int min = 2, int max = 6}) => Event(
  eventId: 'e1',
  name: 'Moștenirea Cartografului',
  dateEvent: DateTime(2026, 11, 14, 10),
  teamSizeMin: min,
  teamSizeMax: max,
);

class _Harness {
  _Harness(this.tester);

  final WidgetTester tester;
  final teams = _FakeTeams();
  final share = _FakeShare();
  final user = _RecordingUser();
  final routes = <String>[];
  late RegisterTeamController controller;

  Future<void> pump({Event? event}) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<UserProvider>.value(
        value: user,
        child: MaterialApp(
          theme: AppTheme.light,
          navigatorObservers: [_Routes(routes)],
          onGenerateRoute: (settings) {
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (context) {
                if (settings.name == 'register') {
                  controller = RegisterTeamController(
                    context: context,
                    event: event ?? _event(),
                    teamService: teams,
                    shareService: share,
                  );
                }
                return const Scaffold(body: SizedBox());
              },
            );
          },
          initialRoute: '/',
        ),
      ),
    );
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed('register');
    await tester.pumpAndSettle();
  }

  Future<void> fillIn({
    String name = 'Vulpile',
    String phone = '0722 123 456',
    bool rules = true,
  }) async {
    controller.nameController.text = name;
    controller.onNameChanged(name);
    await tester.pump(const Duration(milliseconds: 400));
    controller.phoneController.text = phone;
    controller.onPhoneChanged(phone);
    controller.setRulesAccepted(rules);
  }
}

class _Routes extends NavigatorObserver {
  _Routes(this.names);

  final List<String> names;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      names.add('push ${route.settings.name}');

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      names.add('pop ${route.settings.name}');
}

void main() {
  group('starting size', () {
    for (final (min, max, expected) in [
      (2, 6, 4),
      (2, 3, 3),
      (5, 8, 5),
      (4, 4, 4),
      (2, 4, 4),
    ]) {
      testWidgets('an event of $min to $max starts at $expected', (
        tester,
      ) async {
        final h = _Harness(tester);
        await h.pump(event: _event(min: min, max: max));
        expect(h.controller.size, expected);
      });
    }
  });

  group('blocker', () {
    testWidgets('names the first thing missing, in order', (tester) async {
      final h = _Harness(tester);
      await h.pump();
      final c = h.controller;

      expect(c.blocker, 'Scrie numele echipei');
      expect(c.canSubmit, isFalse);

      c.nameController.text = 'A';
      c.onNameChanged('A');
      expect(c.blocker, 'Numele are 2–30 de litere, fără /');

      c.nameController.text = 'Vulpile';
      c.onNameChanged('Vulpile');
      expect(c.nameStatus, FieldStatus.checking);
      expect(c.blocker, 'Verificăm numele…');

      await tester.pump(const Duration(milliseconds: 400));
      expect(c.nameStatus, FieldStatus.ok);
      expect(c.blocker, 'Scrie telefonul căpitanului');

      c.phoneController.text = '0722 123 456';
      c.onPhoneChanged('0722 123 456');
      expect(c.blocker, 'Acceptă regulamentul');

      c.setRulesAccepted(true);
      expect(c.blocker, isNull);
      expect(c.canSubmit, isTrue);
    });

    testWidgets('a taken name blocks', (tester) async {
      final h = _Harness(tester);
      await h.pump();
      h.teams.free = false;
      await h.fillIn();
      expect(h.controller.blocker, 'Numele e luat');
    });

    testWidgets('the photo consent is not required', (tester) async {
      final h = _Harness(tester);
      await h.pump();
      await h.fillIn();
      expect(h.controller.photoConsent, isFalse);
      expect(h.controller.blocker, isNull);
    });

    testWidgets('changing the name again blocks until it is checked', (
      tester,
    ) async {
      final h = _Harness(tester);
      await h.pump();
      await h.fillIn();
      h.controller.onNameChanged('Vulpi');
      expect(h.controller.blocker, isNotNull);
      await tester.pump(const Duration(milliseconds: 400));
      expect(h.controller.blocker, isNull);
    });
  });

  group('submit', () {
    testWidgets('registers the cleaned name and shows the code', (
      tester,
    ) async {
      final h = _Harness(tester);
      await h.pump();
      await h.fillIn(name: '  Vulpile  ');
      h.controller.setSize(5);
      h.controller.setPhotoConsent(true);

      await h.controller.submit();

      expect(h.teams.registered, [
        {
          'eventId': 'e1',
          'name': 'Vulpile',
          'size': 5,
          'phone': '0722 123 456',
          'rules': true,
          'photo': true,
        },
      ]);
      expect(h.user.added, ['e1']);
      expect(h.controller.registered, isTrue);
      expect(h.controller.displayInviteCode, 'VLP-482');
      expect(h.controller.sending, isFalse);
      expect(h.controller.canSubmit, isFalse);
    });

    testWidgets('a captain\'s crews that fit are offered', (tester) async {
      final h = _Harness(tester);
      h.teams.crews = [
        _crew('mine'),
        _crew('theirs', captain: 'someone'),
        _crew('huge', members: 40),
      ];
      await h.pump();
      await tester.pumpAndSettle();
      expect(h.controller.crews.map((c) => c.id), ['mine']);
      expect(h.controller.chosenCrew, isNull);
    });

    testWidgets('choosing a crew takes its name and room for everyone, and registers it', (tester) async {
      final h = _Harness(tester);
      h.teams.crews = [_crew('mine', members: 3)];
      await h.pump(event: Event(eventId: 'e1', name: 'Harta', teamSizeMin: 2, teamSizeMax: 6));
      await tester.pumpAndSettle();
      await h.fillIn(name: 'Vulpile');
      h.controller.setSize(2);
      h.controller.chooseCrew(h.controller.crews.single);
      await tester.pump(const Duration(milliseconds: 400));
      expect(h.controller.nameController.text, 'Crew mine');
      expect(h.controller.sizeMin, 3);
      expect(h.controller.size, greaterThanOrEqualTo(3));
      await h.controller.submit();
      expect(h.teams.registered.single['crewId'], 'mine');
    });

    testWidgets('going back to a new team sends no crew', (tester) async {
      final h = _Harness(tester);
      h.teams.crews = [_crew('mine')];
      await h.pump();
      await tester.pumpAndSettle();
      h.controller.chooseCrew(h.controller.crews.single);
      h.controller.chooseCrew(null);
      await h.fillIn(name: 'Vulpile');
      await h.controller.submit();
      expect(h.teams.registered.single.containsKey('crewId'), isFalse);
    });

    testWidgets('does nothing while the blocker is set', (tester) async {
      final h = _Harness(tester);
      await h.pump();
      await h.controller.submit();
      expect(h.teams.registered, isEmpty);
    });

    testWidgets('does nothing while sending, and once registered', (
      tester,
    ) async {
      final h = _Harness(tester);
      await h.pump();
      await h.fillIn();
      h.teams.hold = Completer<void>();

      final first = h.controller.submit();
      await tester.pump();
      expect(h.controller.sending, isTrue);
      await h.controller.submit();
      expect(h.teams.registered, hasLength(1));

      h.teams.hold?.complete();
      await first;
      expect(h.controller.sending, isFalse);

      await h.controller.submit();
      expect(h.teams.registered, hasLength(1));
    });

    testWidgets('an error shows its text and leaves the form open', (
      tester,
    ) async {
      final h = _Harness(tester);
      await h.pump();
      await h.fillIn();
      h.teams.failure = FirebaseFunctionsException(
        message: 'x',
        code: 'unavailable',
      );

      await h.controller.submit();
      await tester.pump();

      expect(find.text('Nu am putut înscrie echipa'), findsOneWidget);
      expect(find.text('Nu a mers. Verifică internetul.'), findsOneWidget);
      expect(h.controller.registered, isFalse);
      expect(h.controller.sending, isFalse);
      expect(h.user.added, isEmpty);
      await tester.pumpAndSettle(const Duration(seconds: 4));
    });

    testWidgets('a taken name is marked on the field', (tester) async {
      final h = _Harness(tester);
      await h.pump();
      await h.fillIn();
      h.teams.failure = FirebaseFunctionsException(
        message: 'x',
        code: 'failed-precondition',
        details: {'reason': 'nameTaken'},
      );

      await h.controller.submit();
      await tester.pump();

      expect(find.text('Numele e luat'), findsOneWidget);
      expect(h.controller.nameStatus, FieldStatus.problem);
      expect(h.controller.nameStatusText, 'Numele e luat');
      await tester.pumpAndSettle(const Duration(seconds: 4));
    });
  });

  group('the invite code', () {
    testWidgets('share sends the displayed code, the team and the event', (
      tester,
    ) async {
      final h = _Harness(tester);
      await h.pump();
      await h.fillIn();
      await h.controller.submit();

      h.controller.shareInvite();

      expect(h.share.shared, [
        (
          code: 'VLP-482',
          teamName: 'Vulpile',
          eventName: 'Moștenirea Cartografului',
        ),
      ]);
    });

    testWidgets('share does nothing before the team is made', (tester) async {
      final h = _Harness(tester);
      await h.pump();
      h.controller.shareInvite();
      expect(h.share.shared, isEmpty);
    });

    testWidgets('copy puts the displayed code on the clipboard and says so', (
      tester,
    ) async {
      final h = _Harness(tester);
      await h.pump();
      await h.fillIn();
      await h.controller.submit();

      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String?;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );

      await h.controller.copyInvite();
      await tester.pump();

      expect(copied, 'VLP-482');
      expect(find.text('Cod copiat'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 4));
    });
  });

  group('close', () {
    testWidgets('before the team is made it goes back', (tester) async {
      final h = _Harness(tester);
      await h.pump();
      h.routes.clear();

      h.controller.close();
      await tester.pumpAndSettle();

      expect(h.routes, ['pop register']);
    });

    testWidgets('after the team is made it opens the event page afresh', (
      tester,
    ) async {
      final h = _Harness(tester);
      await h.pump();
      await h.fillIn();
      await h.controller.submit();
      h.routes.clear();

      h.controller.close();
      await tester.pumpAndSettle();

      expect(h.routes, ['pop register', 'push ${Routes.eventDetails}']);
    });
  });
}
