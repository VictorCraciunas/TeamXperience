import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/theme_context.dart';
import '../../theme/theme_controller.dart';

class ThemeModeSheet extends StatelessWidget {
  const ThemeModeSheet({super.key});

  static const _options = [
    (ThemeMode.system, 'Sistem', Icons.brightness_auto_outlined),
    (ThemeMode.light, 'Luminos', Icons.light_mode_outlined),
    (ThemeMode.dark, 'Întunecat', Icons.dark_mode_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final controller = context.watch<ThemeController>();

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
                color: colors.text,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            for (final (mode, label, icon) in _options)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(icon, color: colors.accent),
                title: Text(label, style: TextStyle(color: colors.text)),
                trailing: controller.mode == mode
                    ? Icon(
                        Icons.check,
                        key: ValueKey('theme-option-selected-${mode.name}'),
                        color: colors.accent,
                      )
                    : null,
                onTap: () {
                  controller.setMode(mode);
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}
