import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/features/profile/logic/profile_texts.dart';
import 'package:teamxperience/features/profile/widgets/memory_card.dart';
import 'package:teamxperience/features/team_photo/logic/team_album.dart';
import 'package:teamxperience/features/team_photo/widgets/album_strip.dart';
import 'package:teamxperience/model/memory.dart';
import 'package:teamxperience/ui/components/event/event_picture.dart';
import 'package:teamxperience/ui/components/game/game_outline_button.dart';
import 'package:teamxperience/ui/components/layout/outline_card.dart';
import 'package:teamxperience/ui/components/misc/section_header.dart';
import 'package:teamxperience/ui/ui.dart';

/// "Amintiri" on Home: the player's newest game. [large] shows its photos, for
/// a game just played; otherwise a single row.
class HomeMemoryCard extends StatelessWidget {
  const HomeMemoryCard({
    super.key,
    required this.memory,
    required this.album,
    this.eventPicture,
    required this.large,
    required this.onOpen,
    required this.onAll,
  });

  final Memory memory;
  final List<AlbumPhoto> album;

  /// The event's main picture, for a game without photos.
  final String? eventPicture;
  final bool large;
  final VoidCallback onOpen;
  final VoidCallback onAll;

  Widget _large(BuildContext context) {
    final colors = context.colors;
    final line = memoryLine(memory, photoCount: album.length);
    final picture = eventPicture ?? '';
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onOpen,
      child: OutlineCard(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (album.isNotEmpty)
              AlbumStrip(photos: album, onTap: (_) => onOpen())
            else if (picture.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: EventPicture(url: picture, height: 72),
              ),
            if (album.isNotEmpty || picture.isNotEmpty) const SizedBox(height: 8),
            Text(
              memory.eventName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, height: 1.45, fontWeight: FontWeight.w500, color: colors.text),
            ),
            if (line.isNotEmpty) Text(line, style: TextStyle(fontSize: 11, height: 1.45, color: colors.muted)),
            if (album.isNotEmpty) ...[
              const SizedBox(height: 10),
              GameOutlineButton(label: 'Vezi pozele', icon: TablerIcons.photo, onTap: onOpen),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SectionHeader(title: 'Amintiri', link: 'Toate', onLink: onAll, top: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: large
              ? _large(context)
              : MemoryCard(
                  memory: memory,
                  imageUrl: memoryThumbnail(album, eventPicture),
                  photoCount: album.length,
                  onTap: onOpen,
                ),
        ),
      ],
    );
  }
}
