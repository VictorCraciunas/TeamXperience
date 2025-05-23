import 'package:flutter/material.dart';

import '../../../backend/authentication/AuthenticationRepository.dart';
import '../../../constants/colors.dart';
import '../../../constants/routes.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    AuthenticationRepository authenticationRepository =
    AuthenticationRepository();
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: AppBar(
        title: Text("User Home Page"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: ElevatedButton(onPressed: () {
                authenticationRepository.logout();
                Navigator.pushNamedAndRemoveUntil(
                  context, Routes.splash, (Route<dynamic> route) => false);
              }, child: Text("Log Out")),
            )
          ],
        ),
      ),
    );
  }
}
