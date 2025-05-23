import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../service/forgot_password_service.dart';

class ForgotPasswordController {
  final TextEditingController emailController = TextEditingController();
  ForgotPasswordService service = ForgotPasswordService();

  Future<void> resetPassword(BuildContext context) async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Te rugăm să introduci adresa de email.')),
      );
      return;
    }

    try {
      await service.sendLink(email);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verifică-ți emailul pentru link-ul de resetare.'),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'invalid-email':
          message = 'Adresa de email nu este validă.';
          break;
        case 'user-not-found':
          message = 'Nu am găsit niciun cont cu acest email.';
          break;
        default:
          message = 'A apărut o eroare. Încearcă din nou mai târziu.';
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }
}
