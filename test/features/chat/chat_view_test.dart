import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/message_type.dart';
import 'package:teamxperience/enums/photo_approval_status.dart';
import 'package:teamxperience/enums/role.dart';
import 'package:teamxperience/features/chat/logic/chat_timeline.dart';
import 'package:teamxperience/features/chat/widgets/chat_composer.dart';
import 'package:teamxperience/features/chat/widgets/chat_view.dart';
import 'package:teamxperience/features/chat/widgets/organiser_chat_header.dart';
import 'package:teamxperience/features/chat/widgets/player_chat_header.dart';
import 'package:teamxperience/model/message.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/model/team_member.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

final _now = DateTime(2026, 11, 14, 12);

final _team = Team(
  name: 'Lupii de Cetate din Piața Mare',
  teamMembers: '',
  captainName: 'Ana',
  phoneNumber: '0722',
  captainEmail: '',
  captainUid: 'u1',
  members: const [
    TeamMember(uid: 'u1', displayName: 'Ana Pop', initials: 'AP'),
    TeamMember(uid: 'u2', displayName: 'Mihai Dima', initials: 'MD'),
  ],
  missionCompletedAt: {2: DateTime(2026, 11, 14, 10, 40)},
  photoApprovals: {'2_1_5': PhotoApprovalStatus.pending, '2_0_1': PhotoApprovalStatus.approved},
);

const _long = 'Am ajuns la statuie, dar nu găsim plăcuța nicăieri, am căutat peste tot în jurul soclului.';

List<ChatMessageDoc> _messages() {
  Message m(Role sender, int minute, {String text = _long, String? uid, String? name, bool announcement = false}) =>
      Message(
        sender: sender,
        text: text,
        timestamp: DateTime(2026, 11, 14, 10, minute),
        senderUid: uid,
        senderName: name,
        announcement: announcement,
      );
  Message photo(int minute, String key, String uid, String name) => Message(
        sender: Role.USER,
        text: 'Fotografie',
        timestamp: DateTime(2026, 11, 14, 10, minute),
        type: MessageType.image,
        imageUrl: '',
        approvalKey: key,
        senderUid: uid,
        senderName: name,
      );
  return [
    ChatMessageDoc('a', m(Role.ADMIN, 30, text: 'Finalul se mută la poarta de nord a Pieței Mici.', announcement: true)),
    ChatMessageDoc('b', m(Role.USER, 46, uid: 'u1', name: 'Ana')),
    ChatMessageDoc('c', m(Role.ADMIN, 48, text: 'E pe spatele soclului, în partea dinspre fântână.')),
    ChatMessageDoc('d', photo(52, '2_1_5', 'u2', 'Mihai')),
    ChatMessageDoc('e', photo(53, '2_0_1', 'u1', 'Ana')),
    ChatMessageDoc('f', m(Role.USER, 56, uid: 'u2', name: 'Mihai', text: 'Ușa e închisă, ce facem?')),
  ];
}

Future<void> _pump(WidgetTester tester, {required bool organiser, ThemeData? theme}) async {
  tester.view.physicalSize = const Size(320, 640);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final entries = chatTimeline(messages: _messages(), team: _team, organiserView: organiser, myUid: 'u1', now: _now);
  final header = organiser
      ? OrganiserChatHeader(
          teamName: _team.name,
          teamInitial: 'L',
          members: 'Ana, Mihai, Radu, Ioana, Cristian',
          onBack: () {},
          onMap: null,
          onCall: () {},
          strip: (text: 'Misiunea 4 din 6', total: 6, done: 3, current: 3),
        )
      : PlayerChatHeader(subtitle: 'Moștenirea Cartografului · ${_team.name}', onBack: () {});
  await tester.pumpWidget(MaterialApp(
    theme: theme ?? AppTheme.light,
    builder: (context, app) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(2)),
      child: app ?? const SizedBox.shrink(),
    ),
    home: Scaffold(
      body: ChatView(
        header: header,
        entries: entries,
        loading: false,
        emptyText: 'Niciun mesaj încă.',
        onApprove: (_) {},
        onReject: (_) {},
        composer: ChatComposer(
          controller: TextEditingController(text: 'Venim acum'),
          hint: organiser ? 'Scrie echipei…' : 'Scrie organizatorului…',
          onSend: () {},
          onPhoto: () {},
        ),
      ),
    ),
  ));
  await tester.pump();
}

/// Scrolls up (to older lines) until [text] is on screen; every line on the
/// way is laid out, so an overflow shows.
Future<void> _scrollTo(WidgetTester tester, String text) async {
  await tester.scrollUntilVisible(find.text(text), 200, scrollable: find.byWidgetPredicate((w) => w is Scrollable && w.axisDirection == AxisDirection.up));
  await tester.pump();
}

void main() {
  for (final theme in [AppTheme.light, AppTheme.dark]) {
    testWidgets('organiser view fits 320 x 640 at 2x text (${theme.brightness.name})', (tester) async {
      await _pump(tester, organiser: true, theme: theme);
      expect(tester.takeException(), isNull);
      expect(find.text('Misiunea 4 din 6'), findsOneWidget);
      expect(find.text('Ușa e închisă, ce facem?'), findsOneWidget);
      await _scrollTo(tester, 'Aprobă');
      expect(find.text('Respinge'), findsOneWidget);
      await _scrollTo(tester, 'Mihai a trimis poza');
      await _scrollTo(tester, 'Ana · căpitan');
      await _scrollTo(tester, 'Au rezolvat misiunea 3 · 10:40');
      expect(tester.takeException(), isNull);
    });

    testWidgets('player view fits 320 x 640 at 2x text (${theme.brightness.name})', (tester) async {
      await _pump(tester, organiser: false, theme: theme);
      expect(tester.takeException(), isNull);
      expect(find.text('Organizatorul'), findsOneWidget);
      await _scrollTo(tester, 'Aprobată');
      expect(find.text('Aprobă'), findsNothing);
      await _scrollTo(tester, 'De aprobat');
      await _scrollTo(tester, 'Tu · 10:46');
      await _scrollTo(tester, 'Ați rezolvat misiunea 3 · 10:40');
      await _scrollTo(tester, 'Anunț pentru toate echipele · 10:30');
      expect(tester.takeException(), isNull);
    });
  }
}
