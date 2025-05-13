import 'package:flutter/material.dart';
import '../service/signup_service.dart';

class SignUpController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  SignUpService signUpService = SignUpService();

  bool isLoading = false;

  Future<void> register(BuildContext context, VoidCallback updateUI) async {
    if (formKey.currentState!.validate()) {
      updateUI();
      try{
        await signUpService.register(nameController.text.trim(),emailController.text.trim(), passwordController.text.trim(), context);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully!')),
        );
        Navigator.pushReplacementNamed(context, '/home');
      }
      catch(e){
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
      updateUI();
    }
  }

  Future<void> logInGoogle(BuildContext context, VoidCallback updateUI) async {
    if (formKey.currentState!.validate()) {
      updateUI();
      try{
        await signUpService.logInGoogle();
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Log in successfully!')),
        );
        Navigator.pushReplacementNamed(context, '/home');
      }
      catch(e){
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
      updateUI();
    }
  }

}
