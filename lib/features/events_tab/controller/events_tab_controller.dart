import 'package:flutter/foundation.dart';
import 'package:teamxperience/features/events_tab/logic/event_filters.dart';
import 'package:teamxperience/features/events_tab/logic/event_sections.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/service/team_service/team_service.dart';

/// The Evenimente tab's state: the query, list or map, the search field, and
/// the extras the cards need (the player's team names, team counts of events
/// with a cap). Inputs come in as functions so the tab can follow the
/// providers while tests pass plain values.
class EventsTabController extends ChangeNotifier {
  EventsTabController({
    required List<Event> Function() events,
    required Set<String> Function() registeredIds,
    required String? Function() uid,
    required Listenable source,
    required TeamService teams,
    DateTime Function()? clock,
  })  : _events = events,
        _registeredIds = registeredIds,
        _uid = uid,
        _source = source,
        _teams = teams,
        _clock = clock ?? DateTime.now {
    _source.addListener(_sourceChanged);
    _loadExtras();
  }

  final List<Event> Function() _events;
  final Set<String> Function() _registeredIds;
  final String? Function() _uid;
  final Listenable _source;
  final TeamService _teams;
  final DateTime Function() _clock;

  EventQuery _query = const EventQuery();
  bool _mapMode = false;
  bool _searching = false;
  bool _disposed = false;
  final Map<String, String> _teamNames = {};
  final Map<String, int> _teamCounts = {};
  final Set<String> _askedTeams = {};
  final Set<String> _askedCounts = {};

  EventQuery get query => _query;
  bool get mapMode => _mapMode;
  bool get searching => _searching;
  Map<String, String> get teamNames => Map.unmodifiable(_teamNames);
  Map<String, int> get teamCounts => Map.unmodifiable(_teamCounts);
  DateTime get now => _clock();
  Set<String> get registeredIds => _registeredIds();

  /// The events the query keeps.
  List<Event> get filtered => applyQuery(_events(), _query, now);

  ({List<Event> registered, List<Event> open, List<Event> soon}) get sections =>
      sectionEvents(filtered, _registeredIds(), now);

  void toggle(EventFilter filter) {
    final next = {..._query.filters};
    if (!next.remove(filter)) next.add(filter);
    _set(EventQuery(filters: next, search: _query.search));
  }

  void selectAll() {
    _searching = false;
    _set(const EventQuery());
  }

  void setSearch(String text) => _set(EventQuery(filters: _query.filters, search: text));

  void toggleSearch() {
    _searching = !_searching;
    if (!_searching) {
      _set(EventQuery(filters: _query.filters));
    } else {
      _notify();
    }
  }

  void setMapMode(bool map) {
    _mapMode = map;
    _notify();
  }

  void _set(EventQuery q) {
    _query = q;
    _notify();
  }

  void _sourceChanged() {
    _loadExtras();
    _notify();
  }

  /// Team names for registered events and counts for capped events, asked
  /// once each; a failed lookup is skipped quietly.
  Future<void> _loadExtras() async {
    final uid = _uid();
    final registered = _registeredIds();
    final events = _events();
    final asks = <Future<void>>[];

    if (uid != null) {
      for (final id in registered) {
        if (!_askedTeams.add(id)) continue;
        asks.add(() async {
          try {
            final team = await _teams.getUserTeamForEvent(id, uid);
            if (team != null) _teamNames[id] = team.name;
          } catch (e) {
            debugPrint('Evenimente: team lookup failed for $id: $e');
          }
        }());
      }
    }
    for (final e in events) {
      if (e.maxTeams == null || !_askedCounts.add(e.eventId)) continue;
      asks.add(() async {
        try {
          _teamCounts[e.eventId] = await _teams.countTeams(e.eventId);
        } catch (err) {
          debugPrint('Evenimente: count failed for ${e.eventId}: $err');
        }
      }());
    }
    if (asks.isEmpty) return;
    await Future.wait(asks);
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _source.removeListener(_sourceChanged);
    super.dispose();
  }
}
