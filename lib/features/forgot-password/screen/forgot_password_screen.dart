import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/features/forgot-password/controller/forgot_password_controller.dart';

import '../../../widgets/my_appbar.dart';
import '../../../widgets/my_button.dart';
import '../../../widgets/my_text_field.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ForgotPasswordController controller = ForgotPasswordController();

    return Scaffold(
      appBar: MyAppBar(appBarText: "Resetare parola"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Introdu email-ul si noi iti vom trimite un link pentru resetarea parolei',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  color: MyColors.greyText,
                ),
              ),
              SizedBox(height: 20),
              MyTextField(
                controller: controller.emailController,
                labelText: "Adresa de email",
                labelFontSize: 14,
                borderColor: Color(0xFFE6E6E6),
                hintText: 'exemplu@gmail.com',
                leading: SvgPicture.asset(
                  'assets/images/email.svg',
                  height: 24,
                  width: 24,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Te rugăm să introduci adresa de email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              MyButton(
                buttonText: "Reseteaza parola",
                textColor: Colors.white,
                buttonOnTap: () => controller.resetPassword(context),
                withBorder: false,
                buttonColor: MyColors.yellow,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
