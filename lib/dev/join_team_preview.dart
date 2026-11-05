import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/features/join_team/logic/join_state.dart';
import 'package:teamxperience/features/join_team/widgets/join_team_body.dart';
import 'package:teamxperience/model/team_member.dart';
import 'package:teamxperience/service/team_service/invite_preview.dart';
import 'package:teamxperience/ui/components/misc/segmented_switch.dart';
import 'package:teamxperience/ui/components/navigation/screen_bar.dart';
import 'package:teamxperience/ui/ui.dart';

/// The join screen with the mockup's team, to hold next to
/// docs/roadmap/mockups/04-register-and-join-team.html (right phone). The
/// switch shows a code that was found, an unfinished code and a code that
/// does not exist.
class JoinTeamPreview extends StatefulWidget {
  const JoinTeamPreview({super.key});

  @override
  State<JoinTeamPreview> createState() => _JoinTeamPreviewState();
}

class _JoinTeamPreviewState extends State<JoinTeamPreview> {
  int _state = 0;

  static final _found = InvitePreview(
    crewId: 'sample',
    crewName: 'Vulpile',
    captainName: 'Victor',
    members: const [
      TeamMember(uid: 'u1', displayName: 'Victor C', initials: 'VC'),
      TeamMember(uid: 'u2', displayName: 'Ana M', initials: 'AM'),
    ],
    alreadyMember: false,
    event: InviteEvent(
      eventId: 'sample',
      name: 'Moștenirea Cartografului',
      dateEvent: DateTime(2026, 11, 14, 10),
      teamName: 'Vulpile',
      size: 4,
      count: 2,
    ),
  );

  JoinState get _joinState => switch (_state) {
    0 => Found(_found),
    1 => const Typing(),
    _ => const Problem('Codul nu există'),
  };

  void _say(String what) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(what)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ScreenBar(
            leadingIcon: TablerIcons.arrow_left,
            onLeading: () => Navigator.maybePop(context),
            title: 'Intră într-o echipă',
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.page,
                      AppSpacing.sm,
                      AppSpacing.page,
                      0,
                    ),
                    child: SegmentedSwitch(
                      labels: const ['Găsit', 'Scrie', 'Problemă'],
                      selectedIndex: _state,
                      onSelected: (i) => setState(() => _state = i),
                    ),
                  ),
                  Expanded(
                    child: JoinTeamBody(
                      state: _joinState,
                      onCodeChanged: (_) {},
                      onJoin: () => _say('intră în echipă'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
