import 'package:flutter/widgets.dart';

class HeroAction {
  const HeroAction({required this.label, required this.onTap, this.icon});

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
}
