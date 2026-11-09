import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/ui/components/feedback/load_failed.dart';
import 'package:teamxperience/ui/components/layout/outline_card.dart';
import 'package:teamxperience/ui/components/misc/app_chip.dart';
import 'package:teamxperience/ui/components/misc/app_chip_style.dart';
import 'package:teamxperience/ui/ui.dart';

import '../logic/live_board.dart';
import '../logic/live_texts.dart';
import 'board_action_button.dart';
import 'board_row_tile.dart';
import 'live_header.dart';

/// The board (mockup 09, right): every team's progress, filters, and the
/// announce and stop buttons.
class BoardView extends StatelessWidget {
  const BoardView({
    super.key,
    required this.teamCount,
    required this.missionCount,
    required this.rows,
    required this.filter,
    required this.now,
    required this.canStop,
    this.announcing = false,
    this.failed = false,
    required this.onFilter,
    required this.onTeam,
    required this.onCall,
    required this.onAnnounce,
    required this.onStop,
  });

  /// Every team of the event, whatever the filter shows.
  final int teamCount;
  final int missionCount;
  final List<BoardRow> rows;
  final BoardFilter filter;
  final DateTime now;

  /// Shows "Oprește".
  final bool canStop;

  /// An announcement is on its way: its button rests and says so.
  final bool announcing;

  /// The teams could not be read.
  final bool failed;
  final ValueChanged<BoardFilter> onFilter;
  final ValueChanged<Team> onTeam;
  final ValueChanged<Team> onCall;
  final VoidCallback onAnnounce;
  final VoidCallback onStop;

  static const _filters = {
    BoardFilter.all: 'Toate',
    BoardFilter.stuck: 'Blocate',
    BoardFilter.notStarted: 'Neporniți',
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LiveHeader(title: 'Progresul echipelor', line: boardHeaderLine(teamCount, missionCount)),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final entry in _filters.entries)
                AppChip(
                  label: entry.value,
                  style: entry.key == filter ? AppChipStyle.selected : AppChipStyle.plain,
                  onTap: () => onFilter(entry.key),
                ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: rows.isEmpty && failed && teamCount == 0
                ? const LoadFailed(message: 'Nu am putut încărca echipele.')
                : rows.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      filter == BoardFilter.all ? 'Nu e nicio echipă înscrisă.' : 'Nicio echipă aici.',
                      style: TextStyle(fontSize: 14, height: 1.45, color: colors.muted),
                    ),
                  )
                : OutlineCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < rows.length; i++)
                          BoardRowTile(
                            row: rows[i],
                            missionCount: missionCount,
                            now: now,
                            last: i == rows.length - 1,
                            onTap: () => onTeam(rows[i].team),
                            onCall: () => onCall(rows[i].team),
                          ),
                      ],
                    ),
                  ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 6.5, 14, 8.5),
            child: Row(
              children: [
                Expanded(
                  child: BoardActionButton(
                    label: announcing ? 'Se trimite...' : 'Anunț',
                    icon: TablerIcons.speakerphone,
                    colour: colors.accent,
                    onTap: announcing ? null : onAnnounce,
                  ),
                ),
                if (canStop) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: BoardActionButton(
                      label: 'Oprește',
                      icon: TablerIcons.player_stop,
                      colour: colors.danger,
                      onTap: onStop,
                    ),
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
