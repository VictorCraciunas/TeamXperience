import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/features/log-in/controller/log_in_controller.dart';
import 'package:teamxperience/ui/components/buttons/my_button.dart';
import 'package:teamxperience/ui/components/misc/terms_text.dart';

import '../../../constants/padding.dart';
import 'package:teamxperience/ui/components/navigation/my_appbar.dart';
import 'package:teamxperience/ui/components/inputs/my_text_field.dart';

class LogInScreen extends StatelessWidget {
  const LogInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    LogInController controller = LogInController();

    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: const MyAppBar(appBarText: "Logare"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: MyPaddings.appHorizontalPadding),
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
                      child: Divider(color: Colors.grey.shade300, thickness: 1),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        'SAU',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: MyColors.greyText,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    Expanded(
                      child: Divider(color: Colors.grey.shade300, thickness: 1),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                MyTextField(
                  controller: controller.emailController,
                  labelText: "Adresa de email",
                  labelFontSize: 14,
                  borderColor: const Color(0xFFE6E6E6),
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
                MyTextField(
                  controller: controller.passwordController,
                  labelText: "Parola",
                  labelFontSize: 14,
                  borderColor: const Color(0xFFE6E6E6),
                  hintText: 'Parola ta',
                  leading: SvgPicture.asset(
                    'assets/images/pass.svg',
                    height: 24,
                    width: 24,
                  ),
                  obscureText: true,
                  trailing: SvgPicture.asset(
                    'assets/images/show_pass.svg',
                    height: 24,
                    width: 24,
                  ),
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
                  child: const Text(
                    "Ai uitat parola?",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      color: MyColors.yellow,
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


