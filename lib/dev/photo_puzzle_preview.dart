import 'package:flutter/material.dart';
import 'package:teamxperience/features/event_game/logic/photo_state.dart';
import 'package:teamxperience/features/event_game/widgets/image_upload/photo_puzzle_view.dart';

import 'puzzle_preview_frame.dart';
import 'sample_event.dart';

/// Mockup 07's photo puzzle ("Turnul Sfatului") waiting, approved and
/// rejected, in parchment or neon. No picture is loaded in the gallery.
class PhotoPuzzlePreview extends StatefulWidget {
  const PhotoPuzzlePreview({super.key});

  @override
  State<PhotoPuzzlePreview> createState() => _PhotoPuzzlePreviewState();
}

class _PhotoPuzzlePreviewState extends State<PhotoPuzzlePreview> {
  bool _neon = false;
  int _state = 0;

  static const _steps = [PhotoStep.waiting, PhotoStep.approved, PhotoStep.rejected];

  @override
  Widget build(BuildContext context) {
    final event = _neon ? neonSampleEvent() : sampleEvent();
    final now = DateTime(2026, 11, 14, 10, 31);
    return PuzzlePreviewFrame(
      event: event,
      mission: 2,
      clock: '0:31:47',
      body: PhotoPuzzleView(
        step: _steps[_state],
        reason: 'Nu se vede ceasul',
        sentAt: now.subtract(const Duration(minutes: 1)),
        now: now,
        onTakePhoto: () {},
        onContinue: () {},
        onChat: () {},
      ),
      switches: [
        (const ['Pergament', 'Neon'], _neon ? 1 : 0, (i) => setState(() => _neon = i == 1)),
        (const ['Așteaptă', 'Aprobată', 'Respinsă'], _state, (i) => setState(() => _state = i)),
      ],
    );
  }
}
