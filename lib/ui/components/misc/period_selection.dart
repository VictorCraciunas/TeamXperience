/// A date range being picked: nothing, a start only, or a start and an end.
/// All dates are whole days (the time of day is dropped).
class PeriodSelection {
  const PeriodSelection({this.start, this.end});

  final DateTime? start;
  final DateTime? end;

  bool get isEmpty => start == null && end == null;
  bool get isComplete => start != null && end != null;

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  /// The selection after the user taps [date]: first tap sets the start, the
  /// second sets the end (swapping if it is earlier), a third starts over.
  PeriodSelection tap(DateTime date) {
    final day = _day(date);
    final from = start;

    if (from == null || end != null) return PeriodSelection(start: day);
    if (day.isBefore(from)) return PeriodSelection(start: day, end: from);
    return PeriodSelection(start: from, end: day);
  }

  bool isStart(DateTime date) {
    final from = start;
    return from != null && _day(date) == from;
  }

  bool isEnd(DateTime date) {
    final to = end;
    return to != null && _day(date) == to;
  }

  /// True for days strictly between the start and the end.
  bool isInside(DateTime date) {
    final from = start;
    final to = end;
    if (from == null || to == null) return false;
    final day = _day(date);
    return day.isAfter(from) && day.isBefore(to);
  }

  @override
  bool operator ==(Object other) =>
      other is PeriodSelection && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);
}

/// A quick choice shown above the calendar.
class PeriodPreset {
  const PeriodPreset(this.label, this.selection);

  final String label;
  final PeriodSelection selection;

  bool matches(PeriodSelection other) => other == selection;
}

/// The quick choices for [now]: anytime (clears), this week (Monday to
/// Sunday), this month, and the next 30 days.
List<PeriodPreset> periodPresets(DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  // Calendar arithmetic, not Duration: a day is not always 24 h (daylight saving).
  DateTime daysFrom(DateTime d, int n) => DateTime(d.year, d.month, d.day + n);
  final monday = daysFrom(today, 1 - today.weekday);

  return [
    const PeriodPreset('Oricând', PeriodSelection()),
    PeriodPreset(
      'Săptămâna asta',
      PeriodSelection(start: monday, end: daysFrom(monday, 6)),
    ),
    PeriodPreset(
      'Luna asta',
      PeriodSelection(
        start: DateTime(today.year, today.month, 1),
        end: DateTime(today.year, today.month + 1, 0),
      ),
    ),
    PeriodPreset(
      '30 de zile',
      PeriodSelection(start: today, end: daysFrom(today, 29)),
    ),
  ];
}
