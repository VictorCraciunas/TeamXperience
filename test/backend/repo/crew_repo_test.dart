import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/backend/repo/crew_repo.dart';
import 'package:teamxperience/model/crew.dart';

Crew _crew(String name) => Crew(
  id: name,
  name: name,
  captainUid: 'u1',
  memberUids: const ['u1'],
  members: const [],
  inviteCode: 'VLP482',
);

void main() {
  test('sortCrews orders by name, ignoring case', () {
    final sorted = sortCrews([
      _crew('vulpile'),
      _crew('Bufnițe'),
      _crew('Ursi'),
    ]);
    expect(sorted.map((c) => c.name), ['Bufnițe', 'Ursi', 'vulpile']);
  });

  test('sortCrews does not change the list it is given', () {
    final crews = [_crew('b'), _crew('a')];
    sortCrews(crews);
    expect(crews.map((c) => c.name), ['b', 'a']);
  });
}
