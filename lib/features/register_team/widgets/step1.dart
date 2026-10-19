import 'package:flutter/cupertino.dart';
import 'package:teamxperience/ui/components/misc/app_svg_icon.dart';
import 'package:teamxperience/ui/ui.dart';

import 'package:teamxperience/ui/components/inputs/my_text_field.dart';

class Step1 extends StatelessWidget {
  final numeEchipaController;
  final componentaEchipeiController;
  final numarPersoaneController;
  const Step1({super.key, required this.numeEchipaController, required this.componentaEchipeiController, required this.numarPersoaneController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MyTextField(
          controller: numeEchipaController,
          labelText: 'Nume echipă *',
          hintText: 'Nume echipă',
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: AppSvgIcon('assets/images/user_icon.svg', width: 24, height: 24, color: context.colors.tick),
          ),
          // ← close SvgPicture.asset
        ),
        const SizedBox(height: 20),
        MyTextField(
          controller: componentaEchipeiController,
          labelText: 'Componenta echipei *',
          hintText: '1.  Nume prenume\n2. Nume Prenume ',
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: AppSvgIcon('assets/images/user-group.svg', width: 24, height: 24, color: context.colors.tick),
          ),
          maxLines: null,
          keyboardType: TextInputType.multiline,
          // ← close SvgPicture.asset
        ),
        const SizedBox(height: 20),
        MyTextField(
          controller: numarPersoaneController,
          labelText: 'Număr persoane *',
          hintText: 'Ex: 4',
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: AppSvgIcon('assets/images/user-group.svg', width: 24, height: 24, color: context.colors.tick),
          ),
          keyboardType: TextInputType.number,
        ),

      ],
    );
  }
}