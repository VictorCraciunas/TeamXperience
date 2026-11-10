import 'package:flutter/material.dart';

/// A small rounded label with an icon: "A început", "În joc", "La întâmplare".
class GamePill extends StatelessWidget {
  const GamePill({super.key, required this.icon, required this.label, required this.fill, required this.text});

  final IconData icon;
  final String label;
  final Color fill;
  final Color text;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(99)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: text),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 12, height: 1.45, fontWeight: FontWeight.w600, color: text),
                ),
              ),
            ],
          ),
        ),
      );
}
