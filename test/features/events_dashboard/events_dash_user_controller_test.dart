import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/features/events_dashboard/events_dashboard_user/controller/events_dash_user_controller.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/state_management/user_provider.dart';

Event _event(String id) => Event(eventId: id, name: 'Eveniment $id');

Future<EventsDashboardUserController> _controller(
  WidgetTester tester,
  List<Event> events,
) async {
  late EventsDashboardUserController controller;
  await tester.pumpWidget(
    ChangeNotifierProvider<UserProvider>(
      create: (_) => UserProvider(),
      child: Builder(
        builder: (context) {
          controller = EventsDashboardUserController(events, context);
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  return controller;
}

void main() {
  testWidgets('lists the events it was created with', (tester) async {
    final controller = await _controller(tester, [_event('a')]);
    expect(controller.events.map((e) => e.eventId), ['a']);
  });

  testWidgets('updateEvents replaces the list and notifies', (tester) async {
    final controller = await _controller(tester, [_event('a')]);
    var notifications = 0;
    controller.addListener(() => notifications++);
    controller.updateEvents([_event('a'), _event('b')]);
    expect(controller.events.map((e) => e.eventId), ['a', 'b']);
    expect(notifications, 1);
  });

  testWidgets('a search still applies after the list is updated', (tester) async {
    final controller = await _controller(tester, [_event('a')]);
    controller.searchEvents('Eveniment b');
    controller.updateEvents([_event('a'), _event('b')]);
    expect(controller.events.map((e) => e.eventId), ['b']);
  });
}
