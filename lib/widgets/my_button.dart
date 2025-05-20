import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String buttonText;
  final Color? buttonColor;
  final LinearGradient? gradient;
  final Function() buttonOnTap;

  const MyButton({
    super.key,
    required this.buttonText,
    required this.buttonOnTap,
    this.buttonColor,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: buttonOnTap,
      child: Container(
        width: double.infinity,
        height: 57,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(50)),
          color: buttonColor,
          gradient: gradient,
        ),
        child: Center(child: Text(buttonText,style: TextStyle(color: Colors.white,fontSize: 16,fontFamily: 'Poppins',fontWeight: FontWeight.w500),)),
      ),
    );
  }
}
