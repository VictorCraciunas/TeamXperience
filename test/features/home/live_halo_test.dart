import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/home/widgets/live_game_card.dart';
import 'package:teamxperience/features/home/widgets/live_halo.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';

import '../../ui/pump_ui.dart';

final _start = DateTime(2026, 11, 10, 18);
final _event = Event(eventId: 'e', name: 'Harta Pierdută', dateEvent: _start, nrMissions: 6);
final _team = Team(name: 'Vulpile', teamMembers: '', captainName: '', phoneNumber: '', captainEmail: '', hasStarted: true);

Widget _card({bool reduced = false}) => Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
        child: LiveGameCard(
          event: _event,
          team: _team,
          now: _start.add(const Duration(minutes: 40)),
          onContinue: () {},
          onChat: () {},
        ),
      ),
    );

void main() {
  test('the halo grows wider than tall and fades out', () {
    expect(liveHalo(0), (scaleX: 1.0, scaleY: 1.0, opacity: .9));
    expect(liveHalo(1), (scaleX: 1.45, scaleY: 1.9, opacity: 0.0));
  });

  testWidgets('the LIVE badge sends out a halo', (tester) async {
    await pumpUi(tester, _card());
    expect(find.ancestor(of: find.text('LIVE'), matching: find.byType(LiveHalo)), findsOneWidget);
    expect(find.byKey(const ValueKey('live-halo-ring')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('no halo with reduced motion', (tester) async {
    await pumpUi(tester, _card(reduced: true));
    expect(find.text('LIVE'), findsOneWidget);
    expect(find.byKey(const ValueKey('live-halo-ring')), findsNothing);
  });
}
