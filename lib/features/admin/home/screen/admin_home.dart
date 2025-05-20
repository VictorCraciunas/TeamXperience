import 'package:flutter/material.dart';
import 'package:teamxperience/constants/routes.dart';

import '../../../../backend/authentication/AuthenticationRepository.dart';


class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    AuthenticationRepository authenticationRepository =
    AuthenticationRepository();

    return Scaffold(
      appBar: AppBar(
        title: Text("admin home page"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child:ElevatedButton(
                onPressed: () {
                  authenticationRepository.logout();
                  Navigator.pushNamedAndRemoveUntil(context, Routes.splash,(Route<dynamic> route) => false, );
                },
                child: const Text("Log out")),
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/create_event');
              },
              child: const Text("Create Event"))
        ],
      ),
    );
  }
}
