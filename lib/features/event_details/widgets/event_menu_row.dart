import 'package:flutter/material.dart';
import 'package:teamxperience/ui/theme/app_radius.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';

/// A plain row of the event's ⋮ sheet: an icon and a label. A [danger] row
/// ("Șterge evenimentul") is drawn in the danger colour.
class EventMenuRow extends StatelessWidget {
  const EventMenuRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textColor = danger ? colors.danger : colors.text;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.button),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Icon(icon, size: 20, color: danger ? colors.danger : colors.muted),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: danger ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
