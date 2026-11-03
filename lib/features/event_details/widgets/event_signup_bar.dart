import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/features/event_details/logic/signup_bar_state.dart';
import 'package:teamxperience/ui/components/buttons/bar_tone.dart';
import 'package:teamxperience/ui/components/buttons/sticky_action_bar.dart';

/// The event page's bottom bar for one [SignupBar] state.
class EventSignupBar extends StatelessWidget {
  const EventSignupBar({super.key, required this.bar, required this.onAction});

  final SignupBar bar;
  final void Function(SignupAction) onAction;

  @override
  Widget build(BuildContext context) {
    final (tone, icon) = switch (bar.tone) {
      SignupTone.success => (BarTone.success, TablerIcons.circle_check),
      SignupTone.accent => (BarTone.accent, TablerIcons.player_play),
      SignupTone.neutral => (BarTone.neutral, null),
    };
    return StickyActionBar(
      title: bar.title,
      detail: bar.detail,
      inlineDetail: bar.inlineDetail,
      leadingIcon: icon,
      tone: tone,
      highlighted: bar.highlighted,
      prominent: bar.prominent,
      actionLabel: bar.actionLabel,
      actionIcon: bar.prominent ? TablerIcons.users_plus : null,
      onAction: () => onAction(bar.action),
    );
  }
}
