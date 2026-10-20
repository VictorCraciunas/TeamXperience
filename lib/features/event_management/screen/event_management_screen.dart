import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/ui/components/navigation/my_appbar.dart';

import '../controller/event_management_controller.dart';
import '../widgets/info_banner.dart';
import '../widgets/management_button.dart';

class EventManagementScreen extends StatefulWidget {
  const EventManagementScreen({super.key});

  @override
  State<EventManagementScreen> createState() => _EventManagementScreenState();
}

class _EventManagementScreenState extends State<EventManagementScreen> {
  EventManagementController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller == null) {
      final event = ModalRoute.of(context)!.settings.arguments as Event;
      _controller = EventManagementController(context, event);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller!;
    final event = controller.event;

    return Scaffold(
      appBar: const MyAppBar(appBarText: "Gestionare eveniment"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.page,
          ),
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  Text(
                    event.name ?? "",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: context.colors.text,
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (!controller.hasStarted) ...[
                    const InfoBanner(
                      text:
                          "Evenimentul nu a început încă. Harta și chat-ul vor fi disponibile după ce evenimentul începe.",
                    ),
                    const SizedBox(height: 30),
                  ] else if (controller.isStopped) ...[
                    const InfoBanner(
                      text:
                          "Evenimentul a fost oprit. Echipele au fost anunțate.",
                    ),
                    const SizedBox(height: 30),
                  ],
                  ManagementButton(
                    text: "Trimite notificare",
                    icon: 'assets/images/notification2.svg',
                    enabled: true,
                    onTap: controller.navigateToNotification,
                  ),
                  const SizedBox(height: 15),
                  ManagementButton(
                    text: "Hartă",
                    icon: 'assets/images/location_map.svg',
                    enabled: controller.hasStarted,
                    onTap: controller.navigateToMap,
                  ),
                  const SizedBox(height: 15),
                  ManagementButton(
                    text: "Chat",
                    icon: 'assets/images/incepe_jocul.svg',
                    enabled: controller.hasStarted,
                    onTap: controller.navigateToChat,
                  ),
                  const SizedBox(height: 15),
                  ManagementButton(
                    text: controller.isStopping
                        ? "Se oprește..."
                        : "Oprește evenimentul",
                    icon: 'assets/images/notification2.svg',
                    enabled: controller.canStop,
                    onTap: controller.confirmAndStop,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
