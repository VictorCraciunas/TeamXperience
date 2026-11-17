import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

/// The line shown where the list would be when no news matches.
class NewsEmpty extends StatelessWidget {
  const NewsEmpty({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.page, 80, AppSpacing.page, 24),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: context.colors.muted, fontSize: 16),
      ),
    );
  }
}
