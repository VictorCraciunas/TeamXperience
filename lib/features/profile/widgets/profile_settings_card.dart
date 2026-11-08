import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/components/layout/outline_card.dart';
import 'package:teamxperience/ui/ui.dart';

/// The settings at the bottom of Profil (mockup 08): theme, notifications and
/// sign-out, one row each with a line between.
class ProfileSettingsCard extends StatelessWidget {
  const ProfileSettingsCard({
    super.key,
    required this.themeLabel,
    required this.notificationsLabel,
    required this.onTheme,
    required this.onNotifications,
    required this.onLogout,
  });

  final String themeLabel;
  final String notificationsLabel;
  final VoidCallback onTheme;
  final VoidCallback onNotifications;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = TextStyle(fontSize: 12, height: 1.45, color: colors.text);

    Widget row(IconData icon, String label, VoidCallback onTap, {String? value, bool chevron = false, Color? tint}) {
      final note = value;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            children: [
              Icon(icon, size: 16, color: tint ?? colors.accent),
              const SizedBox(width: 10),
              Expanded(child: Text(label, style: style.copyWith(color: tint ?? colors.text))),
              if (note != null) Text(note, style: style.copyWith(color: colors.muted)),
              if (chevron) ...[
                const SizedBox(width: 4),
                Icon(TablerIcons.chevron_right, size: 15, color: colors.muted),
              ],
            ],
          ),
        ),
      );
    }

    Widget line() => Divider(height: 1, thickness: 1, color: colors.insetBorder);

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: OutlineCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            row(TablerIcons.sun_moon, 'Temă', onTheme, value: themeLabel),
            line(),
            row(TablerIcons.bell, 'Notificări', onNotifications, value: notificationsLabel, chevron: true),
            line(),
            row(TablerIcons.logout, 'Deconectare', onLogout, tint: colors.danger),
          ],
        ),
      ),
    );
  }
}
