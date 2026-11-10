import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/theme/app_text_styles.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';

/// The ticket in its circle and the two lines under it, top of the join screen.
class JoinIntro extends StatelessWidget {
  const JoinIntro({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: colors.iconButtonBg,
            shape: BoxShape.circle,
          ),
          child: Icon(TablerIcons.ticket, size: 28, color: colors.accent),
        ),
        const SizedBox(height: 8),
        Text(
          'Ai primit un cod?',
          textAlign: TextAlign.center,
          style: AppTextStyles.pageBody(
            context,
          ).copyWith(fontSize: 17, fontWeight: FontWeight.w500),
        ),
        Text(
          'Îl găsești în mesajul de la căpitan.',
          textAlign: TextAlign.center,
          style: AppTextStyles.pageBody(context).copyWith(color: colors.muted),
        ),
      ],
    );
  }
}
