import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/team_chats/logic/chat_row.dart';
import 'package:teamxperience/features/team_chats/widgets/team_chats_view.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

final _now = DateTime(2026, 11, 17, 12);

Team _team(String name, {String? unread, int? count, Map<String, Object>? photos}) => Team.fromMap({
      'name': name,
      if (unread != null)
        'unreadByAdmin': {'text': unread, 'at': Timestamp.fromDate(_now.subtract(const Duration(minutes: 1))), if (count != null) 'count': count},
      if (photos != null) 'photoApprovals': photos,
    });

LastMessage _msg(int minutesAgo, String text, {bool organiser = false}) =>
    LastMessage(fromOrganiser: organiser, text: text, isPhoto: false, at: _now.subtract(Duration(minutes: minutesAgo)));

final _rows = [
  ChatRow(team: _team('Lupii de Cetate', unread: 'Ușa e închisă, ce facem?', count: 2), last: _msg(1, 'Ușa e închisă, ce facem?')),
  ChatRow(team: _team('Vulpile', photos: {'2_0_0': {'status': 'pending'}}), last: _msg(4, 'Fotografie încărcată pentru aprobare')),
  ChatRow(team: _team('Bufnițele'), last: _msg(78, 'Bravo, mergeți mai departe!', organiser: true)),
  ChatRow(team: _team('Pisicile')),
];

Future<void> _pump(
  WidgetTester tester, {
  List<ChatRow>? rows,
  ChatFilter filter = ChatFilter.all,
  ValueChanged<Team>? onOpen,
  ValueChanged<ChatFilter>? onFilter,
  Size size = const Size(390, 844),
  double textScale = 1,
  ThemeData? theme,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final all = rows ?? _rows;
  final split = splitChatRows(all);
  await tester.pumpWidget(MaterialApp(
    theme: theme ?? AppTheme.light,
    builder: (context, app) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
      child: app ?? const SizedBox.shrink(),
    ),
    home: Scaffold(
      body: TeamChatsView(
        subtitle: 'Moștenirea Cartografului, ediția de toamnă · 12 echipe',
        loading: false,
        failed: false,
        teamCount: all.length,
        unreadCount: split.unread.length,
        filter: filter,
        sections: filter == ChatFilter.unread ? (unread: split.unread, read: const []) : split,
        now: _now,
        onBack: () {},
        onFilter: onFilter ?? (_) {},
        onOpen: onOpen ?? (_) {},
        onRetry: () {},
      ),
    ),
  ));
}

void main() {
  testWidgets('unread first with their counts, then the rest, with their times and previews', (tester) async {
    await _pump(tester);
    for (final text in [
      'Conversații',
      'Toate · 4',
      'Necitite · 2',
      'Necitite',
      'Citite',
      'acum 1 min',
      'acum 4 min',
      '10:42',
      'Poză de aprobat · misiunea 3',
      'Tu: Bravo, mergeți mai departe!',
      'Niciun mesaj încă',
      '2',
      '1',
    ]) {
      expect(find.text(text), findsWidgets, reason: text);
    }
    expect(tester.getTopLeft(find.text('Vulpile')).dy, lessThan(tester.getTopLeft(find.text('Bufnițele')).dy));
    expect(find.byKey(const ValueKey('chat-filter-dot')), findsOneWidget);
  });

  testWidgets('a row opens its chat; a chip changes the filter', (tester) async {
    Team? opened;
    ChatFilter? chosen;
    await _pump(tester, onOpen: (t) => opened = t, onFilter: (f) => chosen = f);
    await tester.tap(find.text('Bufnițele'));
    expect(opened?.name, 'Bufnițele');
    await tester.tap(find.text('Necitite · 2'));
    expect(chosen, ChatFilter.unread);
  });

  testWidgets('the unread filter with nothing unread says so', (tester) async {
    await _pump(tester, rows: [ChatRow(team: _team('Bufnițele'))], filter: ChatFilter.unread);
    expect(find.text('Niciun mesaj necitit.'), findsOneWidget);
  });

  for (final theme in [AppTheme.light, AppTheme.dark]) {
    testWidgets('fits a small phone at 2x text (${theme.brightness.name})', (tester) async {
      final long = 'Echipa cu un nume foarte lung care nu încape ${'deloc ' * 6}';
      await _pump(
        tester,
        rows: [
          ChatRow(team: _team(long, unread: long, count: 120), last: _msg(3, long)),
          ..._rows,
        ],
        size: const Size(320, 640),
        textScale: 2,
        theme: theme,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
