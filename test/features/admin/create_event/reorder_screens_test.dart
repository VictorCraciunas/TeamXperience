import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/gestures.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/controller/add_missions_controller.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/screen/add_missions_screen.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/screen/mission_page.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/mission.dart';
import 'package:teamxperience/model/puzzle.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

Puzzle _puzzle(String id, PuzzleType type) => Puzzle(id: id, type: type);

/// Mission 1 has one puzzle, mission 2 has two, so they can be told apart.
Event _event() => Event(
      eventId: 'e',
      name: 'Hunt',
      missions: [
        Mission(id: '0', puzzles: [_puzzle('0', PuzzleType.code)]),
        Mission(id: '1', puzzles: [_puzzle('0', PuzzleType.code), _puzzle('1', PuzzleType.geolocation)]),
      ],
    )..nrMissions = 2;

void _tall(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _pumpList(WidgetTester tester, Event event) async {
  _tall(tester);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      onGenerateRoute:
          (_) => MaterialPageRoute(
            settings: RouteSettings(arguments: {'event': event, 'mode': 'create'}),
            builder: (_) => const AddMissionsPage(),
          ),
    ),
  );
}

Future<void> _pumpMission(WidgetTester tester, AddMissionsController controller) async {
  _tall(tester);
  await tester.pumpWidget(
    MaterialApp(theme: AppTheme.light, home: MissionPage(controller: controller, index: 1)),
  );
}

/// Hold on [from], then drag it by [by].
Future<void> _holdAndDrag(WidgetTester tester, Finder from, Offset by) async {
  final gesture = await tester.startGesture(tester.getCenter(from));
  await tester.pump(kLongPressTimeout + const Duration(milliseconds: 200));
  await gesture.moveBy(Offset(0, by.dy / 2));
  await tester.pump(const Duration(milliseconds: 100));
  await gesture.moveBy(Offset(0, by.dy / 2));
  await tester.pump(const Duration(milliseconds: 100));
  await gesture.up();
  await tester.pumpAndSettle();
}

double _top(WidgetTester tester, String text) => tester.getTopLeft(find.textContaining(text)).dy;

void main() {
  group('missions list', () {
    testWidgets('holding a mission and dragging it down moves it', (tester) async {
      await _pumpList(tester, _event());
      expect(_top(tester, '1 puzzle'), lessThan(_top(tester, '2 puzzle-uri')));

      await _holdAndDrag(tester, find.text('Misiunea 1'), const Offset(0, 140));

      expect(_top(tester, '2 puzzle-uri'), lessThan(_top(tester, '1 puzzle')));
    });

    testWidgets('after a move the numbers still follow the order', (tester) async {
      await _pumpList(tester, _event());
      await _holdAndDrag(tester, find.text('Misiunea 1'), const Offset(0, 140));
      expect(_top(tester, 'Misiunea 1'), lessThan(_top(tester, 'Misiunea 2')));
      expect(_top(tester, '2 puzzle-uri'), lessThan(_top(tester, '1 puzzle')));
    });

    testWidgets('a short tap still opens the mission', (tester) async {
      await _pumpList(tester, _event());
      await tester.tap(find.text('Misiunea 2'));
      await tester.pumpAndSettle();
      expect(find.text('Adaugă puzzle'), findsOneWidget);
    });

    testWidgets('the buttons below the list are still there', (tester) async {
      await _pumpList(tester, _event());
      expect(find.text('Adaugă misiune'), findsOneWidget);
      expect(find.text('Creează eveniment'), findsOneWidget);
    });
  });

  group('puzzles in a mission', () {
    testWidgets('holding a puzzle and dragging it down moves it', (tester) async {
      final controller = AddMissionsController(_event(), 'create');
      await _pumpMission(tester, controller);
      expect(_top(tester, 'Puzzle 1 · Cod'), lessThan(_top(tester, 'Puzzle 2 · Locație')));

      await _holdAndDrag(tester, find.text('Puzzle 1 · Cod'), const Offset(0, 140));

      final puzzles = controller.event.missions[1].puzzles;
      expect(puzzles.map((p) => p.type), [PuzzleType.geolocation, PuzzleType.code]);
      expect(puzzles.map((p) => p.id), ['0', '1']);
      expect(_top(tester, 'Puzzle 1 · Locație'), lessThan(_top(tester, 'Puzzle 2 · Cod')));
    });

    testWidgets('the add button stays under the puzzles', (tester) async {
      await _pumpMission(tester, AddMissionsController(_event(), 'create'));
      expect(find.text('Adaugă puzzle'), findsOneWidget);
    });
  });
}
