import 'package:flutter/material.dart';
import 'package:teamxperience/features/log-in/controller/log_in_controller.dart';
import 'package:teamxperience/widgets/my_button.dart';

import '../../../widgets/my_text_field.dart';

class LogInScreen extends StatelessWidget {
  const LogInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    LogInController logInController = LogInController();

    return Scaffold(
      appBar: AppBar(title: const Text(
        "Logare",
        style: TextStyle(fontSize: 24, fontFamily: 'Poppins', fontWeight: FontWeight.w500),
      ), centerTitle: true),
      body: SingleChildScrollView(
        child: Form(
          key: logInController.formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
                myTextField(
                  logInController.emailController,
                  "Email",
                  Icons.email,
                  false,
                  TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                /// Password Field
                myTextField(
                  logInController.passwordController,
                  "Password",
                  Icons.lock,
                  true,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => logInController.login(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Log In", style: TextStyle(fontSize: 18)),
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      logInController.logInGoogle(context);
                    },
                    child: const Text("Sign in with google")),
                ElevatedButton(
                  onPressed: () {
                    logInController.goToSignUp(context);
                  },
                  child: Text("Create account"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
