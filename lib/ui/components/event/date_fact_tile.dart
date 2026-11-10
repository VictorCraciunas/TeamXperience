import 'package:flutter/material.dart';

import '../../theme/app_radius.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/theme_context.dart';

/// The event date as a navy tile: the day big, the month and hour below.
class DateFactTile extends StatelessWidget {
  const DateFactTile({super.key, required this.day, required this.detail});

  final String day;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(color: colors.navy, borderRadius: BorderRadius.circular(AppRadius.button)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        // Centred in the row's height, like the other fact tiles.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(day, style: AppTextStyles.factValue(context).copyWith(color: colors.onNavy)),
            Text(
              detail,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, height: 1.45, color: colors.onNavy),
            ),
          ],
        ),
      ),
    );
  }
}
