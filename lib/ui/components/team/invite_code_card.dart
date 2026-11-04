import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../theme/app_radius.dart';
import '../../theme/theme_context.dart';
import '../misc/dashed_border.dart';
import 'invite_code_button.dart';

/// The team's invite code, big and ready to share, on a navy card as in
/// mockup 04: a caption, the code in a dashed box, a WhatsApp button next to a
/// copy button, and an optional [footer] (the members who have joined). [code]
/// is shown as given ("VLP-482").
class InviteCodeCard extends StatelessWidget {
  const InviteCodeCard({
    super.key,
    required this.code,
    required this.shareLabel,
    required this.copyLabel,
    required this.onShare,
    required this.onCopy,
    this.caption,
    this.footer,
  });

  final String code;
  final String shareLabel;
  final String copyLabel;
  final VoidCallback onShare;
  final VoidCallback onCopy;
  final String? caption;

  /// Shown centred under the buttons.
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = caption;
    final bottom = footer;

    return DecoratedBox(
      key: const ValueKey('invite-code-card'),
      decoration: BoxDecoration(
        color: colors.navy,
        borderRadius: BorderRadius.circular(AppRadius.hero),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (text != null)
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: colors.onNavy.withValues(alpha: .8),
                  height: 1.45,
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: DashedBorder(
                color: colors.onNavyMuted,
                width: 1.5,
                radius: 12,
                child: Padding(
                  // 6 of CSS padding plus the 1.5 px border.
                  padding: const EdgeInsets.symmetric(vertical: 7.5, horizontal: 1.5),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      code,
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: 'Monospace',
                        fontSize: 26,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 4,
                        color: colors.onNavy,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: InviteCodeButton(
                    label: shareLabel,
                    icon: TablerIcons.brand_whatsapp,
                    highlighted: true,
                    onTap: onShare,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: InviteCodeButton(label: copyLabel, icon: TablerIcons.copy, onTap: onCopy),
                ),
              ],
            ),
            if (bottom != null)
              Padding(padding: const EdgeInsets.only(top: 10), child: Center(child: bottom)),
          ],
        ),
      ),
    );
  }
}
