import 'package:flutter/material.dart';

import '../../theme/app_radius.dart';
import '../../theme/theme_context.dart';

class MySnackBars {
  static void warningSnackBar(BuildContext context, {required String title, String message = ''}) {
    _show(context, Icons.warning, context.colors.warning, title, message);
  }

  static void errorSnackBar(BuildContext context, {required String title, String message = ''}) {
    _show(context, Icons.error, context.colors.danger, title, message);
  }

  static void successSnackBar(BuildContext context, {required String title, String message = ''}) {
    _show(context, Icons.check_circle, context.colors.success, title, message);
  }

  static void infoSnackBar(BuildContext context, {required String title, String message = ''}) {
    _show(context, Icons.info, context.colors.accent, title, message);
  }

  static void _show(
    BuildContext context,
    IconData icon,
    Color background,
    String title,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  if (message.isNotEmpty)
                    Text(message, style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: background,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(20),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
      ),
    );
  }
}
