import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

class InfoBanner extends StatelessWidget {
  final String text;

  const InfoBanner({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.border,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFB8860B)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF5C4A00),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
