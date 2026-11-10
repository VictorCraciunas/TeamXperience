import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/features/game_intro/logic/intro_texts.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/ui/theme/event_theme_scope.dart';

import 'intro_fact_chip.dart';
import 'intro_letter_card.dart';

/// The intro letter of mockup 05, in the event's look: a seal, the place
/// and day, the name, the organiser's letter, the facts of the game, and
/// "Spre prima misiune".
class GameIntroView extends StatelessWidget {
  const GameIntroView({super.key, required this.event, required this.onStart});

  final Event event;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final palette = context.eventPalette;
    final date = introDateLine(event);
    final letter = event.introLetter?.trim() ?? '';

    return ColoredBox(
      key: const ValueKey('intro-page'),
      color: palette.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 30, 18, 0),
                      child: Column(
                        children: [
                          // The mockup's 70 px seal with its 3 px gold border outside it.
                          Container(
                            key: const ValueKey('intro-seal'),
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              color: palette.accent,
                              shape: BoxShape.circle,
                              border: Border.all(color: palette.secondaryAccent, width: 3),
                            ),
                            child: Icon(TablerIcons.compass, size: 34, color: palette.background),
                          ),
                          if (date.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              date,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.45,
                                letterSpacing: 1,
                                color: palette.ink.withValues(alpha: .75),
                              ),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            event.name ?? '',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontFamily: palette.voiceFont, fontSize: 24, height: 1.25, color: palette.ink),
                          ),
                        ],
                      ),
                    ),
                    if (letter.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: IntroLetterCard(letter: letter, signature: event.introSignature),
                      ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final (icon, label) in introFacts(event)) IntroFactChip(icon: icon, label: label),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    color: palette.accent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: onStart,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(11),
                        child: Text(
                          'Spre prima misiune',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.45, color: palette.surface),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cronometrul pornește acum pentru toată echipa.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, height: 1.45, color: palette.ink.withValues(alpha: .75)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
