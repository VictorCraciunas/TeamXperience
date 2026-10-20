import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/misc/app_svg_icon.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:flutter_svg/svg.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/features/log-in/controller/log_in_controller.dart';
import 'package:teamxperience/ui/components/buttons/my_button.dart';
import 'package:teamxperience/ui/components/misc/terms_text.dart';

import 'package:teamxperience/ui/components/navigation/my_appbar.dart';
import 'package:teamxperience/ui/components/inputs/my_text_field.dart';

class LogInScreen extends StatelessWidget {
  const LogInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    LogInController controller = LogInController();

    return Scaffold(
      backgroundColor: context.colors.page,
      appBar: const MyAppBar(appBarText: "Logare"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Form(
            key: controller.formKey,
            child: Column(
              children: [
                const SizedBox(height: 50),
                MyButton(
                  buttonText: "Logare cu Google",
                  textColor: const Color(0xFF0C092A),
                  buttonOnTap: () => controller.logInGoogle(context),
                  leading: SvgPicture.asset(
                    'assets/images/google.svg',
                    width: 24,
                    height: 24,
                  ),
                  withBorder: true,
                ),
                const SizedBox(height: 15),
                MyButton(
                  buttonText: "Logare cu Facebook",
                  textColor: Colors.white,
                  buttonOnTap: () {},
                  withBorder: false,
                  buttonColor: const Color(0xFF0056B2),
                  leading: SvgPicture.asset(
                    'assets/images/facebook.svg',
                    width: 24,
                    height: 24,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: context.colors.border, thickness: 1),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        'SAU',
                        style: TextStyle(
                          color: context.colors.muted,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    Expanded(
                      child: Divider(color: context.colors.border, thickness: 1),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

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
                MyTextField(
                  controller: controller.passwordController,
                  labelText: "Parola",
                  labelFontSize: 14,
                  hintText: 'Parola ta',
                  leading: AppSvgIcon('assets/images/pass.svg', width: 24, height: 24, color: context.colors.accent),
                  obscureText: true,
                  trailing: AppSvgIcon('assets/images/show_pass.svg', width: 24, height: 24, color: context.colors.muted),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Te rugăm să introduci parola';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                MyButton(
                  buttonText: "Logheaza-te",
                  textColor: Colors.white,
                  buttonOnTap: () async {
                    await controller.login(context);
                  },
                  withBorder: false,
                  buttonColor: MyColors.yellow,
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, Routes.forgotPassword);
                  },
                  child: Text(
                    "Ai uitat parola?",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: context.colors.accent,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const TermsText(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


