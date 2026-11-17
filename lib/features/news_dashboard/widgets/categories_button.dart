import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

/// The organiser header's "Categorii" pill.
class CategoriesButton extends StatelessWidget {
  const CategoriesButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(44, 44),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        foregroundColor: colors.text,
        backgroundColor: colors.panel,
        side: BorderSide(color: colors.border),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
      child: const Text('Categorii', maxLines: 1),
    );
  }
}
