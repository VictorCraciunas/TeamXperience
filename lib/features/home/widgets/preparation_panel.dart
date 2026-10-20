import 'package:flutter/material.dart';
import 'package:teamxperience/features/home/logic/preparation_steps.dart';
import 'package:teamxperience/ui/components/event/checklist_row.dart';
import 'package:teamxperience/ui/components/layout/section_card.dart';

class PreparationPanel extends StatelessWidget {
  const PreparationPanel({super.key, required this.steps});

  final List<PreparationStep> steps;

  @override
  Widget build(BuildContext context) {
    final done = steps.where((s) => s.done).length;

    return SectionCard(
      title: 'Pregătirea echipei',
      countLabel: '$done din ${steps.length}',
      child: Column(
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            if (i > 0) const SizedBox(height: 6),
            ChecklistRow(
              title: steps[i].title,
              subtitle: steps[i].subtitle,
              done: steps[i].done,
            ),
          ],
        ],
      ),
    );
  }
}
