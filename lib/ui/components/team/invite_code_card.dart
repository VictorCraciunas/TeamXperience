import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../theme/app_radius.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/theme_context.dart';
import 'invite_code_button.dart';

/// The team's invite code, big and ready to share: a caption, the code, and a
/// WhatsApp button next to a copy button. [code] is shown as given
/// ("VLP-482").
class InviteCodeCard extends StatelessWidget {
  const InviteCodeCard({
    super.key,
    required this.code,
    required this.shareLabel,
    required this.copyLabel,
    required this.onShare,
    required this.onCopy,
    this.caption,
  });

  final String code;
  final String shareLabel;
  final String copyLabel;
  final VoidCallback onShare;
  final VoidCallback onCopy;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = caption;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.panel,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(AppRadius.hero),
      ),
      child: Padding(
        // 14 of CSS padding plus the 1 px border.
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (text != null)
              Text(text, textAlign: TextAlign.center, style: AppTextStyles.smallMuted(context)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.inset,
                  border: Border.all(color: colors.insetBorder, width: 1.5),
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7.5),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      code,
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: 'Monospace',
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 4,
                        color: colors.text,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: InviteCodeButton(
                    label: shareLabel,
                    icon: TablerIcons.brand_whatsapp,
                    filled: true,
                    onTap: onShare,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: InviteCodeButton(label: copyLabel, icon: TablerIcons.copy, onTap: onCopy),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
