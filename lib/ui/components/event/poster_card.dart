import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../theme/theme_context.dart';

class PosterCard extends StatelessWidget {
  const PosterCard({
    super.key,
    required this.title,
    required this.dateLabel,
    required this.place,
    this.imageUrl,
    this.onTap,
    this.width = 112,
    this.height = 128,
  });

  final String title;
  final String dateLabel;
  final String place;
  final String? imageUrl;
  final VoidCallback? onTap;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final url = imageUrl;
    final fallback = ColoredBox(color: colors.navy);

    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(
              child: (url == null || url.isEmpty)
                  ? fallback
                  : CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => fallback,
                      errorWidget: (_, __, ___) => fallback,
                    ),
            ),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00000000), Color(0xD1080A14)],
                    stops: [0.4, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 9,
              right: 9,
              bottom: 9,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFFF0E1B8), fontSize: 10),
                  ),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                  Text(
                    place,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFFD3DAE6), fontSize: 10),
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(onTap: onTap),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
