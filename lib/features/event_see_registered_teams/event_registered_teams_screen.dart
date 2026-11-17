import 'package:flutter/material.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/features/live_room/controller/live_room_controller.dart' show CallResult;
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/ui/components/feedback/app_dialog.dart';
import 'package:teamxperience/ui/components/feedback/load_failed.dart';
import 'package:teamxperience/ui/components/feedback/snackbars.dart';
import 'package:teamxperience/ui/ui.dart';

import 'event_registered_teams_controller.dart';
import 'logic/registered_teams_texts.dart';
import 'widgets/registered_teams_header.dart';
import 'widgets/registered_teams_list.dart';

/// The organiser's "Echipe înscrise" for one event (route argument: the
/// [Event]).
class EventRegisteredTeams extends StatefulWidget {
  const EventRegisteredTeams({super.key, this.createController});

  /// Builds the controller for the event; tests pass one that reads no
  /// Firebase.
  final EventRegisteredTeamsController Function(Event event)? createController;

  @override
  State<EventRegisteredTeams> createState() => _EventRegisteredTeamsState();
}

class _EventRegisteredTeamsState extends State<EventRegisteredTeams> {
  EventRegisteredTeamsController? _controller;
  final _search = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) return;
    final event = ModalRoute.of(context)?.settings.arguments as Event?;
    if (event == null) return;
    final controller = widget.createController?.call(event) ?? EventRegisteredTeamsController(event);
    _controller = controller;
    controller.loadTeams();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(EventRegisteredTeamsController controller, Team team) async {
    final confirmed = await showAppDialog(
      context,
      title: 'Confirmare',
      message: 'Ești sigur că vrei să ștergi echipa înregistrată?',
      confirmLabel: 'Șterge',
      cancelLabel: 'Anulează',
      destructive: true,
    );
    if (!confirmed) return;

    try {
      await controller.deleteTeam(team);
      if (!mounted) return;
      MySnackBars.successSnackBar(context, title: 'Echipa a fost ștearsă cu succes');
    } catch (e) {
      if (!mounted) return;
      MySnackBars.errorSnackBar(context, title: 'Eroare la ștergerea echipei', message: e.toString());
    }
  }

  Future<void> _call(EventRegisteredTeamsController controller, Team team) async {
    final result = await controller.callCaptain(team);
    if (!mounted) return;
    switch (result) {
      case CallResult.opened:
        break;
      case CallResult.noPhone:
        MySnackBars.errorSnackBar(context, title: 'Echipa nu are număr de telefon.');
      case CallResult.failed:
        MySnackBars.errorSnackBar(context, title: 'Nu am putut deschide telefonul.');
    }
  }

  void _message(EventRegisteredTeamsController controller, Team team) {
    Navigator.pushNamed(
      context,
      Routes.chatScreen,
      arguments: {'eventId': controller.event.eventId, 'team': team},
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RegisteredTeamsHeader(
            subtitle: eventSubtitle(controller.event),
            onBack: () => Navigator.maybePop(context),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: controller,
              builder: (context, _) {
                if (controller.isLoading) return const Center(child: CircularProgressIndicator());
                if (controller.failed) {
                  return LoadFailed(message: 'Nu am putut încărca echipele.', onRetry: controller.loadTeams);
                }
                if (controller.teams.isEmpty) {
                  return Center(
                    child: Text('Nicio echipă înscrisă', style: AppTextStyles.bodyMuted(context)),
                  );
                }
                return RegisteredTeamsList(
                  controller: controller,
                  searchController: _search,
                  onCall: (team) => _call(controller, team),
                  onMessage: (team) => _message(controller, team),
                  onRemove: (team) => _confirmDelete(controller, team),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
