import 'package:flutter/material.dart';

import '../../theme/app_radius.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/theme_context.dart';

/// The quiet action of a [StickyActionBar]: accent text with a 48 px tall
/// tap area.
class StickyBarLink extends StatelessWidget {
  const StickyBarLink({super.key, required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.button),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        // Both factors: without heightFactor the link grows as tall as the
        // page, and as a bottom bar it covers the whole screen.
        child: Center(
          widthFactor: 1,
          heightFactor: 1,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.cardTitle(context).copyWith(color: context.colors.accent),
          ),
        ),
      ),
    );
  }
}
