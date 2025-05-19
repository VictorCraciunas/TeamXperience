import 'package:flutter/material.dart';
import 'package:teamxperience/features/sign-up/controller/signup_controller.dart';

import '../../../widgets/my_text_field.dart';


class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});


  @override
  Widget build(BuildContext context) {
    SignUpController signUpController = SignUpController();
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child:Column(
          children: [
            /// Title
            const Text(
              "Sign Up",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            /// Email Field
            myTextField(signUpController.emailController, "Email", Icons.email,
                false, TextInputType.emailAddress),
            const SizedBox(height: 16),

            /// Password Field
            myTextField(signUpController.passwordController, "Password",
                Icons.lock, true),
            const SizedBox(height: 30),

            /// Sign Up Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => signUpController.register(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("Sign Up", style: TextStyle(fontSize: 18)),
              ),
            ),

            ElevatedButton(
                onPressed: () {
                  signUpController.logInGoogle(context);
                },
                child: const Text("Sign in with google")),
            ElevatedButton(
                onPressed: () {

                },
                child: const Text("Sign in with facebook")),
          ],
        ),
      ),
    );
  }
}
