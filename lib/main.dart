import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart'; // Add this import
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/screen/add_missions_screen.dart';
import 'package:teamxperience/features/admin/create_news/screen/create_news_screen.dart';
import 'package:teamxperience/features/admin/home/screen/admin_home.dart';
import 'package:teamxperience/features/calendar/screen/calendar_screen.dart';
import 'package:teamxperience/features/event_details/screen/event_details_screen.dart';
import 'package:teamxperience/features/event_game/screen/event_game_screen.dart';
import 'package:teamxperience/features/event_game/screen/puzzle_game_screen.dart';
import 'package:teamxperience/features/filter/filter_news/screen/filter_news.dart';
import 'package:teamxperience/features/forgot-password/screen/forgot_password_screen.dart';
import 'package:teamxperience/features/news_category_manipulation/screen/news_catergory_manipulation_screen.dart';
import 'package:teamxperience/features/news_dashboard/screen/stiri_dashboard_screen.dart';
import 'package:teamxperience/features/news_details/news_screen.dart';
import 'package:teamxperience/features/register_team/screen/register_team_screen.dart';
import 'package:teamxperience/features/sign-up/screen/register.dart';
import 'package:teamxperience/features/splash/splash.dart';
import 'package:teamxperience/service/news_service/news_service.dart';
import 'package:teamxperience/state_management/events_state_management.dart';
import 'package:teamxperience/state_management/news_state_management.dart';
import 'package:teamxperience/state_management/user_provider.dart';
import 'package:teamxperience/utils/auth_util.dart';
import 'package:teamxperience/constants/routes.dart';
import 'backend/authentication/AuthenticationRepository.dart';
import 'backend/repo/user_repo.dart';
import 'features/admin/create_event/create_event_landing/screen/create_event_screen.dart';
import 'features/events_dashboard/events_dashboard_admin/screen/events_dasboard_screen.dart';
import 'features/events_dashboard/events_dashboard_user/screen/events_dashboard_screen.dart';
import 'features/filter/filter_events/screen/filter_events_screen.dart';
import 'features/home/screen/home.dart';
import 'features/loader_page/landing_page.dart';
import 'features/log-in/screen/log_in_screen.dart';
import 'features/sign-up/screen/sign_up.dart';
import 'firebase_options.dart';

// Add these imports for your services and state management
import 'package:teamxperience/service/event_service/event_service.dart';

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
    // Wrap MaterialApp with MultiProvider
    return MultiProvider(
      providers: [
        // User authentication provider (should be first)
        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider(),
        ),

        // Core services (no state management)
        Provider<UserRepo>(
          create: (_) => UserRepo(),
        ),

        Provider<AuthenticationRepository>(
          create: (_) => AuthenticationRepository(),
        ),

        // AuthUtil with dependencies
        Provider<AuthUtil>(
          create: (context) => AuthUtil(
            Provider.of<UserRepo>(context, listen: false),
            Provider.of<AuthenticationRepository>(context, listen: false),
            Provider.of<UserProvider>(context, listen: false),
          ),
        ),

        Provider<EventService>(
          create: (_) => EventService(),
        ),

        Provider<NewsService>(
          create: (_) => NewsService(),
        ),

        // State management providers
        ChangeNotifierProvider<EventList>(
          create: (context) => EventList(
            Provider.of<EventService>(context, listen: false),
          ),
        ),

        ChangeNotifierProvider<NewsList>(
          create: (context) => NewsList(
            Provider.of<NewsService>(context, listen: false),
          ),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          primaryColor: Colors.white,
          fontFamily: 'Poppins',
          scaffoldBackgroundColor: Colors.white,
          canvasColor: Colors.white,
        ),
        title: 'Treasure Hunt',
        initialRoute: Routes.redirect,
        routes: {
          Routes.redirect: (_) => Consumer<AuthUtil>(
            builder: (context, authUtil, child) => LandingPage(authUtil: authUtil),
          ),
          Routes.register: (_) => const Register(),
          Routes.signup: (_) => const RegisterScreen(),
          Routes.login: (_) => const LogInScreen(),
          Routes.home: (_) => const Home(),
          Routes.createEvent: (_) => const CreateEventPage(),
          Routes.addMissions: (_) => const AddMissionsPage(),
          Routes.adminHome: (_) => const AdminHome(),
          Routes.splash: (_) => const SplashScreen(),
          Routes.forgotPassword: (_) => const ForgotPasswordScreen(),
          Routes.eventDetails: (_) => const EventDetailsScreen(),
          Routes.eventGame: (_) => const EventGameScreen(),
          Routes.puzzleGame: (_) => const PuzzleGameScreen(),
          Routes.eventDashboard: (_) => const EventsDashboard(),
          Routes.filter: (_) => const FilterEventsScreen(),
          Routes.createNews: (_) => const CreateStireScreen(),
          Routes.newsDetails: (_) => const NewsScreen(),
          Routes.newsDashboard: (_) => const StiriDashboard(),
          Routes.chooseNewsType: (_) => const NewsCategoryManipulationScreen(),
          Routes.filterStiri: (_) => const FilterStiriScreen(),
          Routes.calendar: (_) => const DateRangeSelectionScreen(),
          Routes.eventDashboardUser: (_) => const FilterEventsUser(),
          Routes.registerTeam: (_) => const RegisterTeamScreen(),
        },
      ),
    );
  }
}