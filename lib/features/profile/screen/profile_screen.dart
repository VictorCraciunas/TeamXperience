import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/features/profile/controller/profile_controller.dart';
import 'package:teamxperience/features/profile/widgets/profile_view.dart';
import 'package:teamxperience/state_management/user_provider.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().currentUser;
    final name =
        user == null ? '' : '${user.firstName} ${user.lastName}'.trim();

    return Scaffold(
      backgroundColor: context.colors.page,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ProfileView(
            name: name,
            email: user?.email ?? '',
            onLogout: () => ProfileController(context).logout(),
          ),
        ),
      ),
    );
  }
}
