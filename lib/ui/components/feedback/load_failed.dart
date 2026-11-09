import 'package:flutter/material.dart';

import '../../theme/app_text_styles.dart';
import '../../theme/theme_context.dart';

/// Stands in for a list that could not be loaded, so a failure never reads as
/// "there is nothing here". [onRetry] adds a link to try again.
class LoadFailed extends StatelessWidget {
  const LoadFailed({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final retry = onRetry;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 28, 14, 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.pageBody(context).copyWith(color: colors.muted),
          ),
          if (retry != null) ...[
            const SizedBox(height: 8),
            Center(
              child: Semantics(
                button: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: retry,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    child: Text(
                      'Încearcă din nou',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colors.accent),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
