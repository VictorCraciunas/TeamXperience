import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

/// A light pill over a picture (the featured news' category).
class ImagePill extends StatelessWidget {
  const ImagePill({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.heroButton,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colors.text),
        ),
      ),
    );
  }
}
