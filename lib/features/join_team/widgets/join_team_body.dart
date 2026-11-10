import 'package:flutter/material.dart';
import 'package:teamxperience/features/join_team/logic/join_state.dart';
import 'package:teamxperience/features/join_team/widgets/invite_preview_card.dart';
import 'package:teamxperience/features/join_team/widgets/join_bottom_block.dart';
import 'package:teamxperience/features/join_team/widgets/join_intro.dart';
import 'package:teamxperience/ui/components/inputs/code_boxes_input.dart';
import 'package:teamxperience/ui/theme/app_text_styles.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';

/// The join screen under its bar, drawn from a [JoinState]: the code boxes,
/// what was found for the code, and the button pinned to the bottom.
class JoinTeamBody extends StatelessWidget {
  const JoinTeamBody({
    super.key,
    required this.state,
    required this.onCodeChanged,
    required this.onJoin,
  });

  final JoinState state;
  final ValueChanged<String> onCodeChanged;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final current = state;
    final shown = switch (current) {
      Found(:final preview) => preview,
      Joining(:final preview) => preview,
      _ => null,
    };
    final problem = current is Problem ? current.text : null;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const JoinIntro(),
                const SizedBox(height: 12),
                CodeBoxesInput(
                  length: 6,
                  dashAfter: 3,
                  error: problem != null,
                  onChanged: onCodeChanged,
                ),
                if (problem != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    problem,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.smallMuted(
                      context,
                    ).copyWith(color: colors.danger),
                  ),
                ],
                if (shown != null) ...[
                  const SizedBox(height: 16),
                  InvitePreviewCard(preview: shown),
                ],
              ],
            ),
          ),
        ),
        JoinBottomBlock(
          label:
              shown == null ? 'Intră în echipă' : 'Intră în ${shown.crewName}',
          onJoin: current is Found ? onJoin : null,
          joining: current is Joining,
        ),
      ],
    );
  }
}
