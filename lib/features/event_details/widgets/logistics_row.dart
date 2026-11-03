import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

/// One line of the logistics card: an icon and a text, with an optional bold
/// lead ("Start:").
class LogisticsRow extends StatelessWidget {
  const LogisticsRow({super.key, required this.icon, required this.text, this.lead});

  final IconData icon;
  final String text;
  final String? lead;

  @override
  Widget build(BuildContext context) {
    final body = AppTextStyles.pageBody(context);
    final bold = lead;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12 * 1.45, child: Icon(icon, size: 15, color: context.colors.accent)),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(TextSpan(children: [
            if (bold != null) TextSpan(text: '$bold ', style: body.copyWith(fontWeight: FontWeight.w500)),
            TextSpan(text: text, style: body),
          ])),
        ),
      ],
    );
  }
}
