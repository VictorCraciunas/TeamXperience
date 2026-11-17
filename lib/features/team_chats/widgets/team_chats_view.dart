import 'package:flutter/material.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/ui/components/feedback/load_failed.dart';
import 'package:teamxperience/ui/ui.dart';

import '../logic/chat_row.dart';
import '../logic/chat_texts.dart';
import 'chat_filter_chip.dart';
import 'chat_row_tile.dart';
import 'chat_section_label.dart';
import 'team_chats_header.dart';

/// The organiser's conversations: the header, the "Toate" / "Necitite"
/// chips, then the chats with something to read and the rest.
class TeamChatsView extends StatelessWidget {
  const TeamChatsView({
    super.key,
    required this.subtitle,
    required this.loading,
    required this.failed,
    required this.teamCount,
    required this.unreadCount,
    required this.filter,
    required this.sections,
    required this.now,
    required this.onBack,
    required this.onFilter,
    required this.onOpen,
    required this.onRetry,
  });

  final String subtitle;
  final bool loading;
  final bool failed;
  final int teamCount;
  final int unreadCount;
  final ChatFilter filter;
  final ({List<ChatRow> unread, List<ChatRow> read}) sections;
  final DateTime now;
  final VoidCallback onBack;
  final ValueChanged<ChatFilter> onFilter;
  final ValueChanged<Team> onOpen;
  final VoidCallback onRetry;

  Widget _message(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.fromLTRB(14, 28, 14, 6),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTextStyles.pageBody(context).copyWith(color: context.colors.muted),
        ),
      );

  List<Widget> _rows(List<ChatRow> rows) => [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ChatRowTile(row: row, now: now, onTap: () => onOpen(row.team)),
          ),
      ];

  List<Widget> _body(BuildContext context) {
    if (failed) return [LoadFailed(message: 'Nu am putut încărca echipele.', onRetry: onRetry)];
    if (teamCount == 0) return [_message(context, 'Nicio echipă înscrisă.')];
    final unread = sections.unread;
    final read = sections.read;
    if (filter == ChatFilter.unread) {
      return unread.isEmpty ? [_message(context, 'Niciun mesaj necitit.')] : _rows(unread);
    }
    return [
      if (unread.isNotEmpty) ...[const ChatSectionLabel('Necitite'), ..._rows(unread)],
      if (read.isNotEmpty) ...[const ChatSectionLabel('Citite'), ..._rows(read)],
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TeamChatsHeader(subtitle: subtitle, onBack: onBack),
        Expanded(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.page, 4, AppSpacing.page, 24),
                  children: [
                    if (!failed && teamCount > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Wrap(
                          spacing: 8,
                          children: [
                            ChatFilterChip(
                              label: allChipLabel(teamCount),
                              selected: filter == ChatFilter.all,
                              onTap: () => onFilter(ChatFilter.all),
                            ),
                            ChatFilterChip(
                              label: unreadChipLabel(unreadCount),
                              selected: filter == ChatFilter.unread,
                              dot: unreadCount > 0,
                              onTap: () => onFilter(ChatFilter.unread),
                            ),
                          ],
                        ),
                      ),
                    ..._body(context),
                  ],
                ),
        ),
      ],
    );
  }
}
