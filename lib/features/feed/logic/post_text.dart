import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/stire.dart';
import 'package:teamxperience/utils/calendar_helper.dart';

/// The date shown on an event poster, for example `24 OCT`.
String eventPosterDate(Event event) {
  final parts = CalendarHelper.formatEventCardDate(event.dateEvent);
  return '${parts['day']} ${parts['month']}';
}

/// The line under the place: day, time and route length when known.
String eventPostDetails(Event event) {
  final route = event.lungimeTraseu;
  final parts = [
    CalendarHelper.formatEventDate(event.dateEvent),
    CalendarHelper.formatEventTime(event.dateEvent),
    if (route != null && route.isNotEmpty) route,
  ];
  return parts.join(' · ');
}

String eventShareText(Event event) {
  final place = event.location;
  return [
    event.name ?? 'Eveniment',
    if (place != null && place.isNotEmpty) place,
    '${CalendarHelper.formatEventDate(event.dateEvent)}, ${CalendarHelper.formatEventTime(event.dateEvent)}',
    'Te așteptăm la TeamXperience!',
  ].join('\n');
}

/// The news description on a single line, whitespace collapsed.
String newsPreview(Stire stire) {
  final text = stire.description;
  if (text == null) return '';
  return text.replaceAll(RegExp(r'\s+'), ' ').trim();
}

String newsShareText(Stire stire) {
  final preview = newsPreview(stire);
  return [
    stire.title ?? 'Știre',
    if (preview.isNotEmpty) preview,
  ].join('\n\n');
}
