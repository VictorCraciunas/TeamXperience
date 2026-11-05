import 'package:flutter/material.dart';
import 'package:teamxperience/features/enter_code/logic/start_code_check.dart';
import 'package:teamxperience/features/enter_code/logic/start_texts.dart';
import 'package:teamxperience/features/enter_code/widgets/start_code_view.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/ui/components/misc/segmented_switch.dart';
import 'package:teamxperience/ui/ui.dart';

import 'sample_event.dart';

/// The start-code screen of mockup 05 with its data, in four states: typing,
/// a wrong code, a teammate already started, and no team found.
class StartCodePreview extends StatefulWidget {
  const StartCodePreview({super.key});

  @override
  State<StartCodePreview> createState() => _StartCodePreviewState();
}

class _StartCodePreviewState extends State<StartCodePreview> {
  /// 42 minutes left to enter.
  static final _now = DateTime(2026, 11, 14, 10, 18);

  int _state = 0;

  void _say(String what) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(what)));

  Team _team({required bool started}) => Team(
        name: 'Vulpile',
        teamMembers: '',
        captainName: 'Victor',
        phoneNumber: '',
        captainEmail: '',
        numberOfMembers: 4,
        hasStarted: started,
        members: sampleMembers,
        presence: {for (final m in sampleMembers.take(3)) m.uid: _now.subtract(const Duration(seconds: 40))},
      );

  @override
  Widget build(BuildContext context) {
    final event = sampleEvent();
    final started = _state == 2;
    final noTeam = _state == 3;
    return Scaffold(
      backgroundColor: context.colors.navy,
      body: Column(
        children: [
          Expanded(
            child: StartCodeView(
              event: event,
              now: _now,
              team: noTeam ? null : _team(started: started),
              codeLength: codeLength(event),
              code: _state == 1 ? 'HARTI' : '',
              result: switch (_state) {
                1 => StartCodeResult.wrong,
                3 => StartCodeResult.noTeam,
                _ => null,
              },
              started: started,
              busy: false,
              onCode: (_) {},
              onSubmit: () => _say('submit'),
              onClose: () => Navigator.of(context).maybePop(),
              onChat: noTeam ? null : () => _say('chat'),
            ),
          ),
          ColoredBox(
            color: context.colors.page,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: SegmentedSwitch(
                  labels: const ['Cod', 'Greșit', 'Pornit', 'Fără echipă'],
                  selectedIndex: _state,
                  onSelected: (i) => setState(() => _state = i),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
