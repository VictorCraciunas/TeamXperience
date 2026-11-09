import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/misc/app_svg_icon.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:teamxperience/model/user.dart';
import 'package:teamxperience/ui/components/navigation/my_appbar.dart';
import 'package:teamxperience/ui/components/buttons/app_button.dart';
import 'package:teamxperience/ui/components/feedback/snackbars.dart';
import 'package:teamxperience/ui/components/team/invite_code_card.dart';

import '../../../model/event.dart';
import '../../../utils/calendar_helper.dart';
import '../../../utils/image_helper.dart';
import 'package:teamxperience/ui/components/event/event_image.dart';
import '../../event_details/widgets/detail_widget.dart';
import '../controller/team_details_controller.dart';
import '../widgets/team_detail_widget.dart';
import '../widgets/team_members_row.dart';

class TeamDetailsScreen extends StatefulWidget {
  const TeamDetailsScreen({super.key});

  @override
  State<TeamDetailsScreen> createState() => _TeamDetailsScreenState();
}

class _TeamDetailsScreenState extends State<TeamDetailsScreen> {
  late TeamControllerDetails controller;
  bool isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!isInitialized) {
      final arguments =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (arguments == null) return;

      final event = arguments['event'] as Event;
      final user = arguments['user'] as AppUser;

      controller = TeamControllerDetails(user, event);
      isInitialized = true;
    }
  }

  @override
  void dispose() {
    if (isInitialized) {
      controller.disposeControllers();
    }
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      if (!controller.isEditing) {
        controller.populateControllers();
      }
      controller.isEditing = !controller.isEditing;
    });
  }

  Future<void> _saveChanges() async {
    setState(() => controller.isSaving = true);

    final success = await controller.savePhone();

    if (mounted) {
      if (!success) {
        MySnackBars.errorSnackBar(
          context,
          title: 'Eroare la salvare',
          message: 'Nu s-au putut salva modificările.',
        );
      }
      setState(() {
        controller.isSaving = false;
        if (success) {
          controller.isEditing = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final eventDateTime = CalendarHelper.formatEventDateTime(
      controller.event.dateEvent,
    );

    return Scaffold(
      appBar: const MyAppBar(appBarText: "Confirmare înscriere"),
      body: SafeArea(
        child: FutureBuilder(
          future: controller.initializeTeam(),
          builder: (context, snapshot) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final team = controller.team;

            if (team == null) {
              return const Center(child: Text('No team found for this event'));
            }

            final eventDate = eventDateTime['date'] ?? '';
            final eventTime = eventDateTime['time'] ?? '';

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.page),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EventImage(
                      event: controller.event,
                      eventImageCache: ImageHelper.eventImageCache,
                      isAdmin: false,
                      height: 194,
                      nrTeams: controller.teams.length,
                      nrPerson: team.userIds.length,
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        controller.event.name ?? "Nu avem nume eveniment",
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w600,
                          color: context.colors.text,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    DetailWidget(
                      text1: eventDate,
                      text2: eventTime,
                      iconPath: 'assets/images/calendar_icon.svg',
                    ),
                    const SizedBox(height: 10),
                    DetailWidget(
                      text1: controller.event.location ?? "No Location",
                      text2:
                          'Punct de start: ${controller.event.punctDeStart ?? "No starting point"}',
                      iconPath: 'assets/images/location_map.svg',
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Detalii înscriere",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color: context.colors.text,
                          ),
                        ),
                        GestureDetector(
                          onTap: controller.isSaving ? null : _toggleEditMode,
                          child: Text(
                            controller.isEditing ? "Anulează" : "Editează",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: context.colors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TeamDetailWidget(text1: "Nume echipă", text2: team.name),
                    const SizedBox(height: 15),
                    TeamMembersRow(
                      title: "Componență echipă",
                      members: team.memberList,
                    ),
                    const SizedBox(height: 15),
                    TeamDetailWidget(
                      text1: "Nume căpitan",
                      text2: team.captainName,
                    ),
                    const SizedBox(height: 15),
                    TeamDetailWidget(
                      text1: "Email capitan",
                      text2: team.captainEmail,
                    ),
                    const SizedBox(height: 15),
                    TeamDetailWidget(
                      text1: "Telefon",
                      text2: team.phoneNumber,
                      isEditing: controller.isEditing,
                      editingController: controller.phoneController,
                    ),

                    if (controller.showsInviteCode) ...[
                      const SizedBox(height: 20),
                      InviteCodeCard(
                        code: controller.displayInviteCode ?? '',
                        caption: 'Codul echipei',
                        shareLabel: 'WhatsApp',
                        copyLabel: 'Copiază',
                        onShare: () => controller.shareInvite(context),
                        onCopy: () => controller.copyInvite(context),
                      ),
                    ],
                    const SizedBox(height: 30),
                    if (controller.isEditing)
                      AppButton(
                        label:
                            controller.isSaving
                                ? "Se salvează..."
                                : "Salvează schimbările",
                        onPressed: controller.isSaving ? () {} : _saveChanges,
                      )
                    else
                      AppButton(
                        label: "Distribuie detaliile",
                        onPressed:
                            () => controller.shareTeamRegistration(context),
                        leading: AppSvgIcon(
                          'assets/images/download.svg',
                          width: 19,
                          height: 19,
                        ),
                      ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
