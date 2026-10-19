import 'package:flutter/material.dart';

import '../../theme/theme_context.dart';
import 'theme_mode_options.dart';

class ThemeModeSheet extends StatelessWidget {
  const ThemeModeSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aspect',
              style: TextStyle(
                color: context.colors.text,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ThemeModeOptions(onSelected: () => Navigator.of(context).pop()),
          ],
        ),
      ),
    );
  }
}
