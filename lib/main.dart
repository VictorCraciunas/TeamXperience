import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/screen/add_missions_screen.dart';
import 'package:teamxperience/features/admin/home/screen/admin_home.dart';
import 'package:teamxperience/features/event_details/screen/event_details_screen.dart';
import 'package:teamxperience/features/event_game/screen/event_game_screen.dart';
import 'package:teamxperience/features/event_game/screen/puzzle_game_screen.dart';
import 'package:teamxperience/features/events_dashboard/events_dasboard.dart';
import 'package:teamxperience/features/filter/screen/filter_screen.dart';
import 'package:teamxperience/features/forgot-password/screen/forgot_password_screen.dart';
import 'package:teamxperience/features/sign-up/screen/register.dart';
import 'package:teamxperience/features/splash/splash.dart';
import 'package:teamxperience/utils/auth_util.dart';
import 'package:teamxperience/constants/routes.dart';
import 'backend/authentication/AuthenticationRepository.dart';
import 'backend/repo/user_repo.dart';
import 'features/admin/create_event/create_event_landing/screen/create_event_screen.dart';
import 'features/home/screen/home.dart';
import 'features/loader_page/landing_page.dart';
import 'features/log-in/screen/log_in_screen.dart';
import 'features/sign-up/screen/sign_up.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
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
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: Colors.white,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.white,      // makes Scaffold background white
        canvasColor: Colors.white,
      ),
      title: 'Treasure Hunt',
      initialRoute: Routes.redirect,
      routes: {
        Routes.redirect:     (_) => LandingPage(authUtil: authUtil),
        Routes.register:    (_) => const Register(),
        Routes.signup: (_) => const RegisterScreen(),
        Routes.login:       (_) => const LogInScreen(),
        Routes.home:        (_) => const Home(),
        Routes.createEvent: (_) => const CreateEventPage(),
        Routes.addMissions: (_) => const AddMissionsPage(),
        Routes.adminHome:   (_) => const AdminHome(),
        Routes.splash: (_) => const SplashScreen(),
        Routes.forgotPassword: (_) => const ForgotPasswordScreen(),
        Routes.eventDetails: (_) => const EventDetailsScreen(),
        Routes.eventGame: (_) => const EventGameScreen(),
        Routes.puzzleGame: (_) => const PuzzleGameScreen(),
        Routes.eventDashboard: (_) => const EventsDashboard(),
        Routes.filter: (_) => const FilterScreen()

      },
    );
  }
  }