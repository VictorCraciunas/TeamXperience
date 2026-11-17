import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/ui/theme/app_radius.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';

import '../logic/event_menu_action.dart';
import '../logic/event_menu_texts.dart';
import 'event_menu_feature_row.dart';
import 'event_menu_row.dart';

/// Opens the organiser's ⋮ sheet for [event]. The counts follow [teams] while
/// it is open, starting from [initialTeams]. Resolves to what was picked, or
/// null when closed; the page acts on it once the sheet is gone.
Future<EventMenuAction?> showEventMenuSheet(
  BuildContext context, {
  required Event event,
  required Stream<List<Team>> teams,
  List<Team> initialTeams = const [],
}) {
  final colors = context.colors;
  return showModalBottomSheet<EventMenuAction>(
    context: context,
    isScrollControlled: true,
    backgroundColor: colors.panel,
    barrierColor: colors.scrim,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.hero)),
    ),
    builder: (_) => EventMenuSheet(
      event: event,
      teams: teams,
      initialTeams: initialTeams,
      now: DateTime.now(),
    ),
  );
}

/// "Acțiuni pentru eveniment": the live room, the teams and their chats at the
/// top, then editing, trying, duplicating and deleting the event.
class EventMenuSheet extends StatelessWidget {
  const EventMenuSheet({
    super.key,
    required this.event,
    required this.teams,
    required this.now,
    this.initialTeams = const [],
  });

  final Event event;
  final Stream<List<Team>> teams;
  final List<Team> initialTeams;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    void pick(EventMenuAction action) => Navigator.of(context).pop(action);

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        child: Semantics(
          label: 'Acțiuni pentru eveniment',
          container: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 10),
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
              Flexible(
                child: StreamBuilder<List<Team>>(
                  stream: teams,
                  initialData: initialTeams,
                  builder: (context, snapshot) {
                    final list = snapshot.data ?? initialTeams;
                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.name ?? 'Eveniment',
                                  style: TextStyle(color: colors.text, fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  eventMenuHeadline(event, list.length, now),
                                  style: TextStyle(color: colors.muted, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          EventMenuFeatureRow(
                            icon: TablerIcons.activity,
                            iconColor: colors.live,
                            iconBackground: colors.dangerSoft,
                            title: 'Camera live',
                            subtitle: 'Harta, echipele, anunțuri, oprire',
                            onTap: () => pick(EventMenuAction.liveRoom),
                          ),
                          EventMenuFeatureRow(
                            icon: TablerIcons.users,
                            iconColor: colors.accent,
                            iconBackground: colors.iconButtonBg,
                            title: 'Echipe înscrise',
                            subtitle: registeredTeamsLine(list.length, playersOf(list)),
                            onTap: () => pick(EventMenuAction.registeredTeams),
                          ),
                          EventMenuFeatureRow(
                            icon: TablerIcons.message_circle,
                            iconColor: colors.accent,
                            iconBackground: colors.iconButtonBg,
                            title: 'Conversații',
                            subtitle: 'Chat cu fiecare echipă',
                            badge: unreadConversations(list),
                            onTap: () => pick(EventMenuAction.conversations),
                          ),
                          Divider(height: 13, thickness: 1, indent: 8, endIndent: 8, color: colors.insetBorder),
                          EventMenuRow(
                            icon: TablerIcons.pencil,
                            label: 'Editează evenimentul',
                            onTap: () => pick(EventMenuAction.edit),
                          ),
                          EventMenuRow(
                            icon: TablerIcons.eye,
                            label: 'Încearcă jocul ca jucător',
                            onTap: () => pick(EventMenuAction.tryAsPlayer),
                          ),
                          EventMenuRow(
                            icon: TablerIcons.copy,
                            label: 'Duplică pentru o nouă dată',
                            onTap: () => pick(EventMenuAction.duplicate),
                          ),
                          Divider(height: 13, thickness: 1, indent: 8, endIndent: 8, color: colors.insetBorder),
                          EventMenuRow(
                            icon: TablerIcons.trash,
                            label: 'Șterge evenimentul',
                            danger: true,
                            onTap: () => pick(EventMenuAction.delete),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
