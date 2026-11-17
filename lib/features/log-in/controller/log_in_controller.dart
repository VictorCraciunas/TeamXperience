import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:teamxperience/features/log-in/service/log_in_service.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/service/last_email_store.dart';
class LogInController {

  // Made on first use, so the screen can be drawn without Firebase (tests).
  late final LogInService logInService = LogInService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();



  /// Starts the form with the email last signed in on this phone (saved at
  /// log-in and at logout), unless something is typed already.
  Future<void> prefillEmail() async {
    final email = await LastEmailStore().read();
    if (email != null && emailController.text.isEmpty) emailController.text = email;
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }

  Future<void> login(BuildContext context) async {
    if (formKey.currentState!.validate()) {

      try {
        await logInService.logIn(
            emailController.text.trim(), passwordController.text.trim());

        // The password manager offers to save the email and password.
        TextInput.finishAutofillContext();
        await LastEmailStore().save(emailController.text);
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

        Navigator.pushReplacementNamed(context, Routes.redirect);
      }
      catch(e){
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
  }


}
