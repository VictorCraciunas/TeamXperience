import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/buttons/app_button.dart';
import 'package:teamxperience/ui/components/layout/section_card.dart';
import 'package:teamxperience/ui/components/misc/theme_mode_options.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({
    super.key,
    required this.name,
    required this.email,
    required this.onLogout,
  });

  final String name;
  final String email;
  final VoidCallback onLogout;

  String get _initials {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    final letters = words.take(2).map((w) => w.substring(0, 1).toUpperCase());
    return letters.join();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionCard(
            title: 'Contul tău',
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: colors.iconButtonBg,
                  child: Text(
                    _initials,
                    style: TextStyle(
                      color: colors.accent,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colors.muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const SectionCard(title: 'Aspect', child: ThemeModeOptions()),
          const SizedBox(height: 16),
          AppButton(
            label: 'Deconectare',
            variant: AppButtonVariant.secondary,
            leading: const Icon(Icons.logout_rounded),
            onPressed: onLogout,
          ),
        ],
      ),
    );
  }
}
