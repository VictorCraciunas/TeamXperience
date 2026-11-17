import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:teamxperience/enums/message_type.dart';
import 'package:teamxperience/enums/role.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/service/team_service/team_service.dart';

import '../logic/chat_row.dart';

/// The organiser's list of team conversations: the event's teams as they
/// change (their unread marks and photos waiting) and the newest message of
/// each chat, one small listener per team.
class TeamChatsController extends ChangeNotifier {
  TeamChatsController({
    required this.event,
    Stream<List<Team>> Function(String eventId)? teams,
    Stream<LastMessage?> Function(String eventId, String teamName)? lastMessage,
  })  : _teamsOf = teams ?? TeamService().getStreamTeams,
        _lastOf = lastMessage ?? _lastMessageFromFirestore;

  final Event event;
  final Stream<List<Team>> Function(String eventId) _teamsOf;
  final Stream<LastMessage?> Function(String eventId, String teamName) _lastOf;

  static Stream<LastMessage?> _lastMessageFromFirestore(String eventId, String teamName) =>
      TeamService().streamLastMessage(eventId, teamName).map((m) => m == null
          ? null
          : LastMessage(
              fromOrganiser: m.sender == Role.ADMIN,
              text: m.text,
              isPhoto: m.type == MessageType.image,
              at: m.timestamp,
            ));

  StreamSubscription<List<Team>>? _teamSubscription;
  final Map<String, StreamSubscription<LastMessage?>> _chatSubscriptions = {};

  /// Team name → its newest message; a name missing here has not been read yet.
  final Map<String, LastMessage?> _last = {};
  List<Team> _teams = const [];

  bool _loading = true;
  bool _failed = false;
  ChatFilter _filter = ChatFilter.all;

  bool get isLoading => _loading;

  /// The teams could not be read.
  bool get failed => _failed;
  ChatFilter get filter => _filter;

  List<ChatRow> get rows => [
        for (final team in _teams)
          ChatRow(team: team, last: _last[team.name], lastLoaded: _last.containsKey(team.name)),
      ];

  int get teamCount => _teams.length;

  /// How many chats have something to read or a photo to decide.
  int get unreadCount => rows.where((r) => r.isUnread).length;

  /// What the list shows under the chosen filter.
  ({List<ChatRow> unread, List<ChatRow> read}) get sections {
    final split = splitChatRows(rows);
    return _filter == ChatFilter.unread ? (unread: split.unread, read: const <ChatRow>[]) : split;
  }

  void setFilter(ChatFilter filter) {
    if (_filter == filter) return;
    _filter = filter;
    notifyListeners();
  }

  /// Starts following the teams.
  void start() {
    _teamSubscription?.cancel();
    _teamSubscription = _teamsOf(event.eventId).listen(_onTeams, onError: (Object _) {
      _loading = false;
      _failed = true;
      notifyListeners();
    });
  }

  void retry() {
    _loading = true;
    _failed = false;
    notifyListeners();
    start();
  }

  void _onTeams(List<Team> teams) {
    _teams = teams;
    _loading = false;
    _failed = false;
    final names = {for (final team in teams) team.name};
    for (final gone in _chatSubscriptions.keys.where((name) => !names.contains(name)).toList()) {
      _chatSubscriptions.remove(gone)?.cancel();
      _last.remove(gone);
    }
    for (final name in names) {
      if (_chatSubscriptions.containsKey(name)) continue;
      _chatSubscriptions[name] = _lastOf(event.eventId, name).listen((message) {
        _last[name] = message;
        notifyListeners();
      }, onError: (Object _) {});
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _teamSubscription?.cancel();
    for (final subscription in _chatSubscriptions.values) {
      subscription.cancel();
    }
    _chatSubscriptions.clear();
    super.dispose();
  }
}
