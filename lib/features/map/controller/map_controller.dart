import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:teamxperience/model/team.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants/routes.dart';

class MyMapController{
  late Stream<List<Team>> teams;
  late BuildContext context;
  late String eventId;

  MyMapController({required this.context, required this.eventId,required this.teams});

  void navigateToChat(Team team) {
    Navigator.pushNamed(
      context,
      Routes.chatScreen,
      arguments: {
        'eventId': eventId,
        'team': team,
      },
    );
  }

  Future<void> callTeam(Team team) async {
    final phoneNumber = team.phoneNumber;

    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No phone number available for this team'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Format phone number for calling (remove spaces, dashes, etc.)
    final cleanPhoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri phoneUri = Uri(scheme: 'tel', path: cleanPhoneNumber);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open phone dialer'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening dialer: ${e.toString()}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}