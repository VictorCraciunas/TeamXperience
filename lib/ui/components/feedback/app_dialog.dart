import 'package:flutter/material.dart';

import '../../theme/theme_context.dart';

/// A confirmation dialog on the theme tokens. Returns true when confirmed and
/// false when cancelled or dismissed. A [destructive] confirm uses the danger
/// colour.
Future<bool> showAppDialog(
  BuildContext context, {
  required String title,
  String? message,
  required String confirmLabel,
  String? cancelLabel,
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final colors = dialogContext.colors;
      final body = message;
      final cancel = cancelLabel;

      return AlertDialog(
        title: Text(title, style: TextStyle(color: colors.text, fontSize: 19, fontWeight: FontWeight.w600)),
        content: body == null ? null : Text(body, style: TextStyle(color: colors.muted, fontSize: 16)),
        actions: [
          if (cancel != null)
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(cancel, style: TextStyle(color: colors.muted)),
            ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              confirmLabel,
              style: TextStyle(
                color: destructive ? colors.danger : colors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
