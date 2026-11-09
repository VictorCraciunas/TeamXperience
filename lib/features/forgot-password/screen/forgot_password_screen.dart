import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/misc/app_svg_icon.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:teamxperience/features/forgot-password/controller/forgot_password_controller.dart';

import 'package:teamxperience/ui/components/navigation/my_appbar.dart';
import 'package:teamxperience/ui/components/buttons/app_button.dart';
import 'package:teamxperience/ui/components/inputs/app_text_field.dart';

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
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Introdu email-ul și noi îți vom trimite un link pentru resetarea parolei',
                style: TextStyle(fontSize: 18, color: context.colors.muted),
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: controller.emailController,
                label: "Adresa de email",
                hint: 'exemplu@gmail.com',
                leading: AppSvgIcon(
                  'assets/images/email.svg',
                  width: 24,
                  height: 24,
                  color: context.colors.accent,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Te rugăm să introduci adresa de email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              AppButton(
                label: "Reseteaza parola",
                onPressed: () => controller.resetPassword(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
