import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/features/event_game/logic/photo_state.dart';
import 'package:teamxperience/features/event_game/logic/preview_team.dart';
import 'package:teamxperience/features/event_game/screen/puzzle_game_screen.dart';
import 'package:teamxperience/features/event_game/widgets/image_upload/photo_puzzle_view.dart';
import 'package:teamxperience/features/event_game/widgets/location_puzzle_view.dart';
import 'package:teamxperience/features/event_game/widgets/preview_skip_view.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/mission.dart';
import 'package:teamxperience/model/puzzle.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

const _small = Size(320, 568);

/// Far taller than a small phone: an organiser's long story above the map.
final _story = List.filled(60, 'Mergeți până la fântâna veche din piață.').join(' ');

Future<void> _useSmallPhone(WidgetTester tester) async {
  tester.view.physicalSize = _small * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
}

/// The real screen, in an organiser's walk-through, on a puzzle of [type].
Future<void> _pumpScreen(WidgetTester tester, PuzzleType type) async {
  await _useSmallPhone(tester);
  final mission = Mission(id: '0', title: 'Fântâna', puzzles: [
    for (final id in ['0', '1'])
      Puzzle(
        id: id,
        type: type,
        latitude: 45.79,
        longitude: 24.15,
        components: [Component(type: ComponentType.text, text: _story)],
      ),
  ]);
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.light,
    onGenerateRoute: (_) => MaterialPageRoute(
      settings: RouteSettings(arguments: {
        'mission': mission,
        'background': null,
        'event': Event(eventId: 'e', missions: [mission]),
        'team': previewTeamOf(now: DateTime(2026, 11, 8)),
        'missionIndex': 0,
        'preview': true,
      }),
      builder: (_) => const PuzzleGameScreen(),
    ),
  ));
  await tester.pump();
  await tester.pump(const Duration(seconds: 3));
}

/// One of the views the game draws, under a tall header, on a small phone.
Future<void> _pumpView(WidgetTester tester, Widget view) async {
  await _useSmallPhone(tester);
  await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: Scaffold(body: view)));
  await tester.pump();
}

/// How far the content of the puzzle has been scrolled.
double _scrolled(WidgetTester tester) => tester
    .state<ScrollableState>(find.descendant(of: find.byType(PreviewSkipView), matching: find.byType(Scrollable)))
    .position
    .pixels;

final _tallHeader = SizedBox(key: const ValueKey('tall-header'), height: 2000, child: Text(_story));

void main() {
  testWidgets('a location puzzle under long content: the button stays, and the map is reached by scrolling', (tester) async {
    await _pumpView(
      tester,
      LocationPuzzleView(
        state: LocationViewState.tracking,
        map: const SizedBox.expand(),
        inside: true,
        onEnter: () {},
        onOpenSettings: () {},
        header: _tallHeader,
      ),
    );
    expect(tester.takeException(), isNull);
    expect(tester.getBottomLeft(find.text('Intră în cerc')).dy, lessThanOrEqualTo(_small.height));

    final map = find.byKey(const ValueKey('location-map-card'));
    expect(tester.getTopLeft(map).dy, greaterThan(_small.height));
    await tester.dragUntilVisible(map, find.byType(SingleChildScrollView), const Offset(0, -400));
    expect(tester.getTopLeft(map).dy, lessThan(_small.height));
  });

  testWidgets('a photo puzzle under long content: the button stays', (tester) async {
    await _pumpView(
      tester,
      PhotoPuzzleView(
        step: PhotoStep.none,
        now: DateTime(2026, 11, 8),
        onTakePhoto: () {},
        onContinue: () {},
        onChat: () {},
        header: _tallHeader,
      ),
    );
    expect(tester.takeException(), isNull);
    expect(tester.getBottomLeft(find.text('Fă poza')).dy, lessThanOrEqualTo(_small.height));
  });

  testWidgets('a location puzzle with no content above it shows the map straight away', (tester) async {
    await _pumpView(
      tester,
      LocationPuzzleView(
        state: LocationViewState.tracking,
        map: const SizedBox.expand(),
        inside: true,
        onEnter: () {},
        onOpenSettings: () {},
      ),
    );
    expect(tester.takeException(), isNull);
    expect(tester.getTopLeft(find.byKey(const ValueKey('location-map-card'))).dy, lessThan(_small.height));
  });

  testWidgets('in a walk-through the next puzzle opens at its top', (tester) async {
    await _pumpScreen(tester, PuzzleType.geolocation);
    await tester.drag(find.byType(PreviewSkipView), const Offset(0, -300));
    await tester.pump();
    expect(_scrolled(tester), greaterThan(0));

    await tester.tap(find.text('Sari peste'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(_scrolled(tester), 0);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final type in [PuzzleType.geolocation, PuzzleType.imageToUpload]) {
    testWidgets('a long ${type.name} puzzle keeps its button on the screen', (tester) async {
      await _pumpScreen(tester, type);
      expect(tester.takeException(), isNull);
      expect(tester.getBottomLeft(find.text('Sari peste')).dy, lessThanOrEqualTo(_small.height));
      expect(find.textContaining('fântâna veche'), findsOneWidget);

      // Closing the screen stops its clock.
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
