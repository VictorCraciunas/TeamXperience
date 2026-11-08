import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/features/event_game/logic/photo_state.dart';
import 'package:teamxperience/ui/components/game/game_filled_button.dart';
import 'package:teamxperience/ui/components/game/game_outline_button.dart';
import 'package:teamxperience/ui/components/game/photo_status_banner.dart';
import 'package:teamxperience/ui/theme/event_theme_scope.dart';

import '../frame_band.dart';
import 'photo_card.dart';

/// A photo puzzle as mockup 07, from plain values: the photo card with its
/// state, and the bar with "Chat" and the main photo action. The team waits
/// for the organiser's approval before going on.
class PhotoPuzzleView extends StatelessWidget {
  const PhotoPuzzleView({
    super.key,
    required this.step,
    this.picture,
    this.reason,
    this.sentAt,
    required this.now,
    required this.onTakePhoto,
    required this.onContinue,
    required this.onChat,
    this.onPicture = false,
    this.error,
  });

  /// Shown when the last photo did not go out.
  final String? error;

  final PhotoStep step;
  final ImageProvider? picture;
  final String? reason;
  final DateTime? sentAt;
  final DateTime now;
  final VoidCallback onTakePhoto;
  final VoidCallback onContinue;
  final VoidCallback onChat;

  /// Whether the puzzle is drawn on the organiser's picture.
  final bool onPicture;

  @override
  Widget build(BuildContext context) {
    final palette = context.eventPalette;
    final canRedo = step == PhotoStep.waiting || step == PhotoStep.rejected;

    final failed = error;
    final below = <Widget>[
      if (failed != null && step != PhotoStep.uploading) ...[
        const SizedBox(height: 8),
        PhotoStatusBanner(kind: PhotoBannerKind.rejected, text: failed),
      ],
      if (step == PhotoStep.waiting) ...[
        const SizedBox(height: 8),
        PhotoStatusBanner(kind: PhotoBannerKind.waiting, text: 'Organizatorul se uită la poză', trailing: sentAgo(sentAt, now)),
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 6, 2, 0),
          child: Text(
            'Poza a ajuns și în chat. Mergeți mai departe după ce e aprobată.',
            style: TextStyle(fontSize: 11, height: 1.45, color: palette.muted),
          ),
        ),
      ],
      if (step == PhotoStep.approved) ...[
        const SizedBox(height: 8),
        const PhotoStatusBanner(kind: PhotoBannerKind.approved, text: 'Aprobată. Bravo!'),
      ],
      if (step == PhotoStep.rejected) ...[
        const SizedBox(height: 8),
        PhotoStatusBanner(kind: PhotoBannerKind.rejected, text: rejectedLine(reason)),
      ],
    ];

    final (String label, IconData? icon, VoidCallback? action) = switch (step) {
      PhotoStep.none => ('Fă poza', TablerIcons.camera, onTakePhoto),
      PhotoStep.uploading => ('Se trimite…', null, null),
      PhotoStep.waiting || PhotoStep.rejected => ('Fă altă poză', TablerIcons.camera, onTakePhoto),
      PhotoStep.approved => ('Continuă', null, onContinue),
    };

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: PhotoCard(
              picture: picture,
              onTake: step == PhotoStep.none ? onTakePhoto : null,
              onRedo: canRedo ? onTakePhoto : null,
              below: below,
            ),
          ),
        ),
        FrameBand(
          onPicture: onPicture,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
            child: Row(
              children: [
                Expanded(flex: 10, child: GameOutlineButton(label: 'Chat', icon: TablerIcons.message_circle, onTap: onChat)),
                const SizedBox(width: 8),
                Expanded(flex: 14, child: GameFilledButton(label: label, icon: icon, onTap: action)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
