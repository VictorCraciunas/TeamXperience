import 'package:flutter/material.dart';
import 'package:teamxperience/ui/theme/app_text_styles.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';

/// The line that stands in for the crews when they could not be loaded, with
/// a link to try again.
class TeamsLoadError extends StatelessWidget {
  const TeamsLoadError({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 28, 14, 6),
      child: Column(
        children: [
          Text(
            'Nu am putut încărca echipele.',
            textAlign: TextAlign.center,
            style: AppTextStyles.pageBody(
              context,
            ).copyWith(color: colors.muted),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onRetry,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              child: Text(
                'Încearcă din nou',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: colors.accent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
