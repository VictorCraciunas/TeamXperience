import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/features/admin/home/logic/admin_event_stats.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/ui/components/misc/clock_builder.dart';
import 'package:teamxperience/ui/ui.dart';

import '../logic/attention_queue.dart';
import '../logic/live_board.dart';
import '../logic/live_status.dart';
import '../logic/live_texts.dart';
import 'attention_section.dart';
import 'live_count_card.dart';
import 'live_header.dart';
import 'live_header_action.dart';

/// The live room (mockup 09, left): the dark bar, the map, the counts and the
/// queue.
class LiveRoomView extends StatelessWidget {
  const LiveRoomView({
    super.key,
    required this.event,
    required this.stats,
    required this.items,
    required this.map,
    this.loading = false,
    this.failed = false,
    this.clock,
    required this.isDeciding,
    required this.onBoard,
    required this.onAnnounce,
    required this.onViewPhoto,
    required this.onReject,
    required this.onApprove,
    required this.onTeam,
    required this.onChat,
  });

  final Event event;
  final AdminEventStats stats;
  final List<AttentionItem> items;

  /// The map: its own widget, so previews and tests can leave it out.
  final Widget map;
  final bool loading;

  /// The teams could not be read: what shows may be old.
  final bool failed;

  /// Overrides the header's clock (for tests).
  final DateTime Function()? clock;
  final bool Function(PhotoAttention item) isDeciding;
  final ValueChanged<BoardFilter> onBoard;
  final VoidCallback onAnnounce;
  final ValueChanged<PhotoAttention> onViewPhoto;
  final ValueChanged<PhotoAttention> onReject;
  final ValueChanged<PhotoAttention> onApprove;
  final ValueChanged<Team> onTeam;
  final ValueChanged<Team> onChat;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClockBuilder(
          now: clock,
          builder: (context, now) => LiveHeader(
            title: event.name ?? '',
            line: liveHeaderLine(event, now),
            live: isLive(event, now),
            actions: [
              LiveHeaderAction(
                icon: TablerIcons.list_numbers,
                label: 'Progresul echipelor',
                onTap: () => onBoard(BoardFilter.all),
              ),
              LiveHeaderAction(icon: TablerIcons.speakerphone, label: 'Anunț', onTap: onAnnounce),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: colors.border))),
                  child: SizedBox(height: 170, child: map),
                ),
                if (failed)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                    child: Text(
                      'Nu am putut citi echipele. Ce vezi poate fi vechi.',
                      style: TextStyle(fontSize: 11, height: 1.45, color: colors.danger),
                    ),
                  ),
                if (loading)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: LiveCountCard(
                            value: stats.inPlay,
                            label: 'în joc',
                            onTap: () => onBoard(BoardFilter.all),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: LiveCountCard(
                            value: stats.finished,
                            label: 'au terminat',
                            colour: colors.success,
                            onTap: () => onBoard(BoardFilter.all),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: LiveCountCard(
                            value: stats.notStarted,
                            label: 'neporniți',
                            colour: colors.warning,
                            onTap: () => onBoard(BoardFilter.notStarted),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AttentionSection(
                    items: items,
                    isDeciding: isDeciding,
                    onViewPhoto: onViewPhoto,
                    onReject: onReject,
                    onApprove: onApprove,
                    onTeam: onTeam,
                    onChat: onChat,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
