import 'package:flutter/material.dart';
import 'package:teamxperience/features/team_photo/logic/team_album.dart';
import 'package:teamxperience/model/memory.dart';
import 'package:teamxperience/ui/components/misc/section_header.dart';
import 'package:teamxperience/ui/ui.dart';

import 'memory_card.dart';

/// "Amintiri": up to three past games, or a line saying where they will appear.
class MemoriesSection extends StatelessWidget {
  const MemoriesSection({
    super.key,
    required this.memories,
    this.failed = false,
    required this.onOpen,
    this.onAll,
    this.albumOf,
    this.pictureOf,
  });

  static const int shown = 3;

  final List<Memory> memories;

  /// The memories could not be read.
  final bool failed;
  final ValueChanged<Memory> onOpen;

  /// Opens the list of all of them; null hides the link.
  final VoidCallback? onAll;

  /// A game's photos, once read.
  final List<AlbumPhoto> Function(String eventId)? albumOf;

  /// The event's main picture, for a game without photos.
  final String? Function(String eventId)? pictureOf;

  Widget _card(Memory memory) {
    final album = albumOf?.call(memory.eventId) ?? const <AlbumPhoto>[];
    return MemoryCard(
      memory: memory,
      imageUrl: memoryThumbnail(album, pictureOf?.call(memory.eventId)),
      photoCount: album.isEmpty ? null : album.length,
      onTap: () => onOpen(memory),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = memories.take(shown).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SectionHeader(title: 'Amintiri', link: onAll == null ? null : 'Toate', onLink: onAll),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: list.isEmpty
              ? Text(
                  failed ? 'Nu am putut încărca amintirile.' : 'Aici apar jocurile tale terminate.',
                  style: TextStyle(fontSize: 14, height: 1.45, color: context.colors.muted),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < list.length; i++) ...[
                      if (i > 0) const SizedBox(height: 8),
                      _card(list[i]),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}
