import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/model/stire.dart';
import 'package:teamxperience/ui/components/event/picture_chip.dart';
import 'package:teamxperience/ui/components/layout/outline_card.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:teamxperience/utils/event_formats.dart';

/// One news item in the carousel on Home: its picture with the category on
/// it, the title in up to two lines, and the date. With no picture, a flat
/// colour with an icon.
class NewsSlideCard extends StatelessWidget {
  const NewsSlideCard({super.key, required this.stire, required this.pictureHeight, required this.onTap});

  final Stire stire;
  final double pictureHeight;
  final VoidCallback onTap;

  static const double titleSize = 15;
  static const double titleHeight = 1.35;
  static const double dateSize = 13;
  static const double dateHeight = 1.45;

  /// Everything around the text: its padding and the card's border.
  static const double textPadding = 27;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final picture = stire.principalImage ?? '';
    final date = stire.publicationDate;
    final category = stire.category?.name ?? '';
    final noPicture = ColoredBox(
      key: const ValueKey('news-no-picture'),
      color: colors.accent,
      child: Center(child: Icon(TablerIcons.news, size: 36, color: colors.onNavy)),
    );

    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: OutlineCard(
          key: const ValueKey('news-card'),
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: pictureHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (picture.isEmpty)
                        noPicture
                      else
                        LayoutBuilder(
                          builder: (context, box) => CachedNetworkImage(
                            imageUrl: picture,
                            fit: BoxFit.cover,
                            memCacheWidth: (box.maxWidth * MediaQuery.devicePixelRatioOf(context)).round(),
                            errorWidget: (_, _, _) => noPicture,
                          ),
                        ),
                      if (category.isNotEmpty)
                        Positioned(
                          left: 10,
                          right: 10,
                          top: 10,
                          child: Align(alignment: Alignment.centerLeft, child: PictureChip(text: category)),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        stire.title ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.w500, height: titleHeight, color: colors.text),
                      ),
                      if (date != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(
                            dayAndMonth(date),
                            style: TextStyle(fontSize: dateSize, height: dateHeight, color: colors.muted),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
