import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/features/profile/logic/profile_texts.dart';
import 'package:teamxperience/features/team_photo/logic/team_album.dart';
import 'package:teamxperience/features/team_photo/widgets/album_tile.dart';
import 'package:teamxperience/model/memory.dart';
import 'package:teamxperience/ui/components/event/event_picture.dart';
import 'package:teamxperience/ui/components/game/game_outline_button.dart';
import 'package:teamxperience/ui/components/misc/section_header.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:teamxperience/utils/event_formats.dart';

import 'memory_fact_card.dart';

/// One past game: its name, day and team, place and time, and the photos in
/// the order of the game. Start and final are large, the puzzle photos sit
/// side by side.
class MemoryAlbumView extends StatelessWidget {
  const MemoryAlbumView({
    super.key,
    required this.memory,
    required this.album,
    this.teamName,
    this.eventPicture,
    this.onEvent,
    required this.onPhoto,
  });

  final Memory memory;
  final List<AlbumPhoto> album;
  final String? teamName;
  final String? eventPicture;

  /// Opens the event's page; null when the event is not loaded.
  final VoidCallback? onEvent;
  final ValueChanged<AlbumPhoto> onPhoto;

  static const double _gap = 8;

  bool _isLarge(AlbumPhoto photo) => photo.label == 'Start' || photo.label == 'Final';

  Widget _tile(AlbumPhoto photo, double height) => GestureDetector(
        key: ValueKey('album-${photo.url}'),
        behavior: HitTestBehavior.opaque,
        onTap: () => onPhoto(photo),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(height: height, child: AlbumTile(photo: photo)),
        ),
      );

  /// Large photos on their own rows, the others in pairs, in album order.
  List<Widget> _photoRows() {
    final rows = <Widget>[];
    final pair = <AlbumPhoto>[];

    void flush() {
      if (pair.isEmpty) return;
      final first = pair[0];
      final second = pair.length > 1 ? pair[1] : null;
      rows.add(Row(
        children: [
          Expanded(child: _tile(first, 110)),
          const SizedBox(width: _gap),
          Expanded(child: second == null ? const SizedBox(height: 110) : _tile(second, 110)),
        ],
      ));
      pair.clear();
    }

    for (final photo in album) {
      if (_isLarge(photo)) {
        flush();
        rows.add(_tile(photo, 190));
      } else {
        pair.add(photo);
        if (pair.length == 2) flush();
      }
    }
    flush();
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final date = memory.date;
    final team = teamName;
    final subtitle = [
      if (date != null) '${shortDay(date)} ${dayAndMonth(date)}',
      if (team != null && team.isNotEmpty) 'Echipa $team',
    ].join(' · ');
    final place = memory.place;
    final minutes = memory.totalMinutes;
    final event = onEvent;
    final rows = _photoRows();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(memory.eventName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, height: 1.45, color: colors.text)),
              if (subtitle.isNotEmpty) Text(subtitle, style: TextStyle(fontSize: 14, height: 1.45, color: colors.muted)),
            ],
          ),
        ),
        if (place != null || minutes != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Row(
              children: [
                if (place != null) Expanded(child: MemoryFactCard(value: 'Locul $place', label: 'în clasament', accent: true)),
                if (place != null && minutes != null) const SizedBox(width: 6),
                if (minutes != null) Expanded(child: MemoryFactCard(value: memoryTime(minutes), label: 'timp total')),
              ],
            ),
          ),
        if (album.isNotEmpty) ...[
          const SectionHeader(title: 'Pozele voastre', top: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0) const SizedBox(height: _gap),
                  rows[i],
                ],
              ],
            ),
          ),
        ] else
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: EventPicture(url: eventPicture, height: 160),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nicio poză la acest joc.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, height: 1.45, color: colors.muted),
                ),
              ],
            ),
          ),
        if (event != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: GameOutlineButton(label: 'Vezi pagina evenimentului', icon: TablerIcons.map_2, onTap: event),
          )
        else
          const SizedBox(height: 14),
      ],
    );
  }
}
