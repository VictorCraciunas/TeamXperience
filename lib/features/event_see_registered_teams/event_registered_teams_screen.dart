import 'package:teamxperience/ui/components/feedback/load_failed.dart';
import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/ui/components/feedback/app_dialog.dart';
import 'package:teamxperience/ui/components/feedback/snackbars.dart';
import 'package:teamxperience/ui/components/navigation/my_appbar.dart';

import 'event_registered_teams_controller.dart';
import 'widgets/team_card_widget.dart';

class EventRegisteredTeams extends StatefulWidget {
  const EventRegisteredTeams({super.key});

  @override
  State<EventRegisteredTeams> createState() => _EventRegisteredTeamsState();
}

class _EventRegisteredTeamsState extends State<EventRegisteredTeams> {
  late EventRegisteredTeamsController controller;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final event = ModalRoute.of(context)?.settings.arguments as Event?;
      if (event == null) return;

      controller = EventRegisteredTeamsController(event);
      _initialized = true;
      _loadTeams();
    }
  }

  Future<void> _loadTeams() async {
    await controller.loadTeams();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _confirmDelete(Team team) async {
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
      setState(() {});
      MySnackBars.successSnackBar(
        context,
        title: "Echipa a fost ștearsă cu succes",
      );
    } catch (e) {
      if (!mounted) return;
      MySnackBars.errorSnackBar(
        context,
        title: "Eroare la ștergerea echipei",
        message: e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: const MyAppBar(appBarText: "Echipe înscrise"),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : controller.failed
          ? LoadFailed(
              message: 'Nu am putut încărca echipele.',
              onRetry: () {
                setState(() => controller.isLoading = true);
                _loadTeams();
              },
            )
          : controller.teams.isEmpty
              ? Center(
                  child: Text(
                    "Nicio echipă înscrisă",
                    style: TextStyle(fontSize: 16, color: context.colors.muted),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.page,
                    vertical: 16,
                  ),
                  itemCount: controller.teams.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final team = controller.teams[index];
                    return TeamCardWidget(
                      team: team,
                      onDelete: () => _confirmDelete(team),
                    );
                  },
                ),
    );
  }
}
