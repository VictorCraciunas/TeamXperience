import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/dev/sample_event.dart';
import 'package:teamxperience/features/home/widgets/events_grid_section.dart';
import 'package:teamxperience/features/home/widgets/greeting_stats.dart';
import 'package:teamxperience/features/home/widgets/home_header.dart';
import 'package:teamxperience/features/home/widgets/live_game_card.dart';
import 'package:teamxperience/features/home/widgets/live_leaderboard_section.dart';
import 'package:teamxperience/features/home/widgets/next_game_card.dart';
import 'package:teamxperience/features/home/widgets/team_now_card.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/model/team_member.dart';
import 'package:teamxperience/service/leaderboard.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

import '../../ui/pump_ui.dart';

const _members = [
  TeamMember(uid: 'v', displayName: 'Victor C', initials: 'VC'),
  TeamMember(uid: 'a', displayName: 'Ana M', initials: 'AM'),
  TeamMember(uid: 'i', displayName: 'Ion R', initials: 'IR'),
  TeamMember(uid: 'd', displayName: 'Dan P', initials: 'DP'),
];

Team _team({int progress = 3, Map<String, DateTime>? presence}) => Team(
      name: 'Vulpile',
      teamMembers: '',
      captainName: 'Victor',
      phoneNumber: '',
      captainEmail: '',
      numberOfMembers: 4,
      missionProgress: progress,
      hasStarted: true,
      members: _members,
      presence: presence,
    );

void main() {
  group('HomeHeader', () {
    testWidgets('the brand, and the bell with its dot only when there is unread news', (tester) async {
      var bells = 0;
      await pumpUi(tester, HomeHeader(unread: true, onBell: () => bells++));
      expect(find.text('TeamXperience'), findsOneWidget);
      expect(find.byKey(const ValueKey('bell-dot')), findsOneWidget);
      expect(tester.getSize(find.byKey(const ValueKey('bell'))), const Size(32, 32));
      await tester.tap(find.byKey(const ValueKey('bell')));
      expect(bells, 1);

      await pumpUi(tester, HomeHeader(unread: false, onBell: () {}));
      expect(find.byKey(const ValueKey('bell-dot')), findsNothing);
    });
  });

  testWidgets('GreetingStats: the name, games, distance and level', (tester) async {
    await pumpUi(tester, const GreetingStats(firstName: 'Victor', games: 3, distanceMeters: 12400, xp: 800));
    for (final t in ['Salut, Victor', '3', 'jocuri', '12,4 km', 'pe jos', 'Explorator']) {
      expect(find.text(t), findsOneWidget);
    }
  });

  for (final theme in [AppTheme.light, AppTheme.dark]) {
    testWidgets('both Home layouts fit 320 px at 1.3x text (${theme.brightness.name})', (tester) async {
      final event = sampleEvent();
      final live = DateTime(2026, 11, 14, 11, 42, 18);
      final team = _team(presence: {for (final m in _members.take(3)) m.uid: live});
      final ranked = rankTeams([team, _team(progress: 4)._rename('Bufnițele')], missionCount: 6);

      Widget page(List<Widget> children) => SingleChildScrollView(child: Column(children: children));

      await pumpUi(
        tester,
        page([
          HomeHeader(unread: true, onBell: () {}),
          const GreetingStats(firstName: 'Victor-Alexandru', games: 3, distanceMeters: 12400, xp: 800),
          NextGameCard(
            event: event,
            left: const Duration(days: 3, hours: 14, minutes: 22),
            now: DateTime(2026, 11, 10, 19, 38),
            team: _team(),
            onTap: () {},
          ),
          EventsGridSection(title: 'Evenimente noi', link: 'Vezi toate', onLink: () {}, events: sampleOpenEvents(), onTap: (_) {}),
        ]),
        width: 320,
        textScale: 1.3,
        theme: theme,
      );
      expect(tester.takeException(), isNull);

      await pumpUi(
        tester,
        page([
          HomeHeader(unread: false, onBell: () {}),
          const GreetingStats(firstName: 'Victor', games: 3, distanceMeters: 12400, xp: 800),
          LiveGameCard(event: event, team: team, now: live, onContinue: () {}, onChat: () {}),
          LiveLeaderboardSection(ranked: ranked, ownName: 'Vulpile', missionCount: 6, onAll: () {}),
          TeamNowCard(team: team, now: live),
        ]),
        width: 320,
        textScale: 1.3,
        theme: theme,
      );
      expect(tester.takeException(), isNull);
    });
  }
}

extension on Team {
  /// A copy under another name, for a second team on the board.
  Team _rename(String name) => Team(
        name: name,
        teamMembers: teamMembers,
        captainName: captainName,
        phoneNumber: phoneNumber,
        captainEmail: captainEmail,
        missionProgress: missionProgress,
        hasStarted: hasStarted,
      );
}
