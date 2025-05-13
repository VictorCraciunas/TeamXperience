import 'package:flutter/material.dart';

Widget myTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    bool obscureText, [
      TextInputType keyboardType = TextInputType.text,
    ]) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    obscureText: obscureText,
    validator: (value) => value!.isEmpty ? "Enter $label" : null,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}