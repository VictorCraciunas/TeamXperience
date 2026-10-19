import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:teamxperience/features/sign-up/controller/signup_controller.dart';

import '../../../constants/colors.dart';
import '../../../constants/padding.dart';
import '../../../constants/routes.dart';
import 'package:teamxperience/ui/components/navigation/my_appbar.dart';
import 'package:teamxperience/ui/components/buttons/my_button.dart';
import 'package:teamxperience/ui/components/inputs/my_text_field.dart';
import '../../../widgets/terms_text.dart';


class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});


  @override
  Widget build(BuildContext context) {
    SignUpController controller = SignUpController();

    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
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
                  borderColor: const Color(0xFFE6E6E6),
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
                  borderColor: const Color(0xFFE6E6E6),
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
                  borderColor: const Color(0xFFE6E6E6),
                  hintText: 'Confirmă parola',
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
                    const Text(
                      "Ai deja un cont?",
                      style: TextStyle(fontSize: 14, fontFamily: 'Poppins', color: MyColors.greyText),
                    ),
                    const SizedBox(width: 5.0),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          Routes.login,
                        );
                      },
                      child: const Text(
                        "Loghează-te",
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          color: MyColors.yellow,
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
