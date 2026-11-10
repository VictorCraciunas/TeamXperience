import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:teamxperience/features/home/logic/hero_from_providers.dart';
import 'package:teamxperience/features/play_tab/logic/play_suggestions.dart';
import 'package:teamxperience/features/play_tab/logic/play_tab_state.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/service/leaderboard.dart';
import 'package:teamxperience/state_management/events_state_management.dart';
import 'package:teamxperience/state_management/user_registered_events.dart';

/// The Joacă pop-up (mockup 10): whether it is open, which card it shows and
/// what that card needs (the team, the live ranking, the suggestions). While
/// open it ticks every second, for the countdowns.
class PlayPopupController extends ChangeNotifier {
  PlayPopupController({
    required this.userEvents,
    required this.eventList,
    required Future<Team?> Function(Event event) teamFor,
    required Stream<List<Team>> Function(String eventId) teams,
    required Future<int> Function(String eventId) countTeams,
    DateTime Function()? clock,
    Random? random,
  })  : _teamFor = teamFor,
        _teams = teams,
        _countTeams = countTeams,
        _clock = clock ?? DateTime.now,
        _random = random ?? Random() {
    userEvents.addListener(_changed);
    eventList.addListener(_changed);
  }

  final UserEventsProvider userEvents;
  final EventList eventList;
  final Future<Team?> Function(Event event) _teamFor;
  final Stream<List<Team>> Function(String eventId) _teams;
  final Future<int> Function(String eventId) _countTeams;
  final DateTime Function() _clock;
  final Random _random;

  bool _disposed = false;
  bool _open = false;
  bool _closing = false;
  Timer? _ticker;

  String? _teamEventId;
  Team? _fetchedTeam;

  String? _liveEventId;
  StreamSubscription<List<Team>>? _liveSub;
  List<RankedTeam> _ranked = const [];

  List<Event> _suggestions = const [];
  int _suggestionIndex = 0;
  bool _rerolled = false;
  final Map<String, int> _counts = {};

  bool get isOpen => _open;

  /// Asked to close: the pop-up plays its exit, then calls [closed].
  bool get isClosing => _closing;

  DateTime get now => _clock();

  PlayTabState get state => playTabState(
        heroFromProviders(includeFinished: false, userEvents: userEvents, eventList: eventList, now: now),
      );

  /// The team on the card: the live one as the stream last sent it, or the
  /// player's team for the shown event once fetched.
  Team? get team {
    final current = state;
    if (current is PlayLive) {
      return _ranked.where((r) => r.team.name == current.team.name).firstOrNull?.team ?? current.team;
    }
    return _fetchedTeam;
  }

  List<RankedTeam> get ranked => _ranked;
  List<Event> get suggestions => _suggestions;
  int get suggestionIndex => _suggestionIndex;

  /// Whether "Alt joc" was used, so the badge reads "La întâmplare".
  bool get rerolled => _rerolled;

  int? teamCount(Event event) => _counts[event.eventId];

  void toggle() {
    if (!_open) {
      open();
    } else {
      requestClose();
    }
  }

  void open() {
    if (_open) return;
    _open = true;
    _closing = false;
    _suggestionIndex = 0;
    _rerolled = false;
    _suggestions = const [];
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _changed());
    _follow();
    notifyListeners();
  }

  void requestClose() {
    if (!_open || _closing) return;
    _closing = true;
    notifyListeners();
  }

  /// The exit has played: everything stops until the next [open].
  void closed() {
    if (!_open) return;
    _open = false;
    _closing = false;
    _ticker?.cancel();
    _ticker = null;
    _stopLive();
    _teamEventId = null;
    _fetchedTeam = null;
    notifyListeners();
  }

  /// "Alt joc": a different suggestion at random.
  void reroll() {
    if (_suggestions.length < 2) return;
    _suggestionIndex = nextSuggestion(_suggestionIndex, _suggestions.length, _random);
    _rerolled = true;
    _countFor(_suggestions[_suggestionIndex]);
    notifyListeners();
  }

  void _changed() {
    if (!_open) return;
    _follow();
    notifyListeners();
  }

  /// Fetches or follows what the current card needs.
  void _follow() {
    final current = state;
    switch (current) {
      case PlayLive(:final event):
        _watchLive(event);
      case PlayNext(:final event) || PlayEnterCode(:final event):
        _stopLive();
        _fetchTeam(event);
      case PlayNone():
        _stopLive();
        if (_suggestions.isEmpty) {
          final registered = userEvents.registeredEvents.map((e) => e.eventId).toSet();
          _suggestions = openSuggestions(eventList.events, registered, now);
          if (_suggestions.isNotEmpty) _countFor(_suggestions.first);
        }
    }
  }

  void _fetchTeam(Event event) {
    if (_teamEventId == event.eventId) return;
    _teamEventId = event.eventId;
    _fetchedTeam = null;
    _teamFor(event).then((team) {
      if (_disposed || !_open || _teamEventId != event.eventId) return;
      _fetchedTeam = team;
      notifyListeners();
    }, onError: (Object _) {});
  }

  void _watchLive(Event event) {
    if (_liveEventId == event.eventId) return;
    _stopLive();
    _liveEventId = event.eventId;
    _liveSub = _teams(event.eventId).listen((teams) {
      _ranked = rankTeams(teams, missionCount: event.nrMissions);
      notifyListeners();
    }, onError: (Object _) {});
  }

  void _stopLive() {
    _liveSub?.cancel();
    _liveSub = null;
    _liveEventId = null;
    _ranked = const [];
  }

  void _countFor(Event event) {
    if (_counts.containsKey(event.eventId)) return;
    _countTeams(event.eventId).then((n) {
      _counts[event.eventId] = n;
      if (!_disposed && _open) notifyListeners();
    }, onError: (Object _) {});
  }

  @override
  void dispose() {
    _disposed = true;
    _ticker?.cancel();
    _liveSub?.cancel();
    userEvents.removeListener(_changed);
    eventList.removeListener(_changed);
    super.dispose();
  }
}
