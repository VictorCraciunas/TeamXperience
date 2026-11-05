import 'package:flutter/material.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';

/// The mockups' `.lb`: an 11 px medium label with 4 px under it.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: context.colors.text,
          height: 1.45,
        ),
      ),
    );
  }
}
