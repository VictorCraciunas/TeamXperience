import 'package:flutter/material.dart';
import 'package:teamxperience/features/log-in/service/log_in_service.dart';
import 'package:teamxperience/constants/routes.dart';
class LogInController {

  final LogInService logInService = LogInService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();


  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }


  Future<void> login(BuildContext context) async {
    if (formKey.currentState!.validate()) {

      try {
        await logInService.logIn(
            emailController.text.trim(), passwordController.text.trim());


        if (!context.mounted) return;
        // dispose();
        Navigator.pushReplacementNamed(context, Routes.redirect);
      }
       catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }
  Future<void> logInGoogle(BuildContext context) async {
      try{
        await logInService.logInGoogle();
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Log in successfully!')),
        );

        dispose();
        Navigator.pushReplacementNamed(context, Routes.redirect);
      }
      catch(e){
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
  }


}
