import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

/// "Publică" in green or "Privată" in amber, on an organiser's row.
class NewsTypePill extends StatelessWidget {
  const NewsTypePill({super.key, required this.label, required this.isPrivate});

  final String label;
  final bool isPrivate;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isPrivate ? colors.warningSoft : colors.successSoft,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
        child: Text(
          label,
          maxLines: 1,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isPrivate ? colors.warning : colors.success,
          ),
        ),
      ),
    );
  }
}
