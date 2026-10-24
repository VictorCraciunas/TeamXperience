/// Whether [date] falls inside the period from [start] to [end], both whole
/// days (the pickers return midnight): the last day counts until its end.
/// A missing date, or a period that is not complete, filters nothing out.
bool isWithinPeriod(DateTime? date, DateTime? start, DateTime? end) {
  if (date == null || start == null || end == null) return true;
  final from = DateTime(start.year, start.month, start.day);
  final until = DateTime(end.year, end.month, end.day + 1);
  return !date.isBefore(from) && date.isBefore(until);
}
