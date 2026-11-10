import 'package:teamxperience/enums/difficulty.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/utils/plain_text.dart';

/// The chips under the Evenimente header (besides "Toate").
enum EventFilter { thisMonth, easy, medium, hard, under2h }

/// What the Evenimente tab is showing: the chips that are on and the search.
class EventQuery {
  const EventQuery({this.filters = const {}, this.search = ''});

  final Set<EventFilter> filters;
  final String search;

  /// "Toate": no chip on and nothing searched.
  bool get isAll => filters.isEmpty && search.trim().isEmpty;
}

const _difficultyFilters = {
  EventFilter.easy: Difficulty.easy,
  EventFilter.medium: Difficulty.medium,
  EventFilter.hard: Difficulty.hard,
};

/// The events [q] keeps. Difficulty chips are OR among themselves; different
/// kinds of chip combine with AND. An event without the value a chip looks at
/// (no difficulty, no duration) does not pass that chip.
List<Event> applyQuery(List<Event> events, EventQuery q, DateTime now) {
  final difficulties = {
    for (final f in q.filters)
      if (_difficultyFilters[f] case final d?) d,
  };
  final search = plainText(q.search.trim());

  bool keep(Event e) {
    if (q.filters.contains(EventFilter.thisMonth)) {
      final date = e.dateEvent;
      if (date == null || date.year != now.year || date.month != now.month) return false;
    }
    if (difficulties.isNotEmpty && !difficulties.contains(e.effectiveDifficulty)) return false;
    if (q.filters.contains(EventFilter.under2h)) {
      final minutes = e.effectiveDurationMinutes;
      if (minutes == null || minutes > 120) return false;
    }
    if (search.isNotEmpty) {
      final haystack = plainText('${e.name ?? ''} ${e.location ?? ''} ${e.area ?? ''}');
      if (!haystack.contains(search)) return false;
    }
    return true;
  }

  return events.where(keep).toList();
}
