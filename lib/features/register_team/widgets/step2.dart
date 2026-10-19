
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';

import '../../../constants/colors.dart';
import 'package:teamxperience/ui/components/inputs/my_text_field.dart';

class Step2 extends StatelessWidget {
  final numeCapitanController ;
  final numarDeTelefonController;
  final emailCapitanController ;
  const Step2({super.key, required this.numeCapitanController, required this.numarDeTelefonController, required this.emailCapitanController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MyTextField(
          controller: numeCapitanController,
          labelText: 'Nume căpitan *',
          hintText: 'Nume ',
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: SvgPicture.asset(
              'assets/images/user.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(MyColors.yellow, BlendMode.srcIn),
            ),
          ), // ← close SvgPicture.asset
        ),
        const SizedBox(height: 20),
        MyTextField(
          controller: numarDeTelefonController,
          labelText: 'Număr de telefon & Whatsapp căpitan *',
          hintText: '0712 456 789',
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: SvgPicture.asset(
              'assets/images/user_icon.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(MyColors.yellow, BlendMode.srcIn),
            ),
          ), // ← close SvgPicture.asset
        ),
        const SizedBox(height: 20),
        MyTextField(
          controller: emailCapitanController,
          labelText: 'Email căpitan *',
          hintText: 'exemplu@gmail.com',
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: SvgPicture.asset(
              'assets/images/user_icon.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(MyColors.yellow, BlendMode.srcIn),
            ),
          ), // ← close SvgPicture.asset
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}