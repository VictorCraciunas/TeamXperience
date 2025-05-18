import 'package:flutter/material.dart';
import 'package:teamxperience/constants/routes.dart';
import '../service/signup_service.dart';

class SignUpController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  SignUpService signUpService = SignUpService();

  bool isLoading = false;

  Future<void> register(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      try{
        await signUpService.register(emailController.text.trim(), passwordController.text.trim(), context);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully!')),
        );
        Navigator.pushReplacementNamed(context, Routes.redirect);
      }
      catch(e){
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> logInGoogle(BuildContext context) async {
      try{
        await signUpService.logInGoogle();
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Log in successfully!')),
        );
        Navigator.pushReplacementNamed(context, Routes.redirect);
      }
      catch(e){
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
  }

}
