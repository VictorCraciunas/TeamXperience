import 'package:flutter/material.dart';
import 'package:teamxperience/features/play_tab/logic/play_tab_state.dart';
import 'package:teamxperience/features/play_tab/widgets/play_tab_view.dart';
import 'package:teamxperience/features/shell/logic/player_tabs.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/ui/components/misc/segmented_switch.dart';
import 'package:teamxperience/ui/components/navigation/app_bottom_nav.dart';
import 'package:teamxperience/ui/components/navigation/tab_header.dart';
import 'package:teamxperience/ui/ui.dart';

import 'sample_event.dart';

/// The interim Joacă tab in its four states, inside the five-tab bar (red
/// "În joc" while the game is on).
class PlayTabPreview extends StatefulWidget {
  const PlayTabPreview({super.key});

  @override
  State<PlayTabPreview> createState() => _PlayTabPreviewState();
}

class _PlayTabPreviewState extends State<PlayTabPreview> {
  int _state = 0;

  static final _team = Team(
    name: 'Vulpile',
    teamMembers: '',
    captainName: 'Victor',
    phoneNumber: '',
    captainEmail: '',
    numberOfMembers: 4,
  );

  PlayTabState get _current => switch (_state) {
        0 => PlayLive(sampleEvent(), _team),
        1 => PlayEnterCode(sampleEvent(), 42),
        2 => PlayNext(sampleEvent(), const Duration(days: 3)),
        _ => const PlayNone(),
      };

  void _say(String what) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(what)));

  @override
  Widget build(BuildContext context) {
    final state = _current;
    return Scaffold(
      body: Column(
        children: [
          const TabHeader(title: 'Joacă'),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.sm, AppSpacing.page, 0),
            child: SegmentedSwitch(
              labels: const ['În joc', 'Cod', 'Următorul', 'Nimic'],
              selectedIndex: _state,
              onSelected: (i) => setState(() => _state = i),
            ),
          ),
          Expanded(
            child: PlayTabView(
              state: state,
              onContinue: (_, _) => _say('continue'),
              onEnterCode: (_) => _say('code'),
              onOpenEvent: (_) => _say('open'),
              onBrowse: () => _say('browse'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: PlayerTab.play,
        onSelected: (i) => _say('tab $i'),
        items: playerNavItems(live: isLive(state)),
      ),
    );
  }
}
