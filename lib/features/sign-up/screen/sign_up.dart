import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/misc/app_svg_icon.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:teamxperience/features/sign-up/controller/signup_controller.dart';

import '../../../constants/routes.dart';
import 'package:teamxperience/ui/components/navigation/my_appbar.dart';
import 'package:teamxperience/ui/components/buttons/app_button.dart';
import 'package:teamxperience/ui/components/inputs/app_text_field.dart';
import 'package:teamxperience/ui/components/misc/terms_text.dart';
import 'package:teamxperience/ui/components/misc/tap_area.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SignUpController controller = SignUpController();

    return Scaffold(
      backgroundColor: context.colors.page,
      appBar: const MyAppBar(appBarText: "Inregistrare"),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Form(
            key: controller.formKey,
            // One new account for the phone's password manager. Only a
            // successful sign-up saves it (the controller finishes the
            // context); leaving the screen discards it.
            child: AutofillGroup(
              onDisposeAction: AutofillContextAction.cancel,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  AppTextField(
                    controller: controller.emailController,
                    label: "Adresa de email",
                    hint: 'exemplu@gmail.com',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
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
                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                      if (!emailRegex.hasMatch(value)) {
                        return 'Te rugăm să introduci un email valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    controller: controller.firstNameController,
                    label: "Prenume",
                    hint: 'Prenume',
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.givenName],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Te rugăm să introduci prenumele';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    controller: controller.lastNameController,
                    label: "Nume de familie",
                    hint: 'Nume de familie',
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.familyName],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Te rugăm să introduci numele de familie';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    controller: controller.passwordController,
                    label: "Parola",
                    hint: 'Parola ta',
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.newPassword],
                    leading: AppSvgIcon(
                      'assets/images/pass.svg',
                      width: 24,
                      height: 24,
                      color: context.colors.accent,
                    ),
                    obscure: true,
                    trailing: AppSvgIcon(
                      'assets/images/show_pass.svg',
                      width: 24,
                      height: 24,
                      color: context.colors.muted,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Te rugăm să introduci parola';
                      }
                      if (value.length < 6) {
                        return 'Parola trebuie să aibă cel puțin 6 caractere';
                      }
                      if (value != controller.confirmPasswordController.text) {}
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    controller: controller.confirmPasswordController,
                    label: "Confirmă parola",
                    hint: 'Confirmă parola',
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.newPassword],
                    leading: AppSvgIcon(
                      'assets/images/pass.svg',
                      width: 24,
                      height: 24,
                      color: context.colors.accent,
                    ),
                    obscure: true,
                    trailing: AppSvgIcon(
                      'assets/images/show_pass.svg',
                      width: 24,
                      height: 24,
                      color: context.colors.muted,
                    ),
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

                  AppButton(
                    label: "Crează cont",
                    onPressed: () async {
                      await controller.register(context);
                    },
                  ),
                  const SizedBox(height: 20),
                  // Wraps onto two lines on a narrow phone with large text.
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 5.0,
                    children: [
                      Text(
                        "Ai deja un cont?",
                        style: TextStyle(
                          fontSize: 16,
                          color: context.colors.muted,
                        ),
                      ),
                      TapArea(
                        minSize: 44,
                        onTap: () {
                          Navigator.pushNamed(context, Routes.login);
                        },
                        child: Text(
                          "Loghează-te",
                          style: TextStyle(
                            fontSize: 16,
                            color: context.colors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const TermsText(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
