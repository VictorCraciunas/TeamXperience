import 'package:flutter/material.dart';
import 'package:teamxperience/enums/photo_approval_status.dart';
import 'package:teamxperience/features/admin/home/logic/admin_event_stats.dart';
import 'package:teamxperience/features/live_room/logic/attention_queue.dart';
import 'package:teamxperience/features/live_room/logic/live_board.dart';
import 'package:teamxperience/features/live_room/logic/live_map_points.dart';
import 'package:teamxperience/features/live_room/logic/live_status.dart';
import 'package:teamxperience/features/live_room/logic/live_texts.dart';
import 'package:teamxperience/features/live_room/widgets/board_view.dart';
import 'package:teamxperience/features/live_room/widgets/live_map.dart';
import 'package:teamxperience/features/live_room/widgets/live_room_view.dart';
import 'package:teamxperience/features/live_room/widgets/team_sheet.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/photo_detail.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/ui/components/misc/app_chip.dart';
import 'package:teamxperience/ui/components/misc/app_chip_style.dart';
import 'package:teamxperience/ui/ui.dart';

import 'sample_event.dart';

/// Mockup 09: the live room and the board with the mockup's teams, and an event
/// with nobody registered. The buttons only change what the preview shows.
class LiveRoomPreview extends StatefulWidget {
  const LiveRoomPreview({super.key});

  @override
  State<LiveRoomPreview> createState() => _LiveRoomPreviewState();
}

class _LiveRoomPreviewState extends State<LiveRoomPreview> {
  bool _board = false;
  bool _empty = false;
  BoardFilter _filter = BoardFilter.all;

  late final Event _event = () {
    final event = sampleEvent();
    event.dateEvent = DateTime.now().subtract(const Duration(hours: 1, minutes: 42));
    event.isStopped = false;
    return event;
  }();

  Team _team(
    String name, {
    bool started = true,
    int progress = 0,
    int minutesAgo = 0,
    double? lat,
    double? lng,
    Map<String, int>? attempts,
    bool photo = false,
    String? unread,
    DateTime? now,
  }) {
    final at = (now ?? DateTime.now()).subtract(Duration(minutes: minutesAgo));
    return Team(
      name: name,
      teamMembers: '',
      captainName: 'Ana Pop',
      phoneNumber: '0722 123 456',
      captainEmail: '',
      hasStarted: started,
      missionProgress: progress,
      latitude: lat ?? 0,
      longitude: lng ?? 0,
      startedAt: started ? at : null,
      missionCompletedAt: progress > 0 ? {progress - 1: at} : null,
      attempts: attempts,
      photoApprovals: photo ? {'${progress}_0_0': PhotoApprovalStatus.pending} : null,
      photoDetails: photo ? {'${progress}_0_0': PhotoDetail(status: PhotoApprovalStatus.pending, at: at)} : null,
      unreadText: unread,
      unreadAt: unread == null ? null : at,
    );
  }

  List<Team> _teams(DateTime now) => _empty
      ? const []
      : [
          _team('Bufnițele', progress: 5, minutesAgo: 2, lat: 45.803, lng: 24.145, now: now),
          _team('Vulpile', progress: 3, minutesAgo: 1, lat: 45.799, lng: 24.135, photo: true, now: now),
          _team('Lupii de Cetate', progress: 3, minutesAgo: 5, lat: 45.797, lng: 24.131, unread: 'Ușa e închisă, ce facem?', now: now),
          _team('Cometele', progress: 1, minutesAgo: 25, lat: 45.794, lng: 24.126, attempts: {'1_0': 3}, now: now),
          _team('Rapsodia', progress: 1, minutesAgo: 1, lat: 45.790, lng: 24.118, now: now),
          _team('Pisicile', started: false, now: now),
        ];

  void _openTeam(Team team, DateTime now) {
    final missions = _event.missions.length;
    showTeamSheet(
      context,
      team: team,
      tone: pinToneOf(team, missionCount: missions, now: now, eventOver: false),
      status: boardStatusText(boardRows([team], missionCount: missions, now: now, eventOver: false).single, now),
      onCall: () {},
      onMessage: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final teams = _teams(now);
    final missions = _event.missions.length;
    final over = eventEnded(_event, now);
    return Scaffold(
      body: _board
          ? BoardView(
              teamCount: teams.length,
              missionCount: missions,
              rows: boardRows(teams, missionCount: missions, now: now, eventOver: over, filter: _filter),
              filter: _filter,
              now: now,
              canStop: true,
              onFilter: (filter) => setState(() => _filter = filter),
              onTeam: (team) => _openTeam(team, now),
              onCall: (_) {},
              onAnnounce: () {},
              onStop: () {},
            )
          : LiveRoomView(
              event: _event,
              stats: AdminEventStats.fromTeams(teams),
              items: attentionQueue(teams, missionCount: missions, now: now, eventOver: over),
              map: LiveMap(
                event: _event,
                teams: teams,
                now: now,
                onTeam: (team) => _openTeam(team, now),
                onBigMap: () {},
              ),
              isDeciding: (_) => false,
              onBoard: (_) => setState(() => _board = true),
              onAnnounce: () {},
              onViewPhoto: (_) {},
              onReject: (_) {},
              onApprove: (_) {},
              onTeam: (team) => _openTeam(team, now),
              onChat: (_) {},
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Wrap(
            spacing: 6,
            children: [
              AppChip(
                label: 'Camera',
                style: _board ? AppChipStyle.plain : AppChipStyle.selected,
                onTap: () => setState(() => _board = false),
              ),
              AppChip(
                label: 'Tabloul',
                style: _board ? AppChipStyle.selected : AppChipStyle.plain,
                onTap: () => setState(() => _board = true),
              ),
              AppChip(
                label: 'Fără echipe',
                style: _empty ? AppChipStyle.selected : AppChipStyle.plain,
                onTap: () => setState(() => _empty = !_empty),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
