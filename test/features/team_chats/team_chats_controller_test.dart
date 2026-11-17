import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/team_chats/controller/team_chats_controller.dart';
import 'package:teamxperience/features/team_chats/logic/chat_row.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';

Team _team(String name, {String? unread}) => Team.fromMap({
      'name': name,
      if (unread != null) 'unreadByAdmin': {'text': unread},
    });

LastMessage _msg(String text) => LastMessage(fromOrganiser: false, text: text, isPhoto: false, at: DateTime(2026, 11, 17));

class _Harness {
  final teams = StreamController<List<Team>>.broadcast();
  final chats = <String, StreamController<LastMessage?>>{};
  final opened = <String>[];
  late final TeamChatsController controller = TeamChatsController(
    event: Event(eventId: 'e', name: 'Harta'),
    teams: (_) => teams.stream,
    lastMessage: (_, team) {
      opened.add(team);
      return (chats[team] = StreamController<LastMessage?>()).stream;
    },
  );

  Future<void> flush() => Future<void>.delayed(Duration.zero);
}

void main() {
  test('nothing is read until started', () {
    final h = _Harness();
    expect(h.controller.isLoading, isTrue);
    expect(h.teams.hasListener, isFalse);
  });

  test('follows the teams and one last message per team', () async {
    final h = _Harness();
    h.controller.start();
    h.teams.add([_team('Lupii', unread: 'Alo'), _team('Bufnițele')]);
    await h.flush();
    expect(h.controller.isLoading, isFalse);
    expect(h.opened, ['Lupii', 'Bufnițele']);
    expect(h.controller.teamCount, 2);
    expect(h.controller.unreadCount, 1);
    expect(h.controller.rows.every((r) => !r.lastLoaded), isTrue);

    h.chats['Bufnițele']?.add(_msg('Gata'));
    h.chats['Lupii']?.add(null);
    await h.flush();
    final rows = {for (final r in h.controller.rows) r.team.name: r};
    expect(rows['Bufnițele']?.last?.text, 'Gata');
    expect(rows['Lupii']?.lastLoaded, isTrue);
    expect(rows['Lupii']?.last, isNull);
  });

  test('a new snapshot keeps the open chats, opens new ones and closes gone ones', () async {
    final h = _Harness();
    h.controller.start();
    h.teams.add([_team('Lupii'), _team('Vulpile')]);
    await h.flush();
    h.teams.add([_team('Lupii', unread: 'Hei'), _team('Cometele')]);
    await h.flush();
    expect(h.opened, ['Lupii', 'Vulpile', 'Cometele']);
    expect(h.chats['Vulpile']?.hasListener, isFalse);
    expect(h.chats['Lupii']?.hasListener, isTrue);
    expect(h.controller.unreadCount, 1);
  });

  test('the filter shows only the unread', () async {
    final h = _Harness();
    h.controller.start();
    h.teams.add([_team('Lupii', unread: 'Alo'), _team('Bufnițele')]);
    await h.flush();
    expect(h.controller.sections.unread.length + h.controller.sections.read.length, 2);
    h.controller.setFilter(ChatFilter.unread);
    expect(h.controller.filter, ChatFilter.unread);
    expect(h.controller.sections.unread.map((r) => r.team.name), ['Lupii']);
    expect(h.controller.sections.read, isEmpty);
  });

  test('a failed read says so; a retry listens again', () async {
    final h = _Harness();
    h.controller.start();
    h.teams.addError(Exception('offline'));
    await h.flush();
    expect((h.controller.isLoading, h.controller.failed), (false, true));
    h.controller.retry();
    expect((h.controller.isLoading, h.controller.failed), (true, false));
    h.teams.add([_team('Lupii')]);
    await h.flush();
    expect((h.controller.isLoading, h.controller.failed, h.controller.teamCount), (false, false, 1));
  });

  test('dispose stops every stream', () async {
    final h = _Harness();
    h.controller.start();
    h.teams.add([_team('Lupii')]);
    await h.flush();
    h.controller.dispose();
    expect(h.teams.hasListener, isFalse);
    expect(h.chats['Lupii']?.hasListener, isFalse);
  });
}
