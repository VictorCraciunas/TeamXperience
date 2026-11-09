import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../theme/theme_context.dart';

enum PhotoBannerKind { waiting, approved, rejected }

/// One state row of a photo puzzle (mockup 07 `.st`): the app's feedback
/// colours, a 16 px icon, the text in w500 and an optional trailing note
/// ("acum 1 min").
class PhotoStatusBanner extends StatelessWidget {
  const PhotoStatusBanner({super.key, required this.kind, required this.text, this.trailing});

  final PhotoBannerKind kind;
  final String text;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (fill, fg, icon) = switch (kind) {
      PhotoBannerKind.waiting => (colors.warningSoft, colors.warning, TablerIcons.clock),
      PhotoBannerKind.approved => (colors.successSoft, colors.success, TablerIcons.circle_check),
      PhotoBannerKind.rejected => (colors.dangerSoft, colors.danger, TablerIcons.circle_x),
    };
    final note = trailing;
    return DecoratedBox(
      key: const ValueKey('photo-status'),
      decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          children: [
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 8),
            Expanded(
              child: Text(text, style: TextStyle(fontSize: 14, height: 1.45, fontWeight: FontWeight.w500, color: fg)),
            ),
            if (note != null && note.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(note, style: TextStyle(fontSize: 13, height: 1.45, color: fg)),
            ],
          ],
        ),
      ),
    );
  }
}
