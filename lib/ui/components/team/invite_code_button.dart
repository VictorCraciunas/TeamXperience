import 'package:flutter/material.dart';

import '../../theme/app_radius.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/theme_context.dart';

/// One of the two buttons of an [InviteCodeCard]: navy when [filled], an
/// outlined panel button otherwise.
class InviteCodeButton extends StatelessWidget {
  const InviteCodeButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final foreground = filled ? colors.onNavy : colors.text;
    final radius = BorderRadius.circular(AppRadius.button);
    return Ink(
      decoration: BoxDecoration(
        color: filled ? colors.navy : colors.panel,
        borderRadius: radius,
        border: Border.all(color: filled ? colors.navy : colors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
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
