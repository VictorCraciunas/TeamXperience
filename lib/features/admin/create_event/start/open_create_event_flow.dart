import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/features/admin/create_event/start/create_event_start_sheet.dart';
import 'package:teamxperience/state_management/events_state_management.dart';

/// Asks how to begin ("De la zero", an old event or a draft), then opens the
/// event form accordingly. Does nothing if the sheet is closed.
Future<void> openCreateEventFlow(BuildContext context) async {
  final eventList = context.read<EventList>();
  final navigator = Navigator.of(context);

  final start = await showCreateEventStartSheet(
    context,
    drafts: eventList.draftEvents,
    oldEvents: eventList.events,
  );
  if (start == null) return;

  navigator.pushNamed(Routes.createEvent, arguments: start.arguments);
}
