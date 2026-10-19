import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/ui/components/buttons/my_button.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/images/splash_background.svg',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/images/logo.png',
                  width: screenWidth * 0.8,
                  height: screenHeight * 0.60,
                  fit: BoxFit.contain,
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20.0),
                    const Text(
                      "Bine ai venit!",
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF001833),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: MyButton(
                        buttonText: "Loghează-te",
                        buttonOnTap: () {
                          Navigator.pushNamed(context, Routes.login);
                        },
                        gradient: MyColors.myGradient,
                        textColor: Colors.white,
                        withBorder: false,
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Nu ai cont?",
                          style: TextStyle(fontSize: 14, fontFamily: 'Poppins'),
                        ),
                        const SizedBox(width: 5.0),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              Routes.register,
                            );
                          },
                          child: const Text(
                            "Inregistrează-te",
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              color: MyColors.lightBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25.0),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
