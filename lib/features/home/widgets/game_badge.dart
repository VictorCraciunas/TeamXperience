import 'package:flutter/material.dart';

/// The small pill at the top of a Home game card ("Următorul tău joc",
/// "LIVE"): padding 2 / 9, 11 px w500.
class GameBadge extends StatelessWidget {
  const GameBadge({super.key, required this.label, required this.fill, required this.text});

  final String label;
  final Color fill;
  final Color text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(99)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, height: 1.45, color: text),
        ),
      ),
    );
  }
}
