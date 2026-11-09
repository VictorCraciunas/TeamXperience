import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/components/misc/dashed_border.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';

/// The invite code on a crew card: "Cod invitație", the code in mono and, at
/// the right, the share and copy icons, in a dashed box on the navy.
class CrewCodeRow extends StatelessWidget {
  const CrewCodeRow({
    super.key,
    required this.code,
    required this.onShare,
    required this.onCopy,
  });

  /// As shown, "VLP-482".
  final String code;
  final VoidCallback onShare;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final faded = colors.onNavy.withValues(alpha: .8);

    return DashedBorder(
      color: colors.onNavy.withValues(alpha: .35),
      fill: colors.onNavy.withValues(alpha: .08),
      width: 1,
      radius: 12,
      child: Padding(
        // 7 / 10 of CSS padding plus the 1 px border. The icons carry 6 px of
        // tap area each side, taken off the right and the top and bottom.
        padding: const EdgeInsets.fromLTRB(11, 4, 5, 4),
        child: Row(
          children: [
            Flexible(
              flex: 2,
              child: Text(
                'Cod invitație',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, height: 1.45, color: faded),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    code,
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: 'Monospace',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2,
                      height: 1.45,
                      color: colors.onNavy,
                    ),
                  ),
                ),
              ),
            ),
            _CodeIcon(
              icon: TablerIcons.share,
              label: 'Distribuie codul',
              onTap: onShare,
            ),
            _CodeIcon(
              icon: TablerIcons.copy,
              label: 'Copiază codul',
              onTap: onCopy,
            ),
          ],
        ),
      ),
    );
  }
}

class _CodeIcon extends StatelessWidget {
  const _CodeIcon({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox.square(
          dimension: 44,
          child: Icon(icon, size: 18, color: context.colors.onNavy),
        ),
      ),
    );
  }
}
