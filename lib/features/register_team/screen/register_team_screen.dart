import 'package:teamxperience/features/register_team/widgets/crew_choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/features/register_team/controller/register_team_controller.dart';
import 'package:teamxperience/features/register_team/widgets/invite_result_section.dart';
import 'package:teamxperience/features/register_team/widgets/register_form.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/ui/components/navigation/screen_bar.dart';
import 'package:teamxperience/utils/event_formats.dart';

class RegisterTeamScreen extends StatefulWidget {
  const RegisterTeamScreen({super.key});

  @override
  State<RegisterTeamScreen> createState() => _RegisterTeamScreenState();
}

class _RegisterTeamScreenState extends State<RegisterTeamScreen> {
  RegisterTeamController? _controller;
  final GlobalKey _resultKey = GlobalKey();
  bool _resultShown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) return;
    final event = ModalRoute.of(context)?.settings.arguments;
    if (event is! Event) return;
    _controller = RegisterTeamController(context: context, event: event)
      ..addListener(_scrollToResult);
  }

  /// Brings the invite card into view the first time it appears.
  void _scrollToResult() {
    final controller = _controller;
    if (controller == null || !controller.registered || _resultShown) return;
    _resultShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _resultKey.currentContext;
      if (target == null || !target.mounted) return;
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) return const Scaffold();
    final event = controller.event;
    final date = event.dateEvent;
    final subtitle = [
      if (event.name != null) event.name,
      if (date != null) dayAndMonth(date),
    ].join(' · ');

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Scaffold(
          body: Column(
            children: [
              ScreenBar(
                leadingIcon: TablerIcons.x,
                onLeading: controller.close,
                title: 'Înscrie echipa',
                subtitle: subtitle.isEmpty ? null : subtitle,
              ),
              Expanded(
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      children: [
                        if (controller.crews.isNotEmpty &&
                            !controller.registered)
                          CrewChoice(
                            crews: controller.crews,
                            chosen: controller.chosenCrew,
                            onChoose: controller.chooseCrew,
                          ),
                        RegisterForm(
                          nameController: controller.nameController,
                          phoneController: controller.phoneController,
                          onNameChanged: controller.onNameChanged,
                          onPhoneChanged: controller.onPhoneChanged,
                          nameStatus: controller.nameStatus,
                          nameStatusText: controller.nameStatusText,
                          sizeMin: controller.sizeMin,
                          sizeMax: event.teamSizeMax,
                          size: controller.size,
                          onSizeChanged: controller.setSize,
                          rulesAccepted: controller.rulesAccepted,
                          onRulesChanged: controller.setRulesAccepted,
                          dataAccepted: controller.dataAccepted,
                          onDataChanged: controller.setDataAccepted,
                          photoConsent: controller.photoConsent,
                          onPhotoChanged: controller.setPhotoConsent,
                          onSubmit:
                              controller.canSubmit ? controller.submit : null,
                          sending: controller.sending,
                          locked: controller.registered,
                        ),
                        if (controller.registered)
                          InviteResultSection(
                            key: _resultKey,
                            code: controller.displayInviteCode,
                            size: controller.size,
                            initials: controller.teamInitials,
                            leftOut: controller.leftOutNames,
                            onShare: controller.shareInvite,
                            onCopy: controller.copyInvite,
                            onDone: controller.close,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
