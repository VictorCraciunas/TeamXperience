import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/service/team_service/team_service.dart';
import 'package:teamxperience/utils/snackbars.dart'; // Add this import

import '../../../constants/routes.dart';
import '../../../model/user.dart';
import '../../../state_management/user_provider.dart';

class RegisterTeamController {
  late BuildContext context;
  late Event event;

  RegisterTeamController(this.context, this.event);

  TeamService teamService = TeamService();
  bool secondStep = false;
  bool thirdStep = false;

  bool checkBox1 = false;
  bool checkBox2 = false;
  bool checkBox3 = false;

  final numeEchipaController = TextEditingController();
  final componentaEchipeiController = TextEditingController();
  final numarPersoaneController = TextEditingController();
  final numeCapitanController = TextEditingController();
  final numarDeTelefonController = TextEditingController();
  final emailCapitanController = TextEditingController();
  final GlobalKey<FormState> step1FormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> step2FormKey = GlobalKey<FormState>();

  void navigateToTeamDetails() {
    AppUser? user = Provider.of<UserProvider>(context, listen: false).currentUser;
    Navigator.pushReplacementNamed(
      context,
      Routes.registerTeamDetails,
      arguments: {
        'event': event,
        'user': user,
      },
    );
  }

  bool validateCurrentStep() {
    if (!secondStep && !thirdStep) {
      // Step 1
      return step1FormKey.currentState?.validate() ?? false;
    } else if (secondStep && !thirdStep) {
      // Step 2
      return step2FormKey.currentState?.validate() ?? false;
    } else {
      // Step 3 - validate checkboxes
      return validateStep3();
    }
  }

  bool validateStep3() {
    if (!checkBox1 || !checkBox2 || !checkBox3) {
      MySnackBars.errorSnackBar(
        context,
        title: 'Eroare',
        message: 'Toate acordurile sunt obligatorii',
      );
      return false;
    }
    return true;
  }

  void buttonOnTap() async{
    if (validateCurrentStep()) {
      if (!secondStep) {
        // Moving from step 1 to step 2
        secondStep = true;
      } else if (!thirdStep) {
        // Moving from step 2 to step 3
        thirdStep = true;
      } else {
        // Final step - submit form
        final user = Provider.of<UserProvider>(context, listen: false).currentUser;
        if (user != null) {
          await teamService.addTeam(
            numeEchipaController.text,
            componentaEchipeiController.text,
            numeCapitanController.text,
            numarDeTelefonController.text,
            emailCapitanController.text,
            int.tryParse(numarPersoaneController.text) ?? 0,
            user,
            event,
            context
          );
        }
        MySnackBars.successSnackBar(context, title: "Succes", message: "Ai inregistrat echipa cu succes");
        navigateToTeamDetails();
      }
    }
  }
}