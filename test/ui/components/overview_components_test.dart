import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/event/checklist_row.dart';
import 'package:teamxperience/ui/components/event/countdown_tiles.dart';
import 'package:teamxperience/ui/components/event/event_hero_card.dart';
import 'package:teamxperience/ui/components/event/format_remaining.dart';
import 'package:teamxperience/ui/components/event/hero_action.dart';
import 'package:teamxperience/ui/components/event/hero_card_frame.dart';
import 'package:teamxperience/ui/components/event/poster_card.dart';
import 'package:teamxperience/ui/components/layout/action_tile.dart';
import 'package:teamxperience/ui/components/layout/stat_tile.dart';

import '../pump_ui.dart';

int _segments(WidgetTester tester, String kind) {
  return find
      .byWidgetPredicate((w) {
        final key = w.key;
        return key is ValueKey<String> && key.value.startsWith('hero-segment-$kind');
      })
      .evaluate()
      .length;
}

EventHeroCard _hero({
  HeroStatus status = HeroStatus.live,
  String title = 'Treasure Hunt Sibiu',
  String? subtitle = 'Echipa Vulturii · Misiunea 2 din 5',
  String? timeChip = '2:14:09 rămase',
  String? imageUrl,
  int? progressDone,
  int? progressTotal,
  Duration? countdown,
  VoidCallback? onPrimary,
  IconData? secondaryIcon,
  VoidCallback? onSecondary,
}) {
  return EventHeroCard(
    status: status,
    statusLabel: 'LIVE',
    title: title,
    subtitle: subtitle,
    timeChip: timeChip,
    imageUrl: imageUrl,
    progressDone: progressDone,
    progressTotal: progressTotal,
    countdown: countdown,
    primary: HeroAction(label: 'Continuă jocul', onTap: onPrimary ?? () {}),
    secondaryIcon: secondaryIcon,
    onSecondary: onSecondary,
  );
}

void main() {
  group('formatRemaining', () {
    test('formats hours, minutes and seconds', () {
      expect(formatRemaining(const Duration(hours: 2, minutes: 14, seconds: 9)), '2:14:09');
    });

    test('clamps negative durations to zero', () {
      expect(formatRemaining(const Duration(seconds: -5)), '0:00:00');
    });
  });

  testWidgets('CountdownTiles shows zero-padded days, hours and minutes',
      (tester) async {
    await pumpUi(
      tester,
      const CountdownTiles(remaining: Duration(days: 3, hours: 14, minutes: 22)),
    );
    expect(find.text('03'), findsOneWidget);
    expect(find.text('14'), findsOneWidget);
    expect(find.text('22'), findsOneWidget);
    expect(find.text('zile'), findsOneWidget);
    expect(find.text('ore'), findsOneWidget);
    expect(find.text('min'), findsOneWidget);
  });

  testWidgets('HeroCardFrame renders its child without an image', (tester) async {
    await pumpUi(tester, const HeroCardFrame(child: Text('conținut')));
    expect(find.text('conținut'), findsOneWidget);
    await pumpUi(tester, const HeroCardFrame(imageUrl: '', child: Text('conținut')));
    expect(find.text('conținut'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('PosterCard handles a missing image and a very long title',
      (tester) async {
    await pumpUi(
      tester,
      PosterCard(
        title: 'Un eveniment cu un titlu extrem de lung care nu are cum să încapă',
        dateLabel: '20 nov',
        place: 'Sibiu',
        onTap: () {},
      ),
      textScale: 1.5,
    );
    expect(tester.takeException(), isNull);
    expect(find.text('20 nov'), findsOneWidget);
  });

  testWidgets('PosterCard fires onTap', (tester) async {
    var taps = 0;
    await pumpUi(
      tester,
      PosterCard(title: 'Noaptea muzeelor', dateLabel: '20 nov', place: 'Sibiu', onTap: () => taps++),
    );
    await tester.tap(find.byType(PosterCard));
    expect(taps, 1);
  });

  testWidgets('StatTile shows value and label, including zero', (tester) async {
    await pumpUi(tester, const StatTile(label: 'Echipe', value: '0'));
    expect(find.text('0'), findsOneWidget);
    expect(find.text('Echipe'), findsOneWidget);
  });

  testWidgets('ActionTile fires onTap', (tester) async {
    var taps = 0;
    await pumpUi(
      tester,
      ActionTile(icon: Icons.add, label: 'Creează eveniment', onTap: () => taps++),
    );
    await tester.tap(find.byType(ActionTile));
    expect(taps, 1);
  });

  testWidgets('ChecklistRow shows a check when done and a lock when not',
      (tester) async {
    await pumpUi(tester, const ChecklistRow(title: 'Înscriere confirmată', subtitle: '4 membri', done: true));
    expect(find.byIcon(Icons.check), findsOneWidget);
    await pumpUi(tester, const ChecklistRow(title: 'Codul de start', subtitle: 'În ziua evenimentului', done: false));
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
  });

  group('EventHeroCard', () {
    testWidgets('shows the texts it is given', (tester) async {
      await pumpUi(tester, _hero());
      expect(find.text('LIVE'), findsOneWidget);
      expect(find.text('Treasure Hunt Sibiu'), findsOneWidget);
      expect(find.text('Echipa Vulturii · Misiunea 2 din 5'), findsOneWidget);
      expect(find.text('2:14:09 rămase'), findsOneWidget);
      expect(find.text('Continuă jocul'), findsOneWidget);
    });

    testWidgets('fires the primary action', (tester) async {
      var taps = 0;
      await pumpUi(tester, _hero(onPrimary: () => taps++));
      await tester.tap(find.text('Continuă jocul'));
      expect(taps, 1);
    });

    testWidgets('renders one segment per mission with the done ones filled',
        (tester) async {
      await pumpUi(tester, _hero(progressDone: 1, progressTotal: 5));
      expect(_segments(tester, 'done'), 1);
      expect(_segments(tester, 'current'), 1);
      expect(_segments(tester, 'todo'), 3);
    });

    testWidgets('renders no segments without progressTotal', (tester) async {
      await pumpUi(tester, _hero());
      expect(_segments(tester, ''), 0);
    });

    testWidgets('shows countdown tiles only when a countdown is given',
        (tester) async {
      await pumpUi(tester, _hero(countdown: const Duration(days: 3)));
      expect(find.byType(CountdownTiles), findsOneWidget);
      await pumpUi(tester, _hero());
      expect(find.byType(CountdownTiles), findsNothing);
    });

    testWidgets('shows the secondary button only when icon and callback are set',
        (tester) async {
      var taps = 0;
      await pumpUi(tester, _hero(secondaryIcon: Icons.chat_bubble_outline, onSecondary: () => taps++));
      await tester.tap(find.byIcon(Icons.chat_bubble_outline));
      expect(taps, 1);
      await pumpUi(tester, _hero(secondaryIcon: Icons.chat_bubble_outline));
      expect(find.byIcon(Icons.chat_bubble_outline), findsNothing);
    });

    testWidgets('survives empty image, no subtitle and a very long title at text scale 1.5',
        (tester) async {
      await pumpUi(
        tester,
        _hero(
          imageUrl: '',
          subtitle: null,
          timeChip: null,
          title: 'Un eveniment cu un titlu extrem de lung care nu are cum să încapă pe un singur rând',
        ),
        textScale: 1.5,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
