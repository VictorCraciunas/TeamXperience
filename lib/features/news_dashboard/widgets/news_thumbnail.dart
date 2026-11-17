import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/ui.dart';

/// A news picture, cropped to fill its box, with a plain inset box and a
/// news icon while it loads or when there is none.
class NewsThumbnail extends StatelessWidget {
  const NewsThumbnail({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.radius = 12,
  });

  final String? url;
  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final link = url;
    final fallback = ColoredBox(
      color: colors.inset,
      child: Center(child: Icon(TablerIcons.news, size: 24, color: colors.muted)),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: width,
        height: height,
        child:
            link == null || link.isEmpty
                ? fallback
                : CachedNetworkImage(
                  imageUrl: link,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => fallback,
                  errorWidget: (_, __, ___) => fallback,
                ),
      ),
    );
  }
}
