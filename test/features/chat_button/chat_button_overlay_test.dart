import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/features/chat_button/controller/chat_button_spots.dart';
import 'package:teamxperience/features/chat_button/controller/chat_route_watch.dart';
import 'package:teamxperience/features/chat_button/logic/chat_on_top.dart';
import 'package:teamxperience/features/chat_button/logic/watched_chat.dart';
import 'package:teamxperience/features/chat_button/widgets/chat_button_clearance.dart';
import 'package:teamxperience/features/chat_button/widgets/chat_button_overlay.dart';
import 'package:teamxperience/features/chat_button/widgets/chat_button_scope.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

import 'chat_button_test_helpers.dart';

final _button = find.byKey(const ValueKey('chat-float-button'));
final _bubble = find.byKey(const ValueKey('chat-preview-bubble'));

/// The app's layer around a navigator, as MaterialApp.builder puts it.
class _Harness {
  _Harness(this.rig);

  final ControllerRig rig;
  final routes = ChatRouteWatch();
  final spots = ChatButtonSpots();
  final opened = <WatchedChat>[];

  Future<void> pump(
    WidgetTester tester, {
    required Widget home,
    bool player = true,
    Size size = const Size(390, 844),
    double textScale = 1,
    ThemeData? theme,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    routes.addListener(() {
      final top = routes.top;
      rig.controller.chatOnTop(top == null ? null : chatOnTop(top.name, top.arguments));
    });
    await tester.pumpWidget(
      MaterialApp(
        theme: theme ?? AppTheme.light,
        navigatorObservers: [routes],
        builder: (context, app) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
          child: ChatButtonScope(
            spots: spots,
            child: ChatButtonOverlay(
              controller: rig.controller,
              routes: routes,
              spots: spots,
              player: player,
              onOpen: opened.add,
              child: app ?? const SizedBox.shrink(),
            ),
          ),
        ),
        home: home,
        routes: {Routes.chatScreen: (_) => const Scaffold(body: Text('Chat'))},
      ),
    );
    await tester.pump();
  }
}

Future<void> _flush(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.pump();
  }
}

void main() {
  final vulpile = chat('e1', 'Vulpile');

  Future<ControllerRig> watching(WidgetTester tester) async {
    final rig = ControllerRig();
    rig.store.values[vulpile.key] = t0;
    rig.controller.watch([vulpile]);
    await _flush(tester);
    return rig;
  }

  testWidgets('nothing unread: no button', (tester) async {
    final rig = await watching(tester);
    final harness = _Harness(rig);
    await harness.pump(tester, home: const Scaffold(body: Text('Acasă')));
    rig.chats.send(vulpile.key, [player(1), organiser(-5)]);
    await _flush(tester);
    expect(_button, findsNothing);
    expect(find.byType(ChatButtonOverlay), findsOneWidget);
    rig.controller.dispose();
  });

  testWidgets('an unread organiser message shows the button; tapping opens that chat', (tester) async {
    final rig = await watching(tester);
    final harness = _Harness(rig);
    await harness.pump(tester, home: const Scaffold(body: Text('Acasă')));
    rig.chats.send(vulpile.key, [organiser(1), organiser(2)]);
    await _flush(tester);
    expect(_button, findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.bySemanticsLabel('Deschide chatul cu organizatorul, 2 mesaje noi'), findsOneWidget);

    await tester.tap(_button);
    expect(harness.opened.single.key, vulpile.key);
    rig.controller.dispose();
  });

  testWidgets('organisers never see it', (tester) async {
    final rig = await watching(tester);
    await _Harness(rig).pump(tester, home: const Scaffold(body: Text('Acasă')), player: false);
    rig.chats.send(vulpile.key, [organiser(1)]);
    await _flush(tester);
    expect(_button, findsNothing);
    rig.controller.dispose();
  });

  testWidgets('the chat page on top hides the button and reads the chat', (tester) async {
    final rig = await watching(tester);
    final harness = _Harness(rig);
    await harness.pump(tester, home: const Scaffold(body: Text('Acasă')));
    rig.chats.send(vulpile.key, [organiser(1)]);
    await _flush(tester);
    expect(_button, findsOneWidget);

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed(Routes.chatScreen, arguments: vulpile.routeArguments);
    await tester.pumpAndSettle();
    expect(_button, findsNothing);
    expect(rig.controller.unread, 0);
    expect(rig.store.values[vulpile.key], t0.add(const Duration(minutes: 1)));

    navigator.pop();
    await tester.pumpAndSettle();
    expect(_button, findsNothing);
    rig.controller.dispose();
  });

  testWidgets('a dialog on top hides the button', (tester) async {
    final rig = await watching(tester);
    await _Harness(rig).pump(tester, home: const Scaffold(body: Text('Acasă')));
    rig.chats.send(vulpile.key, [organiser(1)]);
    await _flush(tester);
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    showDialog<void>(context: navigator.context, builder: (_) => const AlertDialog(content: Text('Sigur?')));
    await tester.pumpAndSettle();
    expect(_button, findsNothing);
    rig.controller.dispose();
  });

  testWidgets('the button sits above a page bar reported with ChatButtonClearance', (tester) async {
    final rig = await watching(tester);
    await _Harness(rig).pump(
      tester,
      home: const Scaffold(
        body: Text('Puzzle'),
        bottomNavigationBar: ChatButtonClearance.bar(child: SizedBox(height: 90, child: Text('Indiciu'))),
      ),
    );
    rig.chats.send(vulpile.key, [organiser(1)]);
    await _flush(tester);
    await tester.pumpAndSettle();
    final buttonBottom = tester.getBottomLeft(_button).dy;
    final barTop = tester.getTopLeft(find.text('Indiciu')).dy;
    expect(buttonBottom, lessThanOrEqualTo(barTop - ChatButtonOverlay.aboveBar + 0.5));
    rig.controller.dispose();
  });

  testWidgets('a page part that hides it hides it', (tester) async {
    final rig = await watching(tester);
    await _Harness(rig).pump(
      tester,
      home: const Scaffold(body: ChatButtonClearance.hide(child: Text('Joacă'))),
    );
    rig.chats.send(vulpile.key, [organiser(1)]);
    await _flush(tester);
    expect(_button, findsNothing);
    rig.controller.dispose();
  });

  for (final theme in [AppTheme.light, AppTheme.dark]) {
    testWidgets('button and preview fit a small phone at text scale 2 (${theme.brightness.name})', (tester) async {
      final rig = await watching(tester);
      await _Harness(rig).pump(
        tester,
        home: const Scaffold(body: Text('Acasă')),
        size: const Size(320, 640),
        textScale: 2,
        theme: theme,
      );
      rig.chats.send(vulpile.key, []);
      await _flush(tester);
      rig.chats.send(vulpile.key, [
        organiser(1, 'Întâlnirea se mută la poarta de nord a Pieței Mici, lângă fântâna cea mare din colț.'),
      ]);
      await _flush(tester);
      await tester.pump(const Duration(milliseconds: 250));
      expect(_bubble, findsOneWidget);
      expect(find.text('Organizator · acum'), findsOneWidget);
      expect(tester.takeException(), isNull);
      final bubble = tester.getRect(_bubble);
      expect(bubble.left, greaterThanOrEqualTo(0));
      expect(bubble.height, greaterThanOrEqualTo(44));
      expect(tester.getSize(_button).width, greaterThanOrEqualTo(44));

      // The preview goes after a while; the button stays.
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(_bubble, findsNothing);
      expect(_button, findsOneWidget);
      rig.controller.dispose();
    });
  }
}
