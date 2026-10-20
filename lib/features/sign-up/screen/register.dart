import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:flutter_svg/svg.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/features/sign-up/controller/signup_controller.dart';
import 'package:teamxperience/ui/components/buttons/my_button.dart';
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
              MyButton(
                buttonText: 'Inregistrare cu Email',
                textColor: Colors.white,
                buttonOnTap: () => Navigator.pushNamed(context,Routes.signup),
                withBorder: false,
                buttonColor: MyColors.yellow,
                leading: SvgPicture.asset(
                  'assets/images/email_white.svg',
                  width: 24,
                  height: 24,
                ),
              ),
              const SizedBox(height: 15,),
              MyButton(
                buttonText: "Inregistrare cu Google",
                textColor: const Color(0xFF0C092A),
                buttonOnTap: () => controller.signInGoogle(context),
                leading: SvgPicture.asset(
                  'assets/images/google.svg',
                  width: 24,
                  height: 24,
                ),
                withBorder: true,
              ),
              const SizedBox(height: 15,),
              MyButton(
                buttonText: "Inregistrare cu Facebook",
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
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
                        "Logheaza-te",
                        style: TextStyle(
                          fontSize: 14,
                          color: context.colors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const TermsText()
            ],
          ),
        ),
      ),
    );
  }
}
