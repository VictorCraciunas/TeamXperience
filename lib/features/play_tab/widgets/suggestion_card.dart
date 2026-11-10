import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/features/play_tab/logic/play_popup_texts.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/ui/components/event/event_picture.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:teamxperience/utils/event_formats.dart';

import 'card_handle.dart';
import 'game_pill.dart';
import 'popup_button.dart';
import 'spinning_dice.dart';
import 'stagger_in.dart';
import 'suggestion_shell.dart';

/// Not registered: one event to try, "Recomandat pentru tine" first and
/// "La întâmplare" after "Alt joc" (mockup 10).
class SuggestionCard extends StatelessWidget {
  const SuggestionCard({
    super.key,
    required this.event,
    required this.rerolled,
    required this.teamCount,
    required this.canReroll,
    required this.rolls,
    required this.stagger,
    required this.onOpenEvent,
    required this.onReroll,
    required this.onBrowseAll,
  });

  final Event event;
  final bool rerolled;
  final int? teamCount;
  final bool canReroll;

  /// How many times "Alt joc" was tapped, for the dice's turns.
  final int rolls;
  final bool stagger;
  final VoidCallback onOpenEvent;
  final VoidCallback onReroll;
  final VoidCallback onBrowseAll;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final start = event.dateEvent;
    final city = (event.area ?? event.location ?? '').trim();
    final minutes = event.effectiveDurationMinutes;
    final difficulty = event.effectiveDifficulty;
    final count = teamCount;
    final meta = [
      if (city.isNotEmpty) city,
      if (minutes != null) formatDuration(minutes),
      if (difficulty != null) difficultyLabel(difficulty),
      if (count != null) '$count echipe',
    ];
    var i = 0;
    Widget row(Widget child) => StaggerIn(index: i++, play: stagger, child: child);

    return SuggestionShell(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHandle(color: colors.border),
              row(Text(
                'Nu ești înscris la niciun joc',
                style: TextStyle(fontSize: 15, height: 1.45, fontWeight: FontWeight.w600, color: colors.text),
              )),
              row(Text('Ce zici de acesta?', style: TextStyle(fontSize: 13, height: 1.45, color: colors.muted))),
            ],
          ),
        ),
        row(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: EventPicture(
              url: event.landingImageUrl,
              height: 150,
              topLeft: GamePill(
                icon: rerolled ? TablerIcons.dice_5 : TablerIcons.sparkles,
                label: rerolled ? 'La întâmplare' : 'Recomandat pentru tine',
                fill: colors.heroButton,
                text: colors.text,
              ),
            ),
          ),
        )),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              row(Text(event.name ?? '', style: TextStyle(fontSize: 21, height: 1.25, fontWeight: FontWeight.w600, color: colors.text))),
              if (start != null) row(Text(suggestionWhen(start), style: TextStyle(fontSize: 14, height: 1.45, color: colors.muted))),
              if (meta.isNotEmpty)
                row(Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final m in meta)
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.inset,
                            border: Border.all(color: colors.insetBorder),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            child: Text(m, style: TextStyle(fontSize: 12, height: 1.45, color: colors.text)),
                          ),
                        ),
                    ],
                  ),
                )),
              row(Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Row(
                  children: [
                    Expanded(child: PopupButton(label: 'Vezi evenimentul', onPressed: onOpenEvent)),
                    if (canReroll) ...[
                      const SizedBox(width: 8),
                      PopupButton(
                        label: 'Alt joc',
                        kind: PopupButtonKind.outline,
                        icon: SpinningDice(turns: rolls),
                        onPressed: onReroll,
                      ),
                    ],
                  ],
                ),
              )),
              row(PopupButton(label: 'Toate evenimentele', kind: PopupButtonKind.link, onPressed: onBrowseAll)),
            ],
          ),
        ),
      ],
    );
  }
}
