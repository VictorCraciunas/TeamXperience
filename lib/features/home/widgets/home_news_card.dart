import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:teamxperience/model/stire.dart';
import 'package:teamxperience/ui/components/layout/outline_card.dart';
import 'package:teamxperience/ui/components/misc/section_header.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:teamxperience/utils/event_formats.dart';

/// "Știri" on Home: the latest news item.
class HomeNewsCard extends StatelessWidget {
  const HomeNewsCard({super.key, required this.stire, required this.onOpen, required this.onAll});

  final Stire stire;
  final VoidCallback onOpen;
  final VoidCallback onAll;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final date = stire.publicationDate;
    final picture = stire.principalImage ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SectionHeader(title: 'Știri', link: 'Toate', onLink: onAll, top: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onOpen,
            child: OutlineCard(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox.square(
                      dimension: 40,
                      child: ColoredBox(
                        color: colors.accent,
                        child: picture.isEmpty
                            ? null
                            : CachedNetworkImage(
                                imageUrl: picture,
                                fit: BoxFit.cover,
                                errorWidget: (_, _, _) => const SizedBox.shrink(),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stire.title ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, height: 1.45, fontWeight: FontWeight.w500, color: colors.text),
                        ),
                        if (date != null)
                          Text(dayAndMonth(date), style: TextStyle(fontSize: 11, height: 1.45, color: colors.muted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
