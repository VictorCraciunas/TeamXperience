import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../theme/app_radius.dart';
import '../../theme/theme_context.dart';

class HeroCardFrame extends StatelessWidget {
  const HeroCardFrame({super.key, required this.child, this.imageUrl});

  final Widget child;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final url = imageUrl;
    final fallback = ColoredBox(color: colors.navy);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.hero),
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
                  colors: [Color(0x1F0C092A), Color(0xEB0C092A)],
                  stops: [0.0, 0.8],
                ),
              ),
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 210),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
