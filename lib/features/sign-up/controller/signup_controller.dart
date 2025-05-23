import 'package:flutter/material.dart';
import 'package:teamxperience/constants/routes.dart';
import '../service/signup_service.dart';

class SignUpController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  SignUpService signUpService = SignUpService();




  Future<void> register(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      try{
        await signUpService.register(emailController.text.trim(), firstNameController.text.trim(), lastNameController.text.trim(),passwordController.text.trim(), context);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully!')),
        );

        // dispose();
        Navigator.pushReplacementNamed(context, Routes.redirect);
      }
      catch(e){
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> signInGoogle(BuildContext context) async {
      try{
        await signUpService.signInGoogle();
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign in successfully!')),
        );

        Navigator.pushReplacementNamed(context, Routes.redirect);
      }
      catch(e){
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
  }

}
