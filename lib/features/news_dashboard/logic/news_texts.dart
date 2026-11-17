import 'package:teamxperience/enums/stire_type.dart';
import 'package:teamxperience/model/stire.dart';
import 'package:teamxperience/utils/event_formats.dart';

import 'news_reading_time.dart';

/// "16 nov" in the current year, "30 dec 2025" in another; empty without a date.
String newsDateText(DateTime? date, DateTime now) {
  if (date == null) return '';
  final day = dayAndMonth(date);
  return date.year == now.year ? day : '$day ${date.year}';
}

/// Under the featured news: "16 nov · 3 min de citit".
String featuredMeta(Stire stire, DateTime now) {
  final date = newsDateText(stire.publicationDate, now);
  return [if (date.isNotEmpty) date, readingTimeText(stire.description)].join(' · ');
}

/// The category's name, or "Necategorizat".
String newsCategoryText(Stire stire) {
  final name = stire.category?.name.trim() ?? '';
  return name.isEmpty ? 'Necategorizat' : name;
}

/// Next to the type pill on an organiser's row: "Rezultate · 16 nov".
String adminRowMeta(Stire stire, DateTime now) {
  final date = newsDateText(stire.publicationDate, now);
  return [newsCategoryText(stire), if (date.isNotEmpty) date].join(' · ');
}

/// Only PRIVATA is private; a news with no type is public.
bool isPrivateNews(Stire stire) => stire.type == StireType.PRIVATA;

/// "Publică" or "Privată".
String newsTypeLabel(Stire stire) =>
    isPrivateNews(stire) ? StireType.PRIVATA.displayName : StireType.PUBLICA.displayName;

/// Above the title on a player's row: "Evenimente", or "Evenimente · Privată".
String playerRowCategory(Stire stire) => isPrivateNews(stire)
    ? '${newsCategoryText(stire)} · ${StireType.PRIVATA.displayName}'
    : newsCategoryText(stire);

/// "1 știre", "8 știri", "20 de știri".
String _count(int n, String one, String many) {
  if (n == 1) return '1 $one';
  final rest = n % 100;
  final de = n >= 20 && (rest == 0 || rest >= 20);
  return de ? '$n de $many' : '$n $many';
}

/// The organiser header's line: "8 știri · 3 categorii".
String newsCountLine(int news, int categories) =>
    '${_count(news, 'știre', 'știri')} · ${_count(categories, 'categorie', 'categorii')}';

/// A chip with its count: "Toate · 8".
String chipLabel(String label, int count) => '$label · $count';
