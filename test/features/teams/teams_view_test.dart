import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/teams/widgets/teams_view.dart';
import 'package:teamxperience/model/crew.dart';
import 'package:teamxperience/model/team_member.dart';
import 'package:teamxperience/ui/components/misc/avatar_stack.dart';
import 'package:teamxperience/ui/components/misc/dashed_border.dart';
import 'package:teamxperience/ui/theme/app_colors.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

import '../../ui/pump_ui.dart';

const _members = [
  TeamMember(uid: 'u1', displayName: 'Victor C', initials: 'VC'),
  TeamMember(uid: 'u2', displayName: 'Ana M', initials: 'AM'),
  TeamMember(uid: 'u3', displayName: 'Ion R', initials: 'IR'),
  TeamMember(uid: 'u4', displayName: 'Dan P', initials: 'DP'),
];

Crew _crew({
  String name = 'Vulpile',
  List<TeamMember> members = _members,
  String captainUid = 'u1',
}) => Crew(
  id: 'c1',
  name: name,
  captainUid: captainUid,
  memberUids: members.map((m) => m.uid).toList(),
  members: members,
  inviteCode: 'VLP482',
);

Widget _view({
  List<Crew>? crews,
  VoidCallback? onNewCrew,
  VoidCallback? onJoin,
  void Function(Crew)? onShare,
  void Function(Crew)? onCopy,
  bool loading = false,
  bool failed = false,
  VoidCallback? onRetry,
}) => SizedBox(
  height: 640,
  child: TeamsView(
    crews: crews ?? [_crew()],
    myUid: 'u1',
    onNewCrew: onNewCrew ?? () {},
    onJoin: onJoin ?? () {},
    onShare: onShare ?? (_) {},
    onCopy: onCopy ?? (_) {},
    loading: loading,
    failed: failed,
    onRetry: onRetry ?? () {},
  ),
);

