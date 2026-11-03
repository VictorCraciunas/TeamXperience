import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

/// A titled block of the component gallery.
class GallerySection extends StatelessWidget {
  const GallerySection({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
            child: Text(title.toUpperCase(), style: AppTextStyles.smallMuted(context)),
          ),
          child,
        ],
      ),
    );
  }
}
