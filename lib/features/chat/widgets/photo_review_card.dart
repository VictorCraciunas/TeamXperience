import 'package:flutter/material.dart';
import 'package:teamxperience/ui/theme/contrast.dart';
import 'package:teamxperience/ui/ui.dart';

import '../logic/chat_timeline.dart';
import 'chat_picture.dart';
import 'initials_avatar.dart';
import 'photo_status_pill.dart';

/// The organiser's card for a team's photo puzzle: who sent it and where
/// ("Mihai a trimis poza", "Misiunea 3 · Puzzle 2 · 10:52"), its state, the
/// picture, the reason under a rejected one and, while it waits, Respinge /
/// Aprobă.
class PhotoReviewCard extends StatelessWidget {
  const PhotoReviewCard({super.key, required this.entry, required this.onApprove, required this.onReject});

  final ChatPhotoReviewEntry entry;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final status = entry.status;
    final reason = entry.reason;
    final buttonText = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: AppTextStyles.body(context).fontFamily);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.panel,
        border: Border.all(color: colors.insetBorder),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              InitialsAvatar(initials: entry.initials),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colors.text)),
                    Text(entry.line, style: TextStyle(fontSize: 12, color: colors.muted)),
                  ],
                ),
              ),
              if (status != null) ...[const SizedBox(width: 8), Flexible(child: PhotoStatusPill(status: status))],
            ],
          ),
          const SizedBox(height: 10),
          ChatPicture(url: entry.imageUrl, height: 170),
          if (reason != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 8, 2, 0),
              child: Text(reason, style: TextStyle(fontSize: 14, height: 1.4, color: colors.danger)),
            ),
          if (entry.canDecide) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                      foregroundColor: colors.danger,
                      backgroundColor: colors.panel,
                      side: BorderSide(color: colors.danger, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
                      textStyle: buttonText,
                    ),
                    child: const Text('Respinge'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: onApprove,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                      backgroundColor: colors.success,
                      foregroundColor: readableOn([colors.success]),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
                      textStyle: buttonText,
                    ),
                    child: const Text('Aprobă'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
