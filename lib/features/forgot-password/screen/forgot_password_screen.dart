import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/misc/app_svg_icon.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/features/forgot-password/controller/forgot_password_controller.dart';

import '../../../constants/padding.dart';
import 'package:teamxperience/ui/components/navigation/my_appbar.dart';
import 'package:teamxperience/ui/components/buttons/my_button.dart';
import 'package:teamxperience/ui/components/inputs/my_text_field.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ForgotPasswordController controller = ForgotPasswordController();

    return Scaffold(
      backgroundColor: context.colors.page,
      appBar: const MyAppBar(appBarText: "Resetare parola"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: MyPaddings.appHorizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Introdu email-ul și noi îți vom trimite un link pentru resetarea parolei',
                style: TextStyle(
                  fontSize: 16,
                  color: context.colors.muted,
                ),
              ),
              const SizedBox(height: 20),
              MyTextField(
                controller: controller.emailController,
                labelText: "Adresa de email",
                labelFontSize: 14,
                hintText: 'exemplu@gmail.com',
                leading: AppSvgIcon('assets/images/email.svg', width: 24, height: 24, color: context.colors.accent),
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
