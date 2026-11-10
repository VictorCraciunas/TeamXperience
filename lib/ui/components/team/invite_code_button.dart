import 'package:flutter/material.dart';

import '../../theme/app_text_styles.dart';
import '../../theme/theme_context.dart';

/// One of the two buttons of an [InviteCodeCard], made for a navy card:
/// [highlighted] is the teal one (WhatsApp), the other a faint white (copy).
class InviteCodeButton extends StatelessWidget {
  const InviteCodeButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.highlighted = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final foreground = highlighted ? colors.onTick : colors.onNavy;
    return Material(
      color: highlighted ? colors.tickOnNavy : colors.onNavy.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: foreground),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.cardTitle(context).copyWith(color: foreground),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
