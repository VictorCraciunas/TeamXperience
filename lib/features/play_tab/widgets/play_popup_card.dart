import 'package:flutter/material.dart';
import 'package:teamxperience/features/play_tab/controller/play_popup_controller.dart';
import 'package:teamxperience/features/play_tab/logic/play_tab_state.dart';

import 'empty_suggestion_card.dart';
import 'live_game_ticket.dart';
import 'next_game_ticket.dart';
import 'play_popup_actions.dart';
import 'start_code_ticket.dart';
import 'suggestion_card.dart';

/// The one card the Joacă pop-up shows for the controller's state.
class PlayPopupCard extends StatelessWidget {
  const PlayPopupCard({
    super.key,
    required this.controller,
    required this.actions,
    required this.stagger,
    required this.rolls,
    required this.onReroll,
  });

  final PlayPopupController controller;

  /// Already closing the pop-up before they navigate.
  final PlayPopupActions actions;
  final bool stagger;
  final int rolls;
  final VoidCallback onReroll;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final now = c.now;
    switch (c.state) {
      case PlayLive(:final event, :final team):
        final current = c.team ?? team;
        return LiveGameTicket(
          event: event,
          team: current,
          ranked: c.ranked,
          now: now,
          stagger: stagger,
          onContinue: () => actions.continueGame(event, current),
          onChat: () => actions.openChat(event, current),
        );
      case PlayEnterCode(:final event):
        return StartCodeTicket(
          event: event,
          team: c.team,
          now: now,
          stagger: stagger,
          onEnterCode: () => actions.enterCode(event),
        );
      case PlayNext(:final event):
        return NextGameTicket(
          event: event,
          team: c.team,
          now: now,
          stagger: stagger,
          onOpenEvent: () => actions.openEvent(event),
          onOpenTeam: () => actions.openTeam(event),
        );
      case PlayNone():
        final list = c.suggestions;
        if (list.isEmpty) return EmptySuggestionCard(stagger: stagger, onBrowseAll: actions.browseAll);
        final event = list[c.suggestionIndex.clamp(0, list.length - 1)];
        return SuggestionCard(
          event: event,
          rerolled: c.rerolled,
          teamCount: c.teamCount(event),
          canReroll: list.length > 1,
          rolls: rolls,
          stagger: stagger,
          onOpenEvent: () => actions.openEvent(event),
          onReroll: onReroll,
          onBrowseAll: actions.browseAll,
        );
    }
  }
}
