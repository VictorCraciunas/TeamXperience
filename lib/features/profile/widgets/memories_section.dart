import 'package:flutter/material.dart';
import 'package:teamxperience/model/memory.dart';
import 'package:teamxperience/ui/components/misc/section_header.dart';
import 'package:teamxperience/ui/ui.dart';

import 'memory_card.dart';

/// "Amintiri": up to three past games, or a line saying where they will appear.
class MemoriesSection extends StatelessWidget {
  const MemoriesSection({super.key, required this.memories, this.failed = false, required this.onOpen});

  static const int shown = 3;

  final List<Memory> memories;

  /// The memories could not be read.
  final bool failed;
  final ValueChanged<Memory> onOpen;

  @override
  Widget build(BuildContext context) {
    final list = memories.take(shown).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SectionHeader(title: 'Amintiri'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: list.isEmpty
              ? Text(
                  failed ? 'Nu am putut încărca amintirile.' : 'Aici apar jocurile tale terminate.',
                  style: TextStyle(fontSize: 12, height: 1.45, color: context.colors.muted),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < list.length; i++) ...[
                      if (i > 0) const SizedBox(height: 8),
                      MemoryCard(memory: list[i], onTap: () => onOpen(list[i])),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}
