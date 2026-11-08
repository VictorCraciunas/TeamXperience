import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/enums/event_type.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/controller/add_missions_controller.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/mission.dart';
import 'package:teamxperience/model/puzzle.dart';
import 'package:teamxperience/service/event_service/event_service.dart';
import 'package:teamxperience/service/event_service/event_status_changes.dart';
import 'package:teamxperience/state_management/events_state_management.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

/// Writes nothing; remembers how the event would have been saved.
class _Service extends Fake implements EventService {
  final saved = <String>[];

  @override
  Future<Event> publishEvent(Event event) async {
    final ready = asPublished(event, now: DateTime(2026, 11, 9));
    saved.add('publish');
    return ready;
  }

  @override
  Future<Event> updateEvent(Event event) async {
    saved.add('update');
    return event;
  }
}

Event _event({String answer = 'ABCD'}) => Event(
      eventId: 'e',
      name: 'Xtreme',
      description: 'Un joc',
      location: 'Sibiu',
      punctDeStart: 'Piața Mare',
      finishPoint: 'Turnul Sfatului',
      startLatitude: 45.79,
      startLongitude: 24.15,
      dateEvent: DateTime(2027, 5, 15, 18),
      dateStartEnrollment: DateTime(2027, 5, 1),
      dateDeadlineEnrollment: DateTime(2027, 5, 14),
      type: EventType.PUBLIC,
      startCode: 'XTREME',
      routeLengthKm: 3,
      durationMinutes: 120,
      dificultate: 'Medie',
      missions: [
        Mission(id: '0', title: 'Ceasul', puzzles: [
          Puzzle(id: '0', type: PuzzleType.code, code: answer, components: [
            Component(type: ComponentType.code, codeLength: 4, inputType: 'Separated'),
            Component(type: ComponentType.button, buttonLabel: 'Verifică'),
          ]),
        ]),
      ],
    );

/// Presses save on the missions page; what it answered, and how it was saved.
Future<(bool?, List<String>)> _save(WidgetTester tester, Event event, String mode, {bool isDraft = false}) async {
  final service = _Service();
  final list = EventList(service);
  late BuildContext context;
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.light,
    home: ChangeNotifierProvider<EventList>.value(
      value: list,
      child: Scaffold(
        body: Builder(builder: (c) {
          context = c;
          return const SizedBox.shrink();
        }),
      ),
    ),
  ));

  bool? result;
  AddMissionsController(event, mode, isDraft: isDraft).saveEvent(context).then((worked) => result = worked);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  return (result, service.saved);
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 10));
}

void main() {
  group('a new event', () {
    testWidgets('that is complete goes live through the publish check', (tester) async {
      final (worked, saved) = await _save(tester, _event(), 'create');
      expect(worked, isTrue);
      expect(saved, ['publish']);
      await _settle(tester);
    });

    testWidgets('with an answer that does not fit its boxes is not saved, and says why', (tester) async {
      final (worked, saved) = await _save(tester, _event(answer: 'ABCDE'), 'create');
      expect(worked, isFalse);
      expect(saved, isEmpty);
      expect(find.textContaining('răspunsul nu încape în căsuțe'), findsOneWidget);
      await _settle(tester);
    });

    testWidgets('that is incomplete is not saved', (tester) async {
      final (worked, saved) = await _save(tester, _event()..finishPoint = null, 'create');
      expect(worked, isFalse);
      expect(saved, isEmpty);
      await _settle(tester);
    });
  });

  group('editing a live event', () {
    testWidgets('saves it', (tester) async {
      final (worked, saved) = await _save(tester, _event(), 'edit');
      expect(worked, isTrue);
      expect(saved, ['update']);
      await _settle(tester);
    });

    testWidgets('an older event without the newer details can still be saved', (tester) async {
      final older = _event()
        ..finishPoint = null
        ..startLatitude = null
        ..startLongitude = null;
      final (worked, saved) = await _save(tester, older, 'edit');
      expect(worked, isTrue);
      expect(saved, ['update']);
      await _settle(tester);
    });

    testWidgets('an answer that does not fit its boxes is refused, and says why', (tester) async {
      final (worked, saved) = await _save(tester, _event(answer: 'ABCDE'), 'edit');
      expect(worked, isFalse);
      expect(saved, isEmpty);
      expect(find.text('Evenimentul nu poate fi salvat'), findsOneWidget);
      expect(find.textContaining('răspunsul nu încape în căsuțe'), findsOneWidget);
      await _settle(tester);
    });

    testWidgets('team sizes the wrong way round are refused', (tester) async {
      final reversed = _event()
        ..teamSizeMin = 6
        ..teamSizeMax = 2;
      final (worked, saved) = await _save(tester, reversed, 'edit');
      expect(worked, isFalse);
      expect(saved, isEmpty);
      await _settle(tester);
    });
  });

  testWidgets('a draft goes on being published through the check', (tester) async {
    final (worked, saved) = await _save(tester, _event(), 'edit', isDraft: true);
    expect(worked, isTrue);
    expect(saved, ['publish']);
    await _settle(tester);
  });
}
