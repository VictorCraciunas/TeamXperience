import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/event_see_registered_teams/widgets/team_card_widget.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/model/team_member.dart';
import 'package:teamxperience/ui/theme/app_colors.dart';

import '../../ui/pump_ui.dart';

Team _team({List<TeamMember> members = const [], String typed = ''}) => Team(
  name: 'Vulpile',
  teamMembers: typed,
  captainName: 'Victor C',
  phoneNumber: '0722 000 000',
  captainEmail: 'v@example.com',
  userIds: ['u1', 'u2'],
  numberOfMembers: 4,
  members: members,
);

void main() {
  testWidgets('Componență lists the member names and the count says 2 din 4', (
    tester,
  ) async {
    await pumpUi(
      tester,
      TeamCardWidget(
        team: _team(
          members: const [
            TeamMember(uid: 'u1', displayName: 'Victor C', initials: 'VC'),
            TeamMember(uid: 'u2', displayName: 'Ana M', initials: 'AM'),
          ],
        ),
      ),
    );
    expect(find.text('Victor C, Ana M'), findsOneWidget);
    expect(find.text('2 din 4'), findsOneWidget);
  });

  testWidgets('an old team still shows the names typed at registration', (
    tester,
  ) async {
    await pumpUi(
      tester,
      TeamCardWidget(team: _team(typed: 'Ion Popescu, Dan Pop')),
    );
    expect(find.text('Ion Popescu, Dan Pop'), findsOneWidget);
  });

  testWidgets('the initial is dark on the tick colour', (tester) async {
    await pumpUi(tester, TeamCardWidget(team: _team()));
    final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    expect(avatar.backgroundColor, AppColors.light.tick);
    expect(
      tester.widget<Text>(find.text('V')).style?.color,
      AppColors.light.onTick,
    );
  });
}
