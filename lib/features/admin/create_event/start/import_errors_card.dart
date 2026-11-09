import 'package:flutter/material.dart';
import 'package:teamxperience/ui/theme/app_radius.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';

/// What was wrong with the pasted text, one line per mistake.
class ImportErrorsCard extends StatelessWidget {
  const ImportErrorsCard({super.key, required this.errors});

  final List<String> errors;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (errors.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.dangerSoft,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: colors.danger),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            errors.length == 1 ? 'Ceva nu e în regulă' : 'Sunt ${errors.length} probleme',
            style: TextStyle(color: colors.danger, fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          for (final error in errors)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(error, style: TextStyle(color: colors.text, fontSize: 14)),
            ),
        ],
      ),
    );
  }
}
