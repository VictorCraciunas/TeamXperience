import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/misc/app_svg_icon.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:teamxperience/features/sign-up/controller/signup_controller.dart';

import '../../../constants/colors.dart';
import '../../../constants/padding.dart';
import '../../../constants/routes.dart';
import 'package:teamxperience/ui/components/navigation/my_appbar.dart';
import 'package:teamxperience/ui/components/buttons/my_button.dart';
import 'package:teamxperience/ui/components/inputs/my_text_field.dart';
import 'package:teamxperience/ui/components/misc/terms_text.dart';


class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});


  @override
  Widget build(BuildContext context) {
    SignUpController controller = SignUpController();

    return Scaffold(
      backgroundColor: context.colors.page,
      appBar: const MyAppBar(appBarText: "Inregistrare"),
      body: SingleChildScrollView(
        child:Padding(
          padding: const EdgeInsets.symmetric(horizontal: MyPaddings.appHorizontalPadding),
          child: Form(
            key: controller.formKey,
            child: Column(
              children: [
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
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Te rugăm să introduci un email valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                MyTextField(
                  controller: controller.firstNameController,
                  labelText: "Prenume",
                  labelFontSize: 14,
                  hintText: 'Prenume',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Te rugăm să introduci prenumele';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                MyTextField(
                  controller: controller.lastNameController,
                  labelText: "Nume de familie",
                  labelFontSize: 14,
                  hintText: 'Nume de familie',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Te rugăm să introduci numele de familie';
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
                    if (value.length < 6) {
                      return 'Parola trebuie să aibă cel puțin 6 caractere';
                    }
                    if (value != controller.confirmPasswordController.text) {
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                MyTextField(
                  controller: controller.confirmPasswordController,
                  labelText: "Confirmă parola",
                  labelFontSize: 14,
                  hintText: 'Confirmă parola',
                  leading: AppSvgIcon('assets/images/pass.svg', width: 24, height: 24, color: context.colors.accent),
                  obscureText: true,
                  trailing: AppSvgIcon('assets/images/show_pass.svg', width: 24, height: 24, color: context.colors.muted),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Te rugăm să confirmi parola';
                    }
                    if (value != controller.passwordController.text) {
                      return 'Parolele nu se potrivesc';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                MyButton(
                  buttonText: "Crează cont",
                  textColor: Colors.white,
                  buttonOnTap: () async {
                    await controller.register(context);
                  },
                  withBorder: false,
                  buttonColor: MyColors.yellow,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Ai deja un cont?",
                      style: TextStyle(fontSize: 14, color: context.colors.muted),
                    ),
                    const SizedBox(width: 5.0),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          Routes.login,
                        );
                      },
                      child: Text(
                        "Loghează-te",
                        style: TextStyle(
                          fontSize: 14,
                          color: context.colors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const TermsText()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
