import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/misc/app_svg_icon.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:flutter_svg/svg.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/features/log-in/controller/log_in_controller.dart';
import 'package:teamxperience/ui/components/buttons/app_button.dart';
import 'package:teamxperience/ui/components/misc/terms_text.dart';
import 'package:teamxperience/ui/components/misc/tap_area.dart';

import 'package:teamxperience/ui/components/navigation/my_appbar.dart';
import 'package:teamxperience/ui/components/inputs/app_text_field.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  // Kept across rebuilds, so what is typed (and the remembered email) stays.
  final LogInController controller = LogInController();

  @override
  void initState() {
    super.initState();
    controller.prefillEmail();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.page,
      appBar: const MyAppBar(appBarText: "Logare"),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Form(
            key: controller.formKey,
            // The email and password belong together for the phone's password
            // manager. Only a successful log-in saves them (the controller
            // finishes the context); leaving the screen discards them.
            child: AutofillGroup(
              onDisposeAction: AutofillContextAction.cancel,
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  AppButton(
                    label: "Logare cu Google",
                    onPressed: () => controller.logInGoogle(context),
                    leading: SvgPicture.asset(
                      'assets/images/google.svg',
                      width: 24,
                      height: 24,
                    ),
                    variant: AppButtonVariant.secondary,
                  ),
                  const SizedBox(height: 15),
                  AppButton(
                    label: "Logare cu Facebook",
                    onPressed: () {},
                    leading: SvgPicture.asset(
                      'assets/images/facebook.svg',
                      width: 24,
                      height: 24,
                    ),
                    backgroundColor: const Color(0xFF0056B2),
                    foregroundColor: Colors.white,
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: context.colors.border,
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          'SAU',
                          style: TextStyle(
                            color: context.colors.muted,
                            fontSize: 18,
                          ),
                        ),
                      ),

                      Expanded(
                        child: Divider(
                          color: context.colors.border,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

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
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    controller: controller.passwordController,
                    label: "Parola",
                    hint: 'Parola ta',
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
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
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    label: "Logheaza-te",
                    onPressed: () async {
                      await controller.login(context);
                    },
                  ),
                  // A 44 px tap area; the gaps around it give back the extra.
                  const SizedBox(height: 12),
                  TapArea(
                    minSize: 44,
                    onTap: () {
                      Navigator.pushNamed(context, Routes.forgotPassword);
                    },
                    child: Text(
                      "Ai uitat parola?",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: context.colors.accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
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
