import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/enums/event_status.dart';
import 'package:teamxperience/features/admin/create_event/start/event_json_sample.dart';
import 'package:teamxperience/features/admin/create_event/start/import_errors_card.dart';
import 'package:teamxperience/features/admin/create_event/start/import_event_controller.dart';
import 'package:teamxperience/features/admin/create_event/start/import_event_page.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/service/event_service/event_service.dart';
import 'package:teamxperience/state_management/events_state_management.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

class _FakeEventService extends Fake implements EventService {
  _FakeEventService({this.fail = false});

  final bool fail;
  final saved = <Event>[];

  @override
  Future<Event> saveDraft(Event event, {int? wizardStep}) async {
    if (fail) throw Exception('offline');
    event
      ..status = EventStatus.draft
      ..wizardStep = wizardStep ?? event.wizardStep
      ..eventId = 'new-id';
    saved.add(event);
    return event;
  }
}

String _minimal(String name) => jsonEncode({'name': name});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('controller', () {
    test('a good text is saved as a draft and the saved event is returned', () async {
      Event? received;
      final c = ImportEventController(
        saveDraft: (event) async {
          received = event;
          return event..eventId = 'x';
        },
      );
      c.textController.text = _minimal('Din JSON');

      final saved = await c.import();

      expect(saved?.name, 'Din JSON');
      expect(received?.name, 'Din JSON');
      expect(c.errors, isEmpty);
      expect(c.busy, isFalse);
    });

    test('a bad text is not saved and the mistakes are kept for the screen', () async {
      var calls = 0;
      final c = ImportEventController(saveDraft: (e) async => calls++ == 0 ? e : e);
      c.textController.text = '{ nu e json';

      expect(await c.import(), isNull);
      expect(calls, 0);
      expect(c.errors, isNotEmpty);
    });

    test('mistakes are cleared when the next try works', () async {
      final c = ImportEventController(saveDraft: (e) async => e);
      c.textController.text = 'nope';
      await c.import();
      expect(c.errors, isNotEmpty);

      c.textController.text = _minimal('Bun');
      await c.import();
      expect(c.errors, isEmpty);
    });

    test('a failed save is reported, not thrown', () async {
      final c = ImportEventController(saveDraft: (e) async => throw Exception('offline'));
      c.textController.text = _minimal('Bun');

      expect(await c.import(), isNull);
      expect(c.errors.single, contains('offline'));
      expect(c.busy, isFalse);
    });

    test('it tells the screen when it starts and stops being busy', () async {
      final states = <bool>[];
      final c = ImportEventController(saveDraft: (e) async => e);
      c.addListener(() => states.add(c.busy));
      c.textController.text = _minimal('Bun');
      await c.import();
      expect(states.first, isTrue);
      expect(states.last, isFalse);
    });
  });

  group('clipboard', () {
    String? clipboard;

    setUp(() {
      clipboard = null;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            clipboard = (call.arguments as Map)['text'] as String?;
          }
          if (call.method == 'Clipboard.getData') {
            return clipboard == null ? null : {'text': clipboard};
          }
          return null;
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    test('pasting puts the clipboard text in the box', () async {
      clipboard = _minimal('Lipit');
      final c = ImportEventController(saveDraft: (e) async => e);
      await c.paste();
      expect(c.textController.text, _minimal('Lipit'));
    });

    test('pasting with an empty clipboard leaves the box as it was', () async {
      final c = ImportEventController(saveDraft: (e) async => e);
      c.textController.text = 'ce era';
      await c.paste();
      expect(c.textController.text, 'ce era');
    });

    test('copying the sample puts it on the clipboard', () async {
      final c = ImportEventController(saveDraft: (e) async => e);
      await c.copySample();
      expect(clipboard, eventJsonSample);
    });
  });

  group('page', () {
    Future<_FakeEventService> pump(WidgetTester tester, {bool fail = false, List<RouteSettings>? opened}) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final service = _FakeEventService(fail: fail);
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => EventList(service),
          child: MaterialApp(
            theme: AppTheme.light,
            routes: {
              Routes.createEvent: (context) {
                opened?.add(ModalRoute.of(context)!.settings);
                return const Scaffold(body: Text('formularul'));
              },
            },
            home: Builder(
              builder:
                  (context) => TextButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ImportEventPage())),
                    child: const Text('open'),
                  ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return service;
    }

    testWidgets('explains what it does and has the three buttons', (tester) async {
      await pump(tester);
      expect(find.text('Import din JSON'), findsOneWidget);
      expect(find.text('Lipește'), findsOneWidget);
      expect(find.text('Copiază un model'), findsOneWidget);
      expect(find.text('Importă ca ciornă'), findsOneWidget);
    });

    testWidgets('a good text becomes a draft and the form opens on it', (tester) async {
      final opened = <RouteSettings>[];
      final service = await pump(tester, opened: opened);

      await tester.enterText(find.byType(TextField), _minimal('Din JSON'));
      await tester.tap(find.text('Importă ca ciornă'));
      await tester.pumpAndSettle();

      expect(service.saved.single.name, 'Din JSON');
      expect(find.text('formularul'), findsOneWidget);
      final arguments = opened.single.arguments as Map;
      expect(arguments['isDraft'], isTrue);
      expect((arguments['event'] as Event).eventId, 'new-id');
    });

    testWidgets('a bad text shows what is wrong and stays on the page', (tester) async {
      final service = await pump(tester);

      await tester.enterText(find.byType(TextField), jsonEncode({'name': 'X', 'type': 'SECRET'}));
      await tester.tap(find.text('Importă ca ciornă'));
      await tester.pumpAndSettle();

      expect(
        find.descendant(of: find.byType(ImportErrorsCard), matching: find.textContaining('SECRET')),
        findsOneWidget,
      );
      expect(find.text('formularul'), findsNothing);
      expect(service.saved, isEmpty);
    });

    testWidgets('a failed save says so and stays on the page', (tester) async {
      await pump(tester, fail: true);

      await tester.enterText(find.byType(TextField), _minimal('Din JSON'));
      await tester.tap(find.text('Importă ca ciornă'));
      await tester.pumpAndSettle();

      expect(find.textContaining('offline'), findsOneWidget);
      expect(find.text('formularul'), findsNothing);
    });
  });
}
