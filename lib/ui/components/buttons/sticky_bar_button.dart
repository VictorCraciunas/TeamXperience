import 'package:flutter/material.dart';

import '../../theme/app_radius.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/theme_context.dart';

/// The navy action button of a [StickyActionBar]. Its label shortens with an
/// ellipsis when space runs out.
class StickyBarButton extends StatelessWidget {
  const StickyBarButton({super.key, required this.label, this.icon, this.onTap});

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final leading = icon;
    final radius = BorderRadius.circular(AppRadius.button);
    return Ink(
      decoration: BoxDecoration(color: colors.navy, borderRadius: radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[
                Icon(leading, size: 15, color: colors.onNavy),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.cardTitle(context).copyWith(color: colors.onNavy),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
