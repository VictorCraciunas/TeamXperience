import 'package:flutter/material.dart';
import 'package:teamxperience/features/play_tab/logic/play_tab_state.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/utils/event_formats.dart';

import 'play_card.dart';

/// The Joacă tab: what the player can do right now. Interim, until the
/// start-code flow of mockup 05.
class PlayTabView extends StatelessWidget {
  const PlayTabView({
    super.key,
    required this.state,
    required this.onContinue,
    required this.onEnterCode,
    required this.onOpenEvent,
    required this.onBrowse,
  });

  final PlayTabState state;
  final void Function(Event event, Team team) onContinue;
  final void Function(Event event) onEnterCode;
  final void Function(Event event) onOpenEvent;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final card = switch (state) {
      PlayLive(:final event, :final team) => PlayCard(
          title: event.name ?? '',
          line: 'Echipa ${team.name} e în joc',
          buttonLabel: 'Continuă jocul',
          onPressed: () => onContinue(event, team),
        ),
      PlayEnterCode(:final event, :final minutesLeft) => PlayCard(
          title: event.name ?? '',
          line: '$minutesLeft min să intri',
          buttonLabel: 'Introdu codul',
          onPressed: () => onEnterCode(event),
        ),
      PlayNext(:final event) => PlayCard(
          heading: 'Următorul tău joc',
          title: event.name ?? '',
          line: _dayLine(event),
          buttonLabel: 'Vezi evenimentul',
          onPressed: () => onOpenEvent(event),
        ),
      PlayNone() => PlayCard(
          line: 'Nu ai niciun joc programat.',
          buttonLabel: 'Vezi evenimentele',
          onPressed: onBrowse,
        ),
    };

    return ListView(padding: const EdgeInsets.all(14), children: [card]);
  }

  static String _dayLine(Event event) {
    final start = event.dateEvent;
    return start == null ? '' : eventDayLine(start, event.arriveMinutesBefore);
  }
}
