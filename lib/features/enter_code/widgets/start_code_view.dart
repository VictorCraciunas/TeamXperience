import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/features/enter_code/logic/start_code_check.dart';
import 'package:teamxperience/features/enter_code/logic/start_texts.dart';
import 'package:teamxperience/features/home/logic/live_texts.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/ui/components/inputs/code_boxes_input.dart';
import 'package:teamxperience/ui/ui.dart';

import 'start_button.dart';
import 'start_chat_link.dart';
import 'start_refusal_line.dart';
import 'team_here_card.dart';

/// The start-code screen of mockup 05 on navy: the time left to enter, the
/// code boxes and why a code was refused, who of the team is here, the start
/// button and the chat link. Fed plain values; the screen does the rest.
class StartCodeView extends StatelessWidget {
  const StartCodeView({
    super.key,
    required this.event,
    required this.now,
    required this.team,
    required this.codeLength,
    required this.code,
    required this.result,
    required this.started,
    required this.busy,
    required this.onCode,
    required this.onSubmit,
    required this.onClose,
    this.onChat,
    this.photoCard,
  });

  final Event event;
  final DateTime now;
  final Team? team;
  final int codeLength;
  final String code;
  final StartCodeResult? result;

  /// The team already started: no code needed.
  final bool started;
  final bool busy;
  final ValueChanged<String> onCode;
  final VoidCallback onSubmit;
  final VoidCallback onClose;

  /// Opens the team chat; null hides the link.
  final VoidCallback? onChat;

  /// The optional team photo; never in the way of the start button.
  final Widget? photoCard;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final onNavy = colors.onNavy;
    final error = startError(result);
    final current = team;
    final chat = onChat;
    final photo = photoCard;

    return ColoredBox(
      color: colors.navy,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                children: [
                  Semantics(
                    button: true,
                    label: 'Închide',
                    child: GestureDetector(
                      onTap: onClose,
                      behavior: HitTestBehavior.opaque,
                      child: SizedBox.square(dimension: 44, child: Icon(TablerIcons.x, size: 20, color: onNavy)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Align(
                      alignment: Alignment.centerRight,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.soon,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 2,
                          ),
                          child: Text(
                            enterPill(event, now),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              height: 1.45,
                              color: colors.onTick,
                            ),
                          ),
                        ),
                      ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                      child: Column(
                        children: [
                          Text(
                            event.name ?? '',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.45,
                              color: onNavy.withValues(alpha: .75),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Introdu codul de start',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              height: 1.45,
                              color: onNavy,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            codeHint(event),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.45,
                              color: onNavy.withValues(alpha: .75),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!started) ...[
                      const SizedBox(height: 22),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: CodeBoxesInput(
                          length: codeLength,
                          onChanged: onCode,
                          error: result == StartCodeResult.wrong,
                          onDark: true,
                        ),
                      ),
                    ],
                    if (error != null) ...[
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: StartRefusalLine(message: error),
                      ),
                    ],
                    if (!started) ...[
                      SizedBox(height: error == null ? 10 : 4),
                      Text(
                        'Nu contează literele mari sau mici.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: onNavy.withValues(alpha: .7),
                        ),
                      ),
                    ],
                    if (current != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 22, 14, 0),
                        child: TeamHereCard(
                          teamName: current.name,
                          hereInitials: [
                            for (final m in activeMembers(current, now))
                              m.initials,
                          ],
                          size:
                              current.numberOfMembers > 0
                                  ? current.numberOfMembers
                                  : current.memberList.length,
                        ),
                      ),
                    if (photo != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                        child: photo,
                      ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  StartButton(
                    label: started ? 'Intră în joc' : 'Pornește jocul',
                    busy: busy,
                    onTap: onSubmit,
                  ),
                  if (chat != null) ...[
                    const SizedBox(height: 4),
                    StartChatLink(onTap: chat),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
