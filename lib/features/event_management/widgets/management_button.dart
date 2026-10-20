import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/misc/app_svg_icon.dart';
import 'package:teamxperience/ui/components/buttons/app_button.dart';

class ManagementButton extends StatelessWidget {
  final String text;
  final String icon;
  final bool enabled;
  final VoidCallback onTap;

  const ManagementButton({
    super.key,
    required this.text,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: AppButton(
        label: text,
        onPressed: enabled ? onTap : () {},
        leading: AppSvgIcon(icon, width: 24, height: 24),
      ),
    );
  }
}
