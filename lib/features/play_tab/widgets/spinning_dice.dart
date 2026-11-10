import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

/// The dice of "Alt joc": a full turn each time [turns] goes up.
class SpinningDice extends StatelessWidget {
  const SpinningDice({super.key, required this.turns});

  final int turns;

  @override
  Widget build(BuildContext context) => AnimatedRotation(
        turns: turns.toDouble(),
        duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 500),
        curve: const Cubic(.3, 1.5, .5, 1),
        child: const Icon(TablerIcons.dice_5),
      );
}
