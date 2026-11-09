import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/home/logic/home_hero.dart';
import 'package:teamxperience/features/play_tab/logic/play_tab_state.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';

final _event = Event(eventId: 'e', name: 'Moștenirea Cartografului', dateEvent: DateTime(2026, 11, 14, 10));
final _team = Team(name: 'Vulpile', teamMembers: '', captainName: 'V', phoneNumber: '', captainEmail: '', numberOfMembers: 4);

void main() {
  test('a live game continues', () {
    final s = playTabState(LiveHero(_event, _team));
    expect(s, isA<PlayLive>());
    expect(((s as PlayLive).event, s.team), (_event, _team));
    expect(isLive(s), isTrue);
  });

  test('the first hour asks for the code', () {
    final s = playTabState(StartingSoonHero(_event, 42));
    expect(s, isA<PlayEnterCode>());
    expect((s as PlayEnterCode).minutesLeft, 42);
    expect(isLive(s), isFalse);
  });

  test('a registered event later shows the next game', () {
    final s = playTabState(UpcomingHero(_event, const Duration(days: 3)));
    expect(s, isA<PlayNext>());
    expect((s as PlayNext).untilStart, const Duration(days: 3));
  });

  test('a recommendation or nothing shows the empty state', () {
    expect(playTabState(RecommendedHero(_event)), isA<PlayNone>());
    expect(playTabState(const NoHero()), isA<PlayNone>());
    expect(playTabState(FinishedHero(_event, Team.fromMap(const {'name': 'Vulpile'}))), isA<PlayNone>());
    expect(isLive(const PlayNone()), isFalse);
  });
}
