import 'package:flutter/material.dart';
import 'package:teamxperience/model/crew.dart';
import 'package:teamxperience/ui/components/misc/app_chip.dart';
import 'package:teamxperience/ui/components/misc/app_chip_style.dart';

import 'edit_toggle.dart';
import 'field_label.dart';

/// For a captain who already has a team: sign it up again, or make a new one.
/// With a team chosen, [EditToggle] opens its filled-in details for changes.
class CrewChoice extends StatelessWidget {
  const CrewChoice({
    super.key,
    required this.crews,
    required this.chosen,
    required this.onChoose,
    required this.editing,
    required this.onToggleEdit,
  });

  final List<Crew> crews;

  /// Null for a new team.
  final Crew? chosen;
  final ValueChanged<Crew?> onChoose;

  /// Whether the chosen team's details are open for changes.
  final bool editing;

  /// Null while the form cannot change (sending).
  final VoidCallback? onToggleEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(child: FieldLabel('Cu ce echipă te înscrii?')),
              if (chosen != null) EditToggle(editing: editing, onTap: onToggleEdit),
            ],
          ),
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
