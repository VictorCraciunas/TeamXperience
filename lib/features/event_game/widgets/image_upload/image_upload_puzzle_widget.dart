import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/features/event_game/controller/image_upload_puzzle_controller.dart';
import 'package:teamxperience/features/event_game/widgets/image_upload/image_upload_action_button.dart';
import 'package:teamxperience/features/event_game/widgets/image_upload/image_upload_picker.dart';
import 'package:teamxperience/features/event_game/widgets/image_upload/image_upload_preview.dart';
import 'package:teamxperience/features/event_game/widgets/image_upload/image_upload_status_banner.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/state_management/user_provider.dart';
import 'package:teamxperience/widgets/my_button.dart';

class ImageUploadPuzzleWidget extends StatefulWidget {
  final String eventId;
  final String teamName;
  final int missionIndex;
  final int puzzleIndex;
  final VoidCallback onSolved;
  final bool isMissionCompleted;

  const ImageUploadPuzzleWidget({
    super.key,
    required this.eventId,
    required this.teamName,
    required this.missionIndex,
    required this.puzzleIndex,
    required this.onSolved,
    this.isMissionCompleted = false,
  });

  @override
  State<ImageUploadPuzzleWidget> createState() =>
      _ImageUploadPuzzleWidgetState();
}

class _ImageUploadPuzzleWidgetState extends State<ImageUploadPuzzleWidget> {
  late ImageUploadPuzzleController controller;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser!;
      controller = ImageUploadPuzzleController(
        eventId: widget.eventId,
        teamName: widget.teamName,
        missionIndex: widget.missionIndex,
        puzzleIndex: widget.puzzleIndex,
        user: user,
      );
      _initialized = true;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isMissionCompleted) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: MyButton(
            buttonText: 'Continuă',
            textColor: Colors.white,
            buttonOnTap: widget.onSolved,
            withBorder: false,
            gradient: MyColors.myGradient,
            buttonTextSize: 15,
          ),
        ),
      );
    }

    return StreamBuilder<Team>(
      stream: controller.teamStream,
      builder: (context, snapshot) {
        final status =
            snapshot.hasData ? controller.statusFor(snapshot.data!) : null;

        return AnimatedBuilder(
          animation: controller,
          builder: (context, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: controller.selectedImage == null
                      ? ImageUploadPicker(onTap: controller.pickAndUpload)
                      : ImageUploadPreview(file: controller.selectedImage!),
                ),
                const SizedBox(height: 16),
                ImageUploadStatusBanner(
                  status: status,
                  isUploading: controller.isUploading,
                ),
                const SizedBox(height: 12),
                ImageUploadActionButton(
                  status: status,
                  isUploading: controller.isUploading,
                  onContinue: widget.onSolved,
                  onReupload: controller.pickAndUpload,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
