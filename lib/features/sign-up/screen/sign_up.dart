import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../widgets/my_text_field.dart';
import '../controller/signup_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final SignUpController _signUpController = SignUpController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Account"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _signUpController.isLoading
            ? Center(
                child:
                    Lottie.asset('assets/loader/loader.json', width: 700, height: 700),
              ) //  Loader
            : buildForm(context),
      ),
    );
  }

  Form buildForm(BuildContext context) {
    return Form(
      key: _signUpController.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title
          const Text(
            "Sign Up",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          /// Name Field
          myTextField(
              _signUpController.nameController, "Name", Icons.person, false),
          const SizedBox(height: 16),

          /// Email Field
          myTextField(_signUpController.emailController, "Email", Icons.email,
              false, TextInputType.emailAddress),
          const SizedBox(height: 16),

          /// Password Field
          myTextField(_signUpController.passwordController, "Password",
              Icons.lock, true),
          const SizedBox(height: 30),

          /// Sign Up Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _signUpController.register(context, () {
                setState(() {
                  _signUpController.isLoading = !_signUpController.isLoading;
                });
              }),
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
                _signUpController.logInGoogle(context, () {
                  setState(() {
                    _signUpController.isLoading = !_signUpController.isLoading;
                  });
                });
              },
              child: const Text("Sign in with google")),
          ElevatedButton(
              onPressed: () {

              },
              child: const Text("Sign in with facebook")),
        ],
      ),
    );
  }
}
