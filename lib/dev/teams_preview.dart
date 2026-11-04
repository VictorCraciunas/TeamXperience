import 'package:flutter/material.dart';
import 'package:teamxperience/features/teams/widgets/teams_view.dart';
import 'package:teamxperience/model/crew.dart';
import 'package:teamxperience/model/team_member.dart';
import 'package:teamxperience/ui/components/misc/segmented_switch.dart';
import 'package:teamxperience/ui/ui.dart';

/// The Echipe screen with the mockup's crew, to hold next to
/// docs/roadmap/mockups/03-events-and-teams-tabs.html. The switch shows the
/// crew and the screen of a player with no crews.
class TeamsPreview extends StatefulWidget {
  const TeamsPreview({super.key});

  @override
  State<TeamsPreview> createState() => _TeamsPreviewState();
}

class _TeamsPreviewState extends State<TeamsPreview> {
  int _state = 0;

  static const _vulpile = Crew(
    id: 'vulpile',
    name: 'Vulpile',
    captainUid: 'u1',
    memberUids: ['u1', 'u2', 'u3', 'u4'],
    members: [
      TeamMember(uid: 'u1', displayName: 'Victor', initials: 'VC'),
      TeamMember(uid: 'u2', displayName: 'Ana M', initials: 'AM'),
      TeamMember(uid: 'u3', displayName: 'Ioana R', initials: 'IR'),
      TeamMember(uid: 'u4', displayName: 'Dan P', initials: 'DP'),
    ],
    inviteCode: 'VLP482',
  );

  void _say(String what) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(what)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.page,
      appBar: AppBar(
        title: const Text('Echipe'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              0,
              AppSpacing.page,
              AppSpacing.sm,
            ),
            child: SegmentedSwitch(
              labels: const ['Cu echipă', 'Fără echipe'],
              selectedIndex: _state,
              onSelected: (i) => setState(() => _state = i),
            ),
          ),
        ),
      ),
      body: TeamsView(
        crews: _state == 0 ? const [_vulpile] : const [],
        myUid: 'u1',
        onNewCrew: () => _say('echipă nouă'),
        onJoin: () => _say('intră cu un cod'),
        onShare: (_) => _say('WhatsApp'),
        onCopy: (_) => _say('copiază'),
      ),
    );
  }
}
