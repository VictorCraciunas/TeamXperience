import 'package:flutter/material.dart';
import 'package:teamxperience/model/crew.dart';
import 'package:teamxperience/ui/components/misc/app_chip.dart';
import 'package:teamxperience/ui/components/misc/app_chip_style.dart';

import 'field_label.dart';

/// For a captain who already has a team: sign it up again, or make a new one.
class CrewChoice extends StatelessWidget {
  const CrewChoice({super.key, required this.crews, required this.chosen, required this.onChoose});

  final List<Crew> crews;

  /// Null for a new team.
  final Crew? chosen;
  final ValueChanged<Crew?> onChoose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const FieldLabel('Cu ce echipă te înscrii?'),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final crew in crews)
                AppChip(
                  label: crew.name,
                  style: crew.id == chosen?.id ? AppChipStyle.selected : AppChipStyle.plain,
                  onTap: () => onChoose(crew),
                ),
              AppChip(
                label: 'Echipă nouă',
                style: chosen == null ? AppChipStyle.selected : AppChipStyle.plain,
                onTap: () => onChoose(null),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
