import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/join_team/logic/join_state.dart';
import 'package:teamxperience/features/join_team/widgets/invite_preview_card.dart';
import 'package:teamxperience/features/join_team/widgets/join_team_body.dart';
import 'package:teamxperience/model/team_member.dart';
import 'package:teamxperience/service/team_service/invite_preview.dart';
import 'package:teamxperience/ui/components/buttons/navy_button.dart';
import 'package:teamxperience/ui/components/inputs/code_box.dart';
import 'package:teamxperience/ui/components/misc/avatar_stack.dart';
import 'package:teamxperience/ui/theme/app_colors.dart';

import '../../ui/pump_ui.dart';

InvitePreview _preview({bool withEvent = true}) => InvitePreview(
  crewId: 'c1',
  crewName: 'Vulpile',
  captainName: 'Victor',
  members: const [
    TeamMember(uid: 'u1', displayName: 'Victor C', initials: 'VC'),
    TeamMember(uid: 'u2', displayName: 'Ana M', initials: 'AM'),
  ],
  alreadyMember: false,
  event:
      withEvent
          ? InviteEvent(
            eventId: 'e1',
            name: 'Moștenirea Cartografului',
            dateEvent: DateTime(2026, 11, 14, 10),
            teamName: 'Vulpile',
            size: 4,
            count: 2,
          )
          : null,
);

Widget _body(
  JoinState state, {
  VoidCallback? onJoin,
  ValueChanged<String>? onCodeChanged,
}) => SizedBox(
  height: 560,
  child: JoinTeamBody(
    state: state,
    onCodeChanged: onCodeChanged ?? (_) {},
    onJoin: onJoin ?? () {},
  ),
);

NavyButton _button(WidgetTester tester) =>
    tester.widget<NavyButton>(find.byType(NavyButton));

void main() {
  testWidgets('Found shows the team as the mockup does', (tester) async {
    await pumpUi(tester, _body(Found(_preview())));
    expect(find.text('Ai primit un cod?'), findsOneWidget);
    expect(find.text('Îl găsești în mesajul de la căpitan.'), findsOneWidget);
    expect(find.text('Moștenirea Cartografului'), findsOneWidget);
    expect(find.text('Vulpile'), findsOneWidget);
    expect(find.text('Căpitan: Victor · Sâm 14 nov, 10:00'), findsOneWidget);
    expect(find.text('2 din 4 · tu ești al 3-lea'), findsOneWidget);
    expect(find.text('Intră în Vulpile'), findsOneWidget);
    expect(
      find.text(
        'Evenimentul apare la Înscrierile tale și primești notificări.',
      ),
      findsOneWidget,
    );
    final stack = tester.widget<AvatarStack>(find.byType(AvatarStack));
    expect(stack.initials, ['VC', 'AM']);
    expect(stack.total, 4);
    expect(stack.highlightNext, isTrue);
    expect(_button(tester).onPressed, isNotNull);
  });

  testWidgets(
    'the card has 14 px beside it, a 64 px strip and the button sits at the bottom',
    (tester) async {
      await pumpUi(tester, _body(Found(_preview())));
      final card = tester.getRect(find.byType(InvitePreviewCard));
      expect(card.left, 14);
      expect(card.right, 360 - 14);
      final strip = tester.getRect(
        find
            .ancestor(
              of: find.text('Moștenirea Cartografului'),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(strip.height, 64);
      expect(strip.top, card.top + 1);
      final button = tester.getRect(find.byType(NavyButton));
      expect(button.left, 14);
      expect(
        tester
            .getRect(
              find.text(
                'Evenimentul apare la Înscrierile tale și primești notificări.',
              ),
            )
            .bottom,
        closeTo(560 - 14, 0.5),
      );
    },
  );

  testWidgets('without an event there is no strip, no date and no slot line', (
    tester,
  ) async {
    await pumpUi(tester, _body(Found(_preview(withEvent: false))));
    expect(find.text('Moștenirea Cartografului'), findsNothing);
    expect(find.text('Căpitan: Victor'), findsOneWidget);
    expect(find.textContaining('tu ești'), findsNothing);
    final stack = tester.widget<AvatarStack>(find.byType(AvatarStack));
    expect(stack.total, 2);
    expect(stack.highlightNext, isFalse);
  });

  for (final state in <JoinState>[
    const Typing(),
    const Looking(),
    const Problem('Codul nu există'),
  ]) {
    testWidgets('${state.runtimeType} shows no team and a greyed button', (
      tester,
    ) async {
      await pumpUi(tester, _body(state));
      expect(find.text('Vulpile'), findsNothing);
      expect(find.text('Intră în echipă'), findsOneWidget);
      expect(_button(tester).onPressed, isNull);
      expect(_button(tester).isLoading, isFalse);
    });
  }

  testWidgets('a Problem is written under the boxes in the danger colour', (
    tester,
  ) async {
    await pumpUi(tester, _body(const Problem('Codul nu există')));
    final text = tester.widget<Text>(find.text('Codul nu există'));
    expect(text.style?.color, AppColors.light.danger);
    final box = find.byKey(const ValueKey('code-box-0'));
    final decoration =
        tester
                .widget<DecoratedBox>(
                  find
                      .descendant(of: box, matching: find.byType(DecoratedBox))
                      .first,
                )
                .decoration
            as BoxDecoration;
    expect((decoration.border as Border).top.color, AppColors.light.danger);
    expect(find.byType(CodeBox), findsNWidgets(6));
  });

  testWidgets('Joining keeps the team and spins the button', (tester) async {
    await pumpUi(tester, _body(Joining(_preview())));
    expect(find.text('Vulpile'), findsOneWidget);
    expect(_button(tester).onPressed, isNull);
    expect(_button(tester).isLoading, isTrue);
  });

  testWidgets('the button calls onJoin and typing reports the code', (
    tester,
  ) async {
    var joined = 0;
    String? typed;
    await pumpUi(
      tester,
      _body(
        Found(_preview()),
        onJoin: () => joined++,
        onCodeChanged: (c) => typed = c,
      ),
    );
    await tester.tap(find.text('Intră în Vulpile'));
    expect(joined, 1);
    await tester.enterText(find.byType(TextField), 'vlp482');
    expect(typed, 'VLP482');
  });

  for (final state in <JoinState>[
    Found(_preview()),
    Found(_preview(withEvent: false)),
    const Problem('Nu a mers. Verifică internetul.'),
  ]) {
    testWidgets(
      'at 320 wide and 1.3x text ${state.runtimeType} lays out without an exception',
      (tester) async {
        await pumpUi(tester, _body(state), width: 320, textScale: 1.3);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
