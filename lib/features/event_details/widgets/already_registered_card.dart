import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:flutter_svg/svg.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/ui/components/buttons/app_button.dart';

class AlreadyRegisteredCard extends StatelessWidget {
  final Event event;
  final Function() onDetailsTap;

  const AlreadyRegisteredCard({
    super.key,
    required this.event,
    required this.onDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: const Color(0xFF0B2F63).withValues(alpha: 0.1),
      color: context.colors.panel,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Text(
              "Ți-ai înscris deja echipa la acest eveniment!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.colors.text,
              ),
            ),
            const SizedBox(height: 25),
            AppButton(
              label: "Detalii înscriere",
              onPressed: () => onDetailsTap(),
              leading: SvgPicture.asset(
                'assets/images/user_icon.svg',
                width: 19,
                height: 19,
                colorFilter: ColorFilter.mode(
                  context.colors.text,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