void main() {
  testWidgets('a crew shows as the mockup does', (tester) async {
    await pumpUi(tester, _view());
    expect(find.text('Echipe'), findsOneWidget);
    expect(find.text('Echipă nouă'), findsOneWidget);
    expect(find.text('Vulpile'), findsOneWidget);
    expect(find.text('Căpitan: Victor C · 4 membri'), findsOneWidget);
    expect(find.text('Cod invitație'), findsOneWidget);
    expect(find.text('VLP-482'), findsOneWidget);
    expect(find.text('Ai primit un cod de la altă echipă?'), findsOneWidget);
    expect(find.text('Intră'), findsOneWidget);
    expect(find.text('Nu ești încă într-o echipă.'), findsNothing);
  });

  testWidgets('the avatars are the members, at most four, 28 across, on navy', (
    tester,
  ) async {
    final five = [
      ..._members,
      const TeamMember(uid: 'u5', displayName: 'Eva T', initials: 'ET'),
    ];
    await pumpUi(tester, _view(crews: [_crew(members: five)]));
    final stack = tester.widget<AvatarStack>(find.byType(AvatarStack));
    expect(stack.initials, ['VC', 'AM', 'IR', 'DP']);
    expect(stack.total, 4);
    expect(stack.size, 28);
    expect(stack.onDark, isTrue);
    expect(find.text('Căpitan: Victor C · 5 membri'), findsOneWidget);
  });

  testWidgets('one member is "1 membru" with one circle and no empty places', (
    tester,
  ) async {
    await pumpUi(
      tester,
      _view(crews: [_crew(members: _members.take(1).toList())]),
    );
    expect(find.text('Căpitan: Victor C · 1 membru'), findsOneWidget);
    expect(tester.widget<AvatarStack>(find.byType(AvatarStack)).total, 1);
  });

  testWidgets(
    'a captain who is not among the members is left out of the line',
    (tester) async {
      await pumpUi(tester, _view(crews: [_crew(captainUid: 'gone')]));
      expect(find.text('4 membri'), findsOneWidget);
    },
  );

  testWidgets('the code sits in a dashed box at 35% onNavy over an 8% fill', (
    tester,
  ) async {
    await pumpUi(tester, _view());
    final dashed = tester.widget<DashedBorder>(
      find.descendant(
        of: find.byKey(const ValueKey('crew-card')),
        matching: find.byType(DashedBorder),
      ),
    );
    expect(dashed.color, AppColors.light.onNavy.withValues(alpha: .35));
    expect(dashed.fill, AppColors.light.onNavy.withValues(alpha: .08));
    expect(dashed.radius, 12);
    expect(dashed.width, 1);
    final code = tester.widget<Text>(find.text('VLP-482'));
    expect(code.style?.fontFamily, 'Monospace');
    expect(code.style?.letterSpacing, 2);
  });

  testWidgets('"Intră" and the card around it call onJoin', (tester) async {
    var joins = 0;
    await pumpUi(tester, _view(onJoin: () => joins++));
    await tester.tap(find.text('Intră'));
    expect(joins, 1);
    await tester.tap(find.text('Ai primit un cod de la altă echipă?'));
    expect(joins, 2);
  });

  testWidgets('"Echipă nouă" calls onNewCrew', (tester) async {
    var taps = 0;
    await pumpUi(tester, _view(onNewCrew: () => taps++));
    await tester.tap(find.text('Echipă nouă'));
    expect(taps, 1);
  });

  testWidgets(
    'the share and copy icons call onShare and onCopy with the crew',
    (tester) async {
      final shared = <String>[];
      final copied = <String>[];
      await pumpUi(
        tester,
        _view(
          onShare: (crew) => shared.add(crew.id),
          onCopy: (crew) => copied.add(crew.id),
        ),
      );
      await tester.tap(find.byIcon(TablerIcons.share));
      await tester.tap(find.byIcon(TablerIcons.copy));
      expect(shared, ['c1']);
      expect(copied, ['c1']);
    },
  );

  testWidgets('with no crews: the empty text and the same two actions', (
    tester,
  ) async {
    var joins = 0;
    var news = 0;
    await pumpUi(
      tester,
      _view(crews: const [], onJoin: () => joins++, onNewCrew: () => news++),
    );
    expect(find.text('Nu ești încă într-o echipă.'), findsOneWidget);
    expect(find.byType(AvatarStack), findsNothing);
    await tester.tap(find.text('Intră'));
    await tester.tap(find.text('Echipă nouă'));
    expect(joins, 1);
    expect(news, 1);
  });

  for (final (name, theme) in [
    ('light', AppTheme.light),
    ('dark', AppTheme.dark),
  ]) {
    testWidgets('lays out in the $name theme with two crews', (tester) async {
      await pumpUi(
        tester,
        _view(crews: [_crew(), _crew(name: 'Bufnițele')]),
        theme: theme,
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Bufnițele'), findsOneWidget);
    });
  }

  testWidgets('at 320 wide and 1.3x text nothing overflows', (tester) async {
    await pumpUi(
      tester,
      _view(
        crews: [
          _crew(name: 'Vulpile Argintii din Cluj-Napoca de la Nord'),
          _crew(members: _members.take(1).toList()),
        ],
      ),
      width: 320,
      textScale: 1.3,
    );
    expect(tester.takeException(), isNull);
    await pumpUi(tester, _view(crews: const []), width: 320, textScale: 1.3);
    expect(tester.takeException(), isNull);
  });

  testWidgets('on error the header and the join card stay, with a retry', (
    tester,
  ) async {
    var retries = 0;
    var joins = 0;
    await pumpUi(
      tester,
      _view(
        crews: const [],
        failed: true,
        onRetry: () => retries++,
        onJoin: () => joins++,
      ),
    );
    expect(find.text('Echipe'), findsOneWidget);
    expect(find.text('Echipă nouă'), findsOneWidget);
    expect(find.text('Intră'), findsOneWidget);
    expect(find.text('Nu am putut încărca echipele.'), findsOneWidget);
    expect(find.text('Nu ești încă într-o echipă.'), findsNothing);
    await tester.tap(find.text('Încearcă din nou'));
    expect(retries, 1);
    await tester.tap(find.text('Intră'));
    expect(joins, 1);
  });

  testWidgets('while loading the header and the join card stay', (
    tester,
  ) async {
    await pumpUi(tester, _view(crews: const [], loading: true));
    expect(find.text('Echipe'), findsOneWidget);
    expect(find.text('Intră'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Nu ești încă într-o echipă.'), findsNothing);
  });
}
