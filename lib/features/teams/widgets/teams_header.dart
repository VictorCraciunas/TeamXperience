import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/components/misc/app_chip.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';

/// The top of the Echipe screen, as in mockup 03: the title and, at the
/// right, the chip that starts a new team. It keeps clear of the status bar.
class TeamsHeader extends StatelessWidget {
  const TeamsHeader({super.key, required this.onNewCrew});

  final VoidCallback onNewCrew;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.panel,
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Echipe',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                    color: colors.text,
                  ),
                ),
              ),
              AppChip(
                label: 'Echipă nouă',
                icon: TablerIcons.plus,
                onTap: onNewCrew,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
