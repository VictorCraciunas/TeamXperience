import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

import 'how_it_works_step.dart';

/// The three steps of the game, opened from "Cum funcționează".
Future<void> showHowItWorksSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: context.colors.page,
    builder: (_) => const HowItWorksSheet(),
  );
}

class HowItWorksSheet extends StatelessWidget {
  const HowItWorksSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Cum se joacă',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.45, color: context.colors.text),
            ),
            const SizedBox(height: 14),
            const HowItWorksStep(number: 1, title: 'Înscrie-ți echipa', line: 'Din pagina jocului'),
            const SizedBox(height: 12),
            const HowItWorksStep(number: 2, title: 'Primești codul de start', line: 'În ziua jocului, de la organizator'),
            const SizedBox(height: 12),
            const HowItWorksStep(number: 3, title: 'Rezolvați misiunile prin oraș', line: 'Coduri, locuri și fotografii'),
          ],
        ),
      ),
    );
  }
}
