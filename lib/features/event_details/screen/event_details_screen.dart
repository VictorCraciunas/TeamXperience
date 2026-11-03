import 'package:flutter/material.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/features/event_details/controller/event_details_controller.dart';
import 'package:teamxperience/features/event_details/widgets/event_page_view.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/ui/components/buttons/app_button.dart';
import 'package:teamxperience/ui/components/misc/app_svg_icon.dart';
import 'package:teamxperience/ui/components/navigation/my_appbar.dart';

class EventDetailsScreen extends StatefulWidget {
  const EventDetailsScreen({super.key});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  late EventDetailsController controller;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? const {};
    final event = arguments['event'] as Event;
    final isAdmin = arguments['isAdmin'] as bool? ?? false;
    controller = EventDetailsController(event, context, isAdmin: isAdmin);
    _initialized = true;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  List<Widget> _adminActions() => [
        AppButton(
          label: 'Vezi echipele înscrise',
          onPressed: () => Navigator.pushNamed(context, Routes.eventRegisteredTeams, arguments: controller.event),
        ),
        AppButton(
          label: 'Gestionează evenimentul',
          onPressed: () => Navigator.pushNamed(context, Routes.eventManagement, arguments: controller.event),
          leading: const AppSvgIcon('assets/images/notification2.svg', width: 24, height: 24),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final isAdmin = controller.isAdmin;
        final event = controller.event;
        return EventPageView(
          event: event,
          data: controller.data,
          now: DateTime.now(),
          onBack: () => Navigator.maybePop(context),
          onShare: controller.share,
          onOpenMap: event.hasStartPin ? controller.openMap : null,
          onMessageOrganiser: controller.messageOrganiser,
          onSignupAction: controller.onSignupAction,
          showHeroButtons: !isAdmin,
          adminActions: isAdmin ? _adminActions() : const [],
          appBar: isAdmin
              ? MyAppBar(
                  appBarText: 'Detalii Eveniment',
                  iconString: 'assets/images/menu.svg',
                  showDropdown: true,
                  event: event,
                )
              : null,
        );
      },
    );
  }
}
