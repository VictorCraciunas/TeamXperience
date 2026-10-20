import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/ui/components/buttons/app_button.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: context.colors.page,
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
                decoration: BoxDecoration(
                  color: context.colors.panel,
                  borderRadius: BorderRadius.circular(AppRadius.panel),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20.0),
                    Text(
                      "Bine ai venit!",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: context.colors.text,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: AppButton(
                        label: "Loghează-te",
                        onPressed: () {
                          Navigator.pushNamed(context, Routes.login);
                        },
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Nu ai cont?",
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 5.0),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, Routes.register);
                          },
                          child: Text(
                            "Inregistrează-te",
                            style: TextStyle(
                              fontSize: 14,
                              color: context.colors.accent,
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
