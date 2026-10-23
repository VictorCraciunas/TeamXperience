import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/theme_context.dart';
import '../../theme/theme_controller.dart';

/// The three appearance choices (system, light, dark) bound to [ThemeController].
class ThemeModeOptions extends StatelessWidget {
  const ThemeModeOptions({super.key, this.onSelected});

  /// Called after a choice has been applied (the sheet uses it to close itself).
  final VoidCallback? onSelected;

  static const _options = [
    (ThemeMode.system, 'Sistem', Icons.brightness_auto_outlined),
    (ThemeMode.light, 'Luminos', Icons.light_mode_outlined),
    (ThemeMode.dark, 'Întunecat', Icons.dark_mode_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final controller = context.watch<ThemeController>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (mode, label, icon) in _options)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(icon, color: colors.accent),
            title: Text(label, style: TextStyle(color: colors.text)),
            trailing:
                controller.mode == mode
                    ? Icon(
                      Icons.check,
                      key: ValueKey('theme-option-selected-${mode.name}'),
                      color: colors.accent,
                    )
                    : null,
            onTap: () {
              controller.setMode(mode);
              onSelected?.call();
            },
          ),
      ],
    );
  }
}
