import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class TermsText extends StatelessWidget {
  const TermsText({super.key});

  @override
  Widget build(BuildContext context) {
    final baseStyle = TextStyle(
      color: Colors.grey.shade600,
      fontSize: 14,
      fontFamily: 'Poppins',
    );
    final linkStyle = baseStyle.copyWith(color: Colors.black);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30.0,),
      child: Text.rich(
        TextSpan(
          style: baseStyle,
          children: [
            const TextSpan(text: 'Prin continuare, ești de acord cu '),
            TextSpan(
              text: 'Termenii și Condițiile',
              style: linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  // TODO: navigate to terms page
                },
            ),
            const TextSpan(text: ' și cu '),
            TextSpan(
              text: 'Politica de confidențialitate',
              style: linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  // TODO: navigate to privacy policy
                },
            ),
            const TextSpan(text: '.'),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
