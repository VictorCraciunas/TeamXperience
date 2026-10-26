import 'package:flutter/material.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/controller/add_missions_controller.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/screen/mission_page.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/mission_list/mission_card.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/ui/components/buttons/app_button.dart';
import 'package:teamxperience/ui/components/feedback/app_dialog.dart';
import 'package:teamxperience/ui/components/navigation/my_appbar.dart';
import 'package:teamxperience/ui/ui.dart';

class AddMissionsPage extends StatefulWidget {
  const AddMissionsPage({super.key});

  @override
  State<AddMissionsPage> createState() => _AddMissionsPageState();
}

class _AddMissionsPageState extends State<AddMissionsPage> {
  late AddMissionsController _controller;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final Event event = args?['event'];
    _controller = AddMissionsController(
      event,
      args?['mode'] ?? 'create',
      isDraft: args?['isDraft'] ?? false,
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
    _initialized = true;
  }

  bool get _isPublished => _controller.mode == 'edit' && !_controller.isDraft;

  String get _primaryLabel {
    if (_controller.isDraft) return 'Publică evenimentul';
    if (_controller.mode == 'edit') return 'Actualizează eveniment';
    return 'Creează eveniment';
  }

  Future<void> _openMission(int index) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MissionPage(controller: _controller, index: index),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _confirmDelete(int index) async {
    final ok = await showAppDialog(
      context,
      title: 'Ștergi misiunea ${index + 1}?',
      message: 'Se șterg și puzzle-urile ei.',
      confirmLabel: 'Șterge',
      cancelLabel: 'Anulează',
      destructive: true,
    );
    if (ok) _controller.removeMission(index);
  }

  void _goHome() {
    Navigator.pushNamedAndRemoveUntil(context, Routes.adminHome, (_) => false);
  }

  Future<void> _save() async {
    if (await _controller.saveEvent(context) && mounted) _goHome();
  }

  Future<void> _saveDraft() async {
    if (await _controller.saveDraft(context) && mounted) _goHome();
  }

  @override
  Widget build(BuildContext context) {
    final missions = _controller.event.missions;

    return Scaffold(
      backgroundColor: context.colors.page,
      appBar: const MyAppBar(appBarText: 'Misiuni'),
      body: SafeArea(
        // Hold a mission and drag it to change the order.
        child: ReorderableListView.builder(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            8,
            AppSpacing.page,
            30,
          ),
          itemCount: missions.length,
          onReorderItem: _controller.moveMission,
          itemBuilder:
              (context, i) => Padding(
                key: ObjectKey(missions[i]),
                padding: const EdgeInsets.only(bottom: 10),
                child: MissionCard(
                  index: i,
                  puzzleCount: missions[i].puzzles.length,
                  status: _controller.statusText(i),
                  done: _controller.isDone(i),
                  onTap: () => _openMission(i),
                  onDelete: () => _confirmDelete(i),
                ),
              ),
          footer: Column(
            children: [
              AppButton(
                label: 'Adaugă misiune',
                variant: AppButtonVariant.secondary,
                foregroundColor: context.colors.text,
                onPressed: _controller.addNewMission,
              ),
              const SizedBox(height: 24),
              AppButton(label: _primaryLabel, onPressed: _save),
              if (!_isPublished) ...[
                const SizedBox(height: 10),
                AppButton(
                  label: 'Salvează ca ciornă',
                  variant: AppButtonVariant.secondary,
                  foregroundColor: context.colors.text,
                  onPressed: _saveDraft,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
