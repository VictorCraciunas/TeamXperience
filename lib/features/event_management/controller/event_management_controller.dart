import 'package:flutter/material.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/service/event_service/event_service.dart';
import 'package:teamxperience/service/team_service/team_service.dart';
import 'package:teamxperience/ui/components/feedback/app_dialog.dart';

class EventManagementController extends ChangeNotifier {
  final BuildContext context;
  final Event event;
  final EventService _eventService = EventService();
  final TeamService _teamService = TeamService();

  bool _isStopping = false;
  bool get isStopping => _isStopping;

  EventManagementController(this.context, this.event);

  bool get hasStarted {
    final d = event.dateEvent;
    return d != null && d.isBefore(DateTime.now());
  }

  bool get isStopped => event.isOver;
  bool get canStop => hasStarted && !event.isOver && !_isStopping;

  void navigateToNotification() {
    Navigator.pushNamed(
      context,
      Routes.sendNotification,
      arguments: event,
    );
  }

  void navigateToMap() {
    final Stream<List<Team>> teams = _teamService.getStreamTeams(event.eventId);
    Navigator.pushNamed(
      context,
      Routes.map,
      arguments: {
        'eventId': event.eventId,
        'teams': teams,
      },
    );
  }

  void navigateToChat() {
    Navigator.pushNamed(
      context,
      Routes.teamConversations,
      arguments: event,
    );
  }

  Future<void> confirmAndStop() async {
    final confirmed = await showAppDialog(
      context,
      title: 'Oprește evenimentul',
      message: 'Toate echipele vor vedea un mesaj că evenimentul s-a terminat. Ești sigur?',
      confirmLabel: 'Oprește',
      cancelLabel: 'Anulează',
      destructive: true,
    );

    if (!confirmed) return;

    _isStopping = true;
    notifyListeners();
    try {
      await _eventService.stopEvent(event.eventId);
      event.isStopped = true;
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nu am putut opri evenimentul.")),
      );
    } finally {
      _isStopping = false;
      notifyListeners();
    }
  }
}
