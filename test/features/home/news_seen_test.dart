import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teamxperience/features/home/logic/news_seen.dart';
import 'package:teamxperience/model/stire.dart';

Stire _news(DateTime? at) => Stire(publicationDate: at);

void main() {
  final seen = DateTime(2026, 11, 10, 12);

  group('hasUnreadNews', () {
    test('a news item newer than the last visit', () {
      expect(hasUnreadNews([_news(seen.subtract(const Duration(days: 1))), _news(seen.add(const Duration(hours: 1)))], seen), isTrue);
    });

    test('nothing newer', () {
      expect(hasUnreadNews([_news(seen.subtract(const Duration(days: 1))), _news(null)], seen), isFalse);
    });

    test('no news', () {
      expect(hasUnreadNews(const [], seen), isFalse);
      expect(hasUnreadNews(const [], null), isFalse);
    });

    test('never visited, with news', () {
      expect(hasUnreadNews([_news(seen)], null), isTrue);
    });
  });

  test('NewsSeenStore remembers the last visit', () async {
    SharedPreferences.setMockInitialValues({});
    final store = NewsSeenStore();
    expect(await store.lastSeen(), isNull);
    await store.markSeen(seen);
    expect(await NewsSeenStore().lastSeen(), seen);
  });
}
