import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/ui.dart';

/// "Scoate echipa": a 44 px bin with a red edge.
class RemoveTeamButton extends StatelessWidget {
  const RemoveTeamButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.button),
      side: BorderSide(color: colors.danger.withValues(alpha: 0.35)),
    );
    return Tooltip(
      message: 'Scoate echipa',
      child: Material(
        color: colors.panel,
        shape: shape,
        child: InkWell(
          onTap: onTap,
          customBorder: shape,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(TablerIcons.trash, size: 18, color: colors.danger),
          ),
        ),
      ),
    );
  }
}
