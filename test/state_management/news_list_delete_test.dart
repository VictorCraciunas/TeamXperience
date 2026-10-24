import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/model/stire.dart';
import 'package:teamxperience/service/news_service/news_service.dart';
import 'package:teamxperience/state_management/news_state_management.dart';

class _FakeNewsService extends Fake implements NewsService {
  _FakeNewsService(this.news, {this.failDelete = false});

  final List<Stire> news;
  final bool failDelete;
  final deleted = <String>[];

  @override
  Future<List<Stire>> getAllStire() async => List.of(news);

  @override
  Future<void> deleteStire(String id) async {
    if (failDelete) throw Exception('denied');
    deleted.add(id);
  }
}

Stire _stire(String id) => Stire(id: id, title: 'Știre $id');

Future<NewsList> _loaded(_FakeNewsService service) async {
  final list = NewsList(service);
  await list.loadStire(forceRefresh: true);
  return list;
}

void main() {
  test('deleting removes the news from the list and from the service', () async {
    final service = _FakeNewsService([_stire('a'), _stire('b')]);
    final list = await _loaded(service);
    var notified = 0;
    list.addListener(() => notified++);

    await list.deleteStire('a');

    expect(service.deleted, ['a']);
    expect(list.stireList.map((s) => s.id), ['b']);
    expect(notified, greaterThan(0));
  });

  test('a failed delete keeps the news and reports the error', () async {
    final service = _FakeNewsService([_stire('a')], failDelete: true);
    final list = await _loaded(service);

    await expectLater(list.deleteStire('a'), throwsA(isA<Exception>()));

    expect(list.stireList.map((s) => s.id), ['a']);
  });

  test('deleting an id that is not in the list changes nothing', () async {
    final service = _FakeNewsService([_stire('a')]);
    final list = await _loaded(service);
    await list.deleteStire('zzz');
    expect(list.stireList.map((s) => s.id), ['a']);
  });
}
