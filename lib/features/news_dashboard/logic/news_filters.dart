import 'package:teamxperience/model/stire.dart';
import 'package:teamxperience/utils/period_utils.dart';

import 'news_texts.dart';

/// The organiser's chips: Toate, Publice, Private.
enum NewsTypeFilter { all, public, private }

const _keep = Object();

/// What the news list shows: a type, a category (by name), a period and a
/// search in titles and descriptions. Empty parts filter nothing.
class NewsQuery {
  const NewsQuery({
    this.type = NewsTypeFilter.all,
    this.category,
    this.start,
    this.end,
    this.search = '',
  });

  final NewsTypeFilter type;
  final String? category;
  final DateTime? start;
  final DateTime? end;
  final String search;

  bool get hasCategory => (category?.trim() ?? '').isNotEmpty;
  bool get hasPeriod => start != null && end != null;
  bool get hasSearch => search.trim().isNotEmpty;

  /// Leaves out a field to keep it; pass null to clear [category], [start] or [end].
  NewsQuery copyWith({
    NewsTypeFilter? type,
    Object? category = _keep,
    Object? start = _keep,
    Object? end = _keep,
    String? search,
  }) {
    return NewsQuery(
      type: type ?? this.type,
      category: identical(category, _keep) ? this.category : category as String?,
      start: identical(start, _keep) ? this.start : start as DateTime?,
      end: identical(end, _keep) ? this.end : end as DateTime?,
      search: search ?? this.search,
    );
  }
}

String _clean(String? s) => (s ?? '').trim().toLowerCase();

bool _matchesType(Stire s, NewsTypeFilter type) => switch (type) {
  NewsTypeFilter.all => true,
  NewsTypeFilter.public => !isPrivateNews(s),
  NewsTypeFilter.private => isPrivateNews(s),
};

bool _matches(Stire s, NewsQuery q) {
  if (!_matchesType(s, q.type)) return false;
  if (q.hasCategory && _clean(s.category?.name) != _clean(q.category)) return false;
  if (!isWithinPeriod(s.publicationDate, q.start, q.end)) return false;
  if (q.hasSearch) {
    final needle = _clean(q.search);
    if (!_clean(s.title).contains(needle) && !_clean(s.description).contains(needle)) return false;
  }
  return true;
}

/// The news [query] lets through, newest first, undated ones last.
List<Stire> selectNews(Iterable<Stire> news, NewsQuery query) {
  return news.where((s) => _matches(s, query)).toList()..sort((a, b) {
    final da = a.publicationDate;
    final db = b.publicationDate;
    if (da == null && db == null) return 0;
    if (da == null) return 1;
    if (db == null) return -1;
    return db.compareTo(da);
  });
}

/// How many news each organiser chip would show.
class NewsTypeCounts {
  const NewsTypeCounts({required this.public, required this.private});

  final int public;
  final int private;

  int get all => public + private;

  int of(NewsTypeFilter type) => switch (type) {
    NewsTypeFilter.all => all,
    NewsTypeFilter.public => public,
    NewsTypeFilter.private => private,
  };
}

NewsTypeCounts countByType(Iterable<Stire> news) {
  final private = news.where(isPrivateNews).length;
  return NewsTypeCounts(public: news.length - private, private: private);
}

/// The player's list: the first news as the big card, then the rest.
class NewsSplit {
  const NewsSplit(this.featured, this.rest);

  final Stire? featured;
  final List<Stire> rest;
}

NewsSplit splitFeatured(List<Stire> news) =>
    news.isEmpty ? const NewsSplit(null, []) : NewsSplit(news.first, news.sublist(1));

/// Every category name: the ones [news] use plus the [saved] ones, sorted and
/// without repeats (ignoring case). A name keeps the spelling the news use.
List<String> mergeCategoryNames(Iterable<String> saved, Iterable<Stire> news) {
  final byLower = <String, String>{};

  void add(String? name) {
    final clean = name?.trim() ?? '';
    if (clean.isEmpty) return;
    byLower.putIfAbsent(clean.toLowerCase(), () => clean);
  }

  for (final s in news) {
    add(s.category?.name);
  }
  saved.forEach(add);

  return byLower.values.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
}

/// The [names] some news in [news] uses (ignoring case), in their order.
List<String> categoriesWithNews(Iterable<String> names, Iterable<Stire> news) {
  final used = {for (final s in news) _clean(s.category?.name)};
  return names.where((n) => used.contains(_clean(n))).toList();
}
