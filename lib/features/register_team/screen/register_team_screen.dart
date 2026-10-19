import 'package:flutter/material.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/constants/padding.dart';
import 'package:teamxperience/features/register_team/controller/register_team_controller.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/widgets/StepRegisterIcon.dart';
import 'package:teamxperience/widgets/my_appbar.dart';
import 'package:teamxperience/ui/components/buttons/my_button.dart';

import '../widgets/step1.dart';
import '../widgets/step2.dart';

class RegisterTeamScreen extends StatefulWidget {
  const RegisterTeamScreen({super.key});

  @override
  State<RegisterTeamScreen> createState() => _RegisterTeamScreenState();
}

class _RegisterTeamScreenState extends State<RegisterTeamScreen> {
  late RegisterTeamController controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final event = ModalRoute.of(context)!.settings.arguments as Event;
    controller = RegisterTeamController(context, event); // Initialize with context
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(appBarText: "Detalii echipa"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: MyPaddings.appHorizontalPadding,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 25),
                Row(
                  children: [
                    const StepRegisterWidget(text: '1', isEnabled: true),
                    Expanded(
                      child: Divider(
                        color:
                            !controller.secondStep
                                ? MyColors.transparentYellow
                                : MyColors.yellow, // line color
                        thickness: 2, // line height
                        indent: 10, // space to the left of the line
                        endIndent: 10, // space to the right of the line
                      ),
                    ),
                    StepRegisterWidget(
                      text: '2',
                      isEnabled: controller.secondStep,
                    ),
                    Expanded(
                      child: Divider(
                        color:
                            !controller.thirdStep
                                ? MyColors.transparentYellow
                                : MyColors.yellow, // line color
                        thickness: 2, // line height
                        indent: 10, // space to the left of the line
                        endIndent: 10, // space to the right of the line
                      ),
                    ),
                    StepRegisterWidget(
                      text: '3',
                      isEnabled: controller.thirdStep,
                    ),
                  ],
                ),
                const SizedBox(height: 45),
                if (!controller.secondStep && !controller.thirdStep)
                  Form(
                    key: controller.step1FormKey,
                    child: Step1(
                      numeEchipaController: controller.numeEchipaController,
                      componentaEchipeiController:
                          controller.componentaEchipeiController,
                      numarPersoaneController: controller.numarPersoaneController,
                    ),
                  ),
                if (controller.secondStep && !controller.thirdStep)
                  Form(
                    key: controller.step2FormKey,
                    child: Step2(
                      numeCapitanController: controller.numeCapitanController,
                      numarDeTelefonController: controller.numarDeTelefonController,
                      emailCapitanController: controller.emailCapitanController,
                    ),
                  ),
                if (controller.secondStep && controller.thirdStep)
                  Column(
                    children: [
                      Row(
                        children: [
                          Transform.scale(

                            scale: 1.5,
                            child: Checkbox(
                              value: controller.checkBox1,
                              onChanged:
                                  (value) => setState(
                                    () => controller.checkBox1 = value!,
                                  ),
                              activeColor: MyColors.yellow,
                              checkColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              side: const BorderSide(
                                width: 1.5,
                                color: Color(0xFFE6E6E6),
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Expanded(
                            child: Text(
                              "Sunt de acord cu Regulamentul Specific al activității.",
                              style: TextStyle(
                                fontSize: 13,
                                color: MyColors.blackColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Transform.scale(
                            scale: 1.5,
                            child: Checkbox(
                              value: controller.checkBox2,
                              onChanged:
                                  (value) => setState(
                                    () => controller.checkBox2 = value!,
                                  ),
                              activeColor: MyColors.yellow,
                              checkColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              side: const BorderSide(
                                width: 1.5,
                                color: Color(0xFFE6E6E6),
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Expanded(
                            child: Text(
                              "Sunt de acord cu folosirea datelor cu caracter personal.",
                              style: TextStyle(
                                fontSize: 13,
                                color: MyColors.blackColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Transform.scale(
                            scale: 1.5,
                            child: Checkbox(
                              value: controller.checkBox3,
                              onChanged:
                                  (value) => setState(
                                    () => controller.checkBox3 = value!,
                                  ),
                              activeColor: MyColors.yellow,
                              checkColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              side: const BorderSide(
                                width: 1.5,
                                color: Color(0xFFE6E6E6),
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Expanded(
                            child: Text(
                              "Sunt de acord ca imaginile și  video-urile care sunt realizate de organizatori sau de membrii echipei  mele în timpul activității să îmi fie trimise după eveniment. În același timp ASOCIAȚIA VBE SIBIU poate folosi aceste resurse pentru promovare.",
                              style: TextStyle(
                                fontSize: 14,
                                color: MyColors.blackColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                const SizedBox(height: 30),
                MyButton(
                  buttonText:
                      !(controller.secondStep && controller.thirdStep)
                          ? "Următorul pas"
                          : "Înscrie-ți echipa",
                  textColor: Colors.white,
                  buttonOnTap: () {
                    setState(() {
                      controller.buttonOnTap();
                    });
                  },
                  withBorder: false,
                  fontWeight: FontWeight.w500,
                  buttonTextSize: 15,
                  buttonColor: MyColors.yellow,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
