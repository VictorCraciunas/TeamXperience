import 'package:flutter/widgets.dart';

class HeroAction {
  const HeroAction({required this.label, required this.onTap, this.icon});

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
}

/// An icon-only button next to the primary action of a hero card.
class HeroIconAction {
  const HeroIconAction({required this.icon, required this.onTap, this.label});

  final IconData icon;
  final VoidCallback onTap;

  /// Tooltip and screen-reader label of the icon.
  final String? label;
}
