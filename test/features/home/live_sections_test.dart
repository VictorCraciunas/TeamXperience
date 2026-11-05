import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/home/widgets/leaderboard_sheet.dart';
import 'package:teamxperience/features/home/widgets/live_leaderboard_section.dart';
import 'package:teamxperience/features/home/widgets/team_now_card.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/model/team_member.dart';
import 'package:teamxperience/service/leaderboard.dart';
import 'package:teamxperience/ui/components/misc/avatar_stack.dart';

import '../../ui/pump_ui.dart';

Team _team(String name, int progress, {List<TeamMember> members = const [], Map<String, DateTime>? presence, Map<int, DateTime>? done}) => Team(
      name: name,
      teamMembers: '',
      captainName: '',
      phoneNumber: '',
      captainEmail: '',
      missionProgress: progress,
      hasStarted: true,
      members: members,
      presence: presence,
      missionCompletedAt: done,
    );

/// Mockup 02's board: Bufnițele 5/6, Vulpile 4/6 (us), Lupii de Cetate 4/6, and two more.
List<RankedTeam> _ranked() => rankTeams([
      _team('Bufnițele', 4),
      _team('Vulpile', 3, done: {2: DateTime(2026, 11, 14, 10, 40)}),
      _team('Lupii de Cetate', 3, done: {2: DateTime(2026, 11, 14, 10, 50)}),
      _team('Corbii', 1),
      _team('Zimbrii', 0),
    ], missionCount: 6);

void main() {
  testWidgets('Clasament live: three rows, the own one marked "voi", and Tot', (tester) async {
    await pumpUi(
      tester,
      LiveLeaderboardSection(ranked: _ranked(), ownName: 'Vulpile', missionCount: 6, onAll: () {}),
    );
    expect(find.text('Clasament live'), findsOneWidget);
    expect(find.text('Tot'), findsOneWidget);
    expect(find.text('Bufnițele'), findsOneWidget);
    expect(find.text('5/6'), findsOneWidget);
    expect(find.text('Vulpile · voi'), findsOneWidget);
    expect(find.text('4/6'), findsNWidgets(2));
    expect(find.text('Lupii de Cetate'), findsOneWidget);
    expect(find.text('Corbii'), findsNothing);
  });

  testWidgets('Tot calls back', (tester) async {
    var all = 0;
    await pumpUi(
      tester,
      LiveLeaderboardSection(ranked: _ranked(), ownName: 'Vulpile', missionCount: 6, onAll: () => all++),
    );
    await tester.tap(find.text('Tot'));
    expect(all, 1);
  });

  testWidgets('without missions the score is a dash', (tester) async {
    await pumpUi(
      tester,
      LiveLeaderboardSection(
        ranked: rankTeams([_team('Vulpile', 0)], missionCount: 0),
        ownName: 'Vulpile',
        missionCount: 0,
        onAll: () {},
      ),
    );
    expect(find.text('–'), findsOneWidget);
  });

  testWidgets('own team missing from the teams: no leaderboard', (tester) async {
    await pumpUi(
      tester,
      LiveLeaderboardSection(ranked: _ranked(), ownName: 'Redenumită', missionCount: 6, onAll: () {}),
    );
    expect(find.text('Clasament live'), findsNothing);
  });

  testWidgets('the sheet lists every team', (tester) async {
    await pumpUi(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () => showLeaderboardSheet(context, ranked: _ranked(), ownName: 'Vulpile', missionCount: 6),
          child: const Text('deschide'),
        ),
      ),
    );
    await tester.tap(find.text('deschide'));
    await tester.pumpAndSettle();
    for (final name in ['Bufnițele', 'Vulpile · voi', 'Lupii de Cetate', 'Corbii', 'Zimbrii']) {
      expect(find.text(name), findsOneWidget);
    }
  });

  group('Echipa ta', () {
    final now = DateTime(2026, 11, 14, 11);
    const members = [
      TeamMember(uid: 'v', displayName: 'Victor C', initials: 'VC'),
      TeamMember(uid: 'a', displayName: 'Ana M', initials: 'AM'),
      TeamMember(uid: 'i', displayName: 'Ion R', initials: 'IR'),
    ];

    testWidgets('who is playing and when the last mission was solved', (tester) async {
      final team = _team('Vulpile', 3, members: members, presence: {
        'v': now.subtract(const Duration(minutes: 1)),
        'a': now.subtract(const Duration(seconds: 30)),
        'i': now.subtract(const Duration(minutes: 5)),
      }, done: {
        2: now.subtract(const Duration(minutes: 6)),
      });
      await pumpUi(tester, TeamNowCard(team: team, now: now));
      expect(find.text('Echipa ta'), findsOneWidget);
      expect(find.text('2 jucători activi'), findsOneWidget);
      expect(find.text('Ultima misiune rezolvată acum 6 min'), findsOneWidget);
      expect(tester.widget<AvatarStack>(find.byType(AvatarStack)).initials, ['VC', 'AM']);
    });

    testWidgets('nobody here: no avatars', (tester) async {
      await pumpUi(tester, TeamNowCard(team: _team('Vulpile', 0, members: members), now: now));
      expect(find.text('Niciun jucător activ acum'), findsOneWidget);
      expect(find.text('Nicio misiune rezolvată încă'), findsOneWidget);
      expect(find.byType(AvatarStack), findsNothing);
    });
  });
}
