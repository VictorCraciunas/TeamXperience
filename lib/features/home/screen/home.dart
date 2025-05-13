import 'package:flutter/material.dart';

import '../../../backend/authentication/AuthenticationRepository.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    AuthenticationRepository authenticationRepository =
        AuthenticationRepository();
    return Column(
      children: [
        const Center(child: Text("Home")),
        ElevatedButton(
            onPressed: () {
              authenticationRepository.logout();
              Navigator.pushNamed(context, '/register_screen');

            },
            child: const Text("Log out"))
      ],
    );
  }
}
