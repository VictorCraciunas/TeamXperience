import 'package:flutter/material.dart';

import '../../theme/theme_context.dart';
import '../buttons/app_button.dart';

/// Shows a spinner while loading, an error with a retry button, an empty
/// message, or [child], in that order of priority.
class AsyncState extends StatelessWidget {
  const AsyncState({
    super.key,
    required this.isLoading,
    required this.isEmpty,
    required this.child,
    this.error,
    this.onRetry,
    this.emptyMessage = 'Nu există nimic de afișat.',
  });

  final bool isLoading;
  final Object? error;
  final bool isEmpty;
  final Widget child;
  final VoidCallback? onRetry;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: colors.danger, size: 32),
              const SizedBox(height: 8),
              Text(
                'Ceva nu a mers bine.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.text, fontSize: 14),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 12),
                AppButton(label: 'Reîncearcă', onPressed: onRetry, expand: false),
              ],
            ],
          ),
        ),
      );
    }

    if (isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            emptyMessage,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.muted, fontSize: 13),
          ),
        ),
      );
    }

    return child;
  }
}
