import 'package:flutter/material.dart';
import 'package:teamxperience/features/event_details/logic/event_page_data.dart';
import 'package:teamxperience/features/event_details/widgets/event_page_view.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/ui/components/misc/segmented_switch.dart';
import 'package:teamxperience/ui/ui.dart';

import 'sample_event.dart';

/// The event page with the mockup's event, to hold next to
/// docs/roadmap/mockups/01-event-details.html. The switch shows the bar for a
/// visitor, a registered team, and a team in the first hour of the game.
class EventPagePreview extends StatefulWidget {
  const EventPagePreview({super.key});

  @override
  State<EventPagePreview> createState() => _EventPagePreviewState();
}

class _EventPagePreviewState extends State<EventPagePreview> {
  int _state = 0;

  static final _team = Team(
    name: 'Vulpile',
    teamMembers: '',
    captainName: 'Victor',
    phoneNumber: '',
    captainEmail: '',
    numberOfMembers: 4,
  );

  void _say(String what) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(what)));
  }

  @override
  Widget build(BuildContext context) {
    final registered = _state > 0;
    final now = _state == 2 ? DateTime(2026, 11, 14, 10, 18) : DateTime(2026, 11, 9, 12);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagina evenimentului'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, AppSpacing.sm),
            child: SegmentedSwitch(
              labels: const ['Vizitator', 'Înscriși', 'Start'],
              selectedIndex: _state,
              onSelected: (i) => setState(() => _state = i),
            ),
          ),
        ),
      ),
      body: EventPageView(
        event: sampleEvent(),
        data: EventPageData(team: registered ? _team : null, teamsCount: 12, organiserEventsCount: 14),
        now: now,
        onBack: () => Navigator.maybePop(context),
        onShare: () => _say('share'),
        onOpenMap: () => _say('map'),
        onMessageOrganiser: registered ? () => _say('chat') : null,
        onSignupAction: (action) => _say(action.name),
      ),
    );
  }
}
