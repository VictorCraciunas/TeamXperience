import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/features/event_game/controller/image_upload_puzzle_controller.dart';
import 'package:teamxperience/features/event_game/logic/photo_state.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/state_management/user_provider.dart';
import 'package:teamxperience/ui/theme/event_theme_scope.dart';

import 'photo_puzzle_view.dart';

/// A photo puzzle: sends the team's photo to the organiser (through the chat)
/// and follows the team doc until it is approved. Draws [PhotoPuzzleView].
class ImageUploadPuzzleWidget extends StatefulWidget {
  const ImageUploadPuzzleWidget({
    super.key,
    required this.eventId,
    required this.teamName,
    required this.missionIndex,
    required this.puzzleIndex,
    required this.onSolved,
    required this.onChat,
    this.isMissionCompleted = false,
    this.onPicture = false,
  });

  final String eventId;
  final String teamName;
  final int missionIndex;
  final int puzzleIndex;
  final VoidCallback onSolved;
  final VoidCallback onChat;
  final bool isMissionCompleted;
  final bool onPicture;

  @override
  State<ImageUploadPuzzleWidget> createState() => _ImageUploadPuzzleWidgetState();
}

class _ImageUploadPuzzleWidgetState extends State<ImageUploadPuzzleWidget> {
  ImageUploadPuzzleController? _controller;
  Timer? _tick;
  DateTime _now = DateTime.now();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) return;
    final user = context.read<UserProvider>().currentUser;
    if (user == null) return;
    _controller = ImageUploadPuzzleController(
      eventId: widget.eventId,
      teamName: widget.teamName,
      missionIndex: widget.missionIndex,
      puzzleIndex: widget.puzzleIndex,
      user: user,
    );
    // "acum 3 min" moves on by itself.
    _tick = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) return const SizedBox.shrink();
    return StreamBuilder<Team>(
      stream: controller.teamStream,
      builder: (context, snapshot) {
        final team = snapshot.data;
        if (team == null) {
          return Center(child: CircularProgressIndicator(color: context.eventPalette.accent));
        }
        return ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final state = photoState(team, widget.missionIndex, widget.puzzleIndex, uploading: controller.isUploading);
            final step = widget.isMissionCompleted ? PhotoStep.approved : state.step;
            final file = controller.selectedImage;
            final url = state.detail?.url;
            final ImageProvider? picture = step == PhotoStep.uploading && file != null
                ? FileImage(file)
                : (url != null ? NetworkImage(url) : (file != null ? FileImage(file) : null));
            return PhotoPuzzleView(
              step: step,
              picture: picture,
              reason: state.detail?.reason,
              sentAt: state.detail?.at,
              now: _now,
              onTakePhoto: controller.pickAndUpload,
              error: controller.error,
              onContinue: widget.onSolved,
              onChat: widget.onChat,
              onPicture: widget.onPicture,
            );
          },
        );
      },
    );
  }
}
