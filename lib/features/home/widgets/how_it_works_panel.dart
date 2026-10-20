import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/layout/section_card.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';

/// Three-step explainer shown to players who have nothing registered yet.
class HowItWorksPanel extends StatelessWidget {
  const HowItWorksPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionCard(
      title: 'Cum funcționează',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _Step(
              icon: Icons.group_add_outlined,
              title: 'Înscrie',
              text: 'Alege un eveniment și înscrie-ți echipa',
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: _Step(
              icon: Icons.key_outlined,
              title: 'Primești',
              text: 'Codul de start în ziua evenimentului',
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: _Step(
              icon: Icons.extension_outlined,
              title: 'Rezolvă',
              text: 'Misiuni și ghicitori prin oraș',
            ),
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.icon, required this.title, required this.text});

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors.inset,
            shape: BoxShape.circle,
            border: Border.all(color: colors.insetBorder),
          ),
          child: Icon(icon, size: 20, color: colors.accent),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(
            color: colors.text,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.muted, fontSize: 10.5),
        ),
      ],
    );
  }
}
