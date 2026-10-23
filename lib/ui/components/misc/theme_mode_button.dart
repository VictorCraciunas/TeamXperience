import 'package:flutter/material.dart';

import '../../theme/theme_context.dart';
import 'theme_mode_sheet.dart';

class ThemeModeButton extends StatelessWidget {
  const ThemeModeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      label: 'Alege aspectul aplicației',
      child: GestureDetector(
        onTap:
            () => showModalBottomSheet<void>(
              context: context,
              builder: (_) => const ThemeModeSheet(),
            ),
        child: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: colors.iconButtonBg,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.brightness_6_outlined,
            size: 22,
            color: colors.accent,
          ),
        ),
      ),
    );
  }
}
