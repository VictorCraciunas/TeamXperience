import 'package:flutter/cupertino.dart';
import 'package:teamxperience/ui/components/misc/app_svg_icon.dart';
import 'package:teamxperience/ui/ui.dart';

import 'package:teamxperience/ui/components/inputs/app_text_field.dart';

class Step2 extends StatelessWidget {
  final numeCapitanController;
  final numarDeTelefonController;
  final emailCapitanController;
  const Step2({
    super.key,
    required this.numeCapitanController,
    required this.numarDeTelefonController,
    required this.emailCapitanController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppTextField(
          controller: numeCapitanController,
          label: 'Nume căpitan *',
          hint: 'Nume ',
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: AppSvgIcon(
              'assets/images/user.svg',
              width: 24,
              height: 24,
              color: context.colors.tick,
            ),
          ),
          validator: requiredValidator('Nume căpitan *'),
        ),
        const SizedBox(height: 20),
        AppTextField(
          controller: numarDeTelefonController,
          label: 'Număr de telefon & Whatsapp căpitan *',
          hint: '0712 456 789',
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: AppSvgIcon(
              'assets/images/user_icon.svg',
              width: 24,
              height: 24,
              color: context.colors.tick,
            ),
          ),
          validator: requiredValidator('Număr de telefon & Whatsapp căpitan *'),
        ),
        const SizedBox(height: 20),
        AppTextField(
          controller: emailCapitanController,
          label: 'Email căpitan *',
          hint: 'exemplu@gmail.com',
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: AppSvgIcon(
              'assets/images/user_icon.svg',
              width: 24,
              height: 24,
              color: context.colors.tick,
            ),
          ),
          validator: requiredValidator('Email căpitan *'),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
