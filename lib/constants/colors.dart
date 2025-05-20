import 'package:flutter/material.dart';

class MyColors{
  static const lightBlue = Color(0xFF53C4C7);
  static const facebookBlue = Color(0xFF0056B2);
  static const yellow = Color(0xFFF6AF1A);
  static const myGradient =  LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      lightBlue,
      Color(0xFF222F62),
    ],
    stops: [0.0, 1.0],
    tileMode: TileMode.clamp,
  );
}