import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';

import '../../../constants/colors.dart';
import '../../../widgets/my_text_field.dart';

class Step1 extends StatelessWidget {
  final numeEchipaController;
  final componentaEchipeiController;
  const Step1({super.key, required this.numeEchipaController, required this.componentaEchipeiController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MyTextField(
          controller: numeEchipaController,
          labelText: 'Nume echipa *',
          hintText: 'Nume echipa',
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: SvgPicture.asset(
              'assets/images/user_icon.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(MyColors.yellow, BlendMode.srcIn),
            ),
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
            child: SvgPicture.asset(
              'assets/images/user-group.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(MyColors.yellow, BlendMode.srcIn),
            ),
          ),
          maxLines: null,
          keyboardType: TextInputType.multiline,
          // ← close SvgPicture.asset
        ),

      ],
    );
  }
}