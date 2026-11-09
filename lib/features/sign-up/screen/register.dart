import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:flutter_svg/svg.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/features/sign-up/controller/signup_controller.dart';
import 'package:teamxperience/ui/components/buttons/app_button.dart';
import 'package:teamxperience/ui/components/misc/terms_text.dart';

import 'package:teamxperience/ui/components/navigation/my_appbar.dart';

class Register extends StatelessWidget {
  const Register({super.key});

  @override
  Widget build(BuildContext context) {
    SignUpController controller = SignUpController();

    return Scaffold(
      backgroundColor: context.colors.page,
      appBar: const MyAppBar(appBarText: "Inregistrare"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              AppButton(
                label: 'Inregistrare cu Email',
                onPressed: () => Navigator.pushNamed(context, Routes.signup),
                leading: SvgPicture.asset(
                  'assets/images/email_white.svg',
                  width: 24,
                  height: 24,
                ),
              ),
              const SizedBox(height: 15),
              AppButton(
                label: "Inregistrare cu Google",
                onPressed: () => controller.signInGoogle(context),
                leading: SvgPicture.asset(
                  'assets/images/google.svg',
                  width: 24,
                  height: 24,
                ),
                variant: AppButtonVariant.secondary,
              ),
              const SizedBox(height: 15),
              AppButton(
                label: "Inregistrare cu Facebook",
                onPressed: () {},
                leading: SvgPicture.asset(
                  'assets/images/facebook.svg',
                  width: 24,
                  height: 24,
                ),
                backgroundColor: const Color(0xFF0056B2),
                foregroundColor: Colors.white,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Ai deja un cont?",
                      style: TextStyle(
                        fontSize: 16,
                        color: context.colors.muted,
                      ),
                    ),
                    const SizedBox(width: 5.0),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, Routes.login);
                      },
                      child: Text(
                        "Logheaza-te",
                        style: TextStyle(
                          fontSize: 16,
                          color: context.colors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const TermsText(),
            ],
          ),
        ),
      ),
    );
  }
}
