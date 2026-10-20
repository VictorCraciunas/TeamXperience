import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:flutter_svg/svg.dart';
import 'package:teamxperience/features/enter_code/controller/enter_code_controller.dart';
import 'package:teamxperience/ui/components/navigation/my_appbar.dart';

import '../../../model/event.dart';
import 'package:teamxperience/ui/components/buttons/app_button.dart';

class EnterCode extends StatefulWidget {
  const EnterCode({super.key});

  @override
  State<EnterCode> createState() => _EnterCodeState();
}

class _EnterCodeState extends State<EnterCode> {
  late EnterCodeController controller;
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    final event = ModalRoute.of(context)!.settings.arguments as Event;
    controller = EnterCodeController(event, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(appBarText: "TeamXperience"),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Center(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: context.colors.navy,
              ),
              padding: const EdgeInsets.all(
                20.0,
              ), // Use padding instead of Padding widget
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Introdu codul primit",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20), // Spacing before text field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: TextField(
                        controller: controller.codeController,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: const InputDecoration(
                          hintText: "Introdu codul aici",
                          hintStyle: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20), // Spacing before button
                  AppButton(
                    label: "Trimite codul",
                    onPressed: () => controller.navigateToGame(),
                    leading: SvgPicture.asset(
                      'assets/images/incepe_jocul.svg',
                      width: 19,
                      height: 19,
                      colorFilter: ColorFilter.mode(
                        const Color(0xFF222F62),
                        BlendMode.srcIn,
                      ),
                    ),
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF222F62),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
