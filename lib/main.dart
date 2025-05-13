import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/screen/add_missions_screen.dart';
import 'package:teamxperience/utils/auth_util.dart';
import 'backend/authentication/AuthenticationRepository.dart';
import 'backend/repo/user_repo.dart';
import 'features/admin/create_event/create_event_landing/screen/create_event_screen.dart';
import 'features/home/screen/home.dart';
import 'features/landing-page/landing_page.dart';
import 'features/sign-up/screen/sign_up.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final userRepo = UserRepo();
    final authenticationRepository = AuthenticationRepository();
    final AuthUtil authUtil = AuthUtil(userRepo,authenticationRepository);

    return MaterialApp(
      title: 'Treasure Hunt',
      initialRoute: '/landing',
      routes: {
        '/landing': (context) => LandingPage(authUtil: authUtil),
        '/register_screen': (context) => const RegisterScreen(),
        '/home':(context) => const Home(),
        '/create_event':(context) =>  CreateEventPage(),
        '/add_missions':(context) => AddMissionsPage()
      },
    );
  }
  }