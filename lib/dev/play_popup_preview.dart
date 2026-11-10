import 'package:flutter/material.dart';
import 'package:teamxperience/enums/event_type.dart';
import 'package:teamxperience/features/play_tab/controller/play_popup_controller.dart';
import 'package:teamxperience/features/play_tab/widgets/play_popup.dart';
import 'package:teamxperience/features/play_tab/widgets/play_popup_actions.dart';
import 'package:teamxperience/features/shell/logic/player_tabs.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/mission.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/model/team_member.dart';
import 'package:teamxperience/state_management/events_state_management.dart';
import 'package:teamxperience/state_management/user_registered_events.dart';
import 'package:teamxperience/ui/components/misc/segmented_switch.dart';
import 'package:teamxperience/ui/components/navigation/app_shell.dart';
import 'package:teamxperience/ui/components/navigation/shell_controller.dart';
import 'package:teamxperience/ui/components/navigation/tab_header.dart';
import 'package:teamxperience/ui/ui.dart';

/// The Joacă pop-up of mockup 10 in the five-tab bar, with no Firebase: pick
/// a situation on Acasă, then tap the key.
class PlayPopupPreview extends StatefulWidget {
  const PlayPopupPreview({super.key});

  @override
  State<PlayPopupPreview> createState() => _PlayPopupPreviewState();
}

/// The two providers the pop-up reads, held in memory.
class _Events extends ChangeNotifier implements EventList {
  List<Event> list = const [];

  @override
  List<Event> get events => list;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UserEvents extends ChangeNotifier implements UserEventsProvider {
  List<Event> upcoming = const [];
  Event? started;
  Event? active;
  Team? team;

  @override
  List<Event> get upcomingRegisteredEvents => upcoming;
  @override
  List<Event> get registeredEvents => [...upcoming, if (started case final s?) s, if (active case final a?) a];
  @override
  Event? get recentlyStartedEvent => started;
  @override
  Event? get activeEvent => active;
  @override
  Team? get activeTeam => team;
  @override
  Event? get finishedEvent => null;
  @override
  Team? get finishedTeam => null;

  void changed() => notifyListeners();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PlayPopupPreviewState extends State<PlayPopupPreview> {
  final _shell = ShellController(5);
  final _events = _Events();
  final _userEvents = _UserEvents();
  late final PlayPopupController _popup = PlayPopupController(
    userEvents: _userEvents,
    eventList: _events,
    teamFor: (_) async => _team,
    teams: (_) => Stream.value([_team, _rival]),
    countTeams: (_) async => 9,
  )..addListener(_popupChanged);
  int _situation = 0;
  (bool, bool) _shown = (false, false);

  static final _team = Team(
    name: 'Vulpile',
    teamMembers: '',
    captainName: 'Ana',
    phoneNumber: '',
    captainEmail: '',
    hasStarted: true,
    missionProgress: 3,
    missionCompletedAt: {2: DateTime.now().subtract(const Duration(minutes: 6))},
    members: const [
      TeamMember(uid: 'a', displayName: 'Ana', initials: 'AN'),
      TeamMember(uid: 'm', displayName: 'Mihai', initials: 'MI'),
      TeamMember(uid: 'r', displayName: 'Radu', initials: 'RA'),
    ],
  );
  static final _rival = Team(
    name: 'Bufnițele',
    teamMembers: '',
    captainName: '',
    phoneNumber: '',
    captainEmail: '',
    hasStarted: true,
    missionProgress: 4,
  );

  static Event _game(DateTime start) => Event(
        eventId: 'harta',
        name: 'Harta Pierdută',
        dateEvent: start,
        punctDeStart: 'Piața Mare',
        meetingPointNote: 'lângă fântână',
        teamSizeMax: 4,
        nrMissions: 6,
        missions: [
          for (final (i, t) in ['Scara Pasajului', 'Podul Minciunilor', 'Turnul Sfatului', 'Fântâna cu lei', 'Biserica', 'Zidul']
              .indexed)
            Mission(id: '$i', title: t),
        ],
      );

  static Event _public(String id, String name, int days, String area) => Event(
        eventId: id,
        name: name,
        type: EventType.PUBLIC,
        area: area,
        durationMinutes: 120,
        dateEvent: DateTime.now().add(Duration(days: days)),
      );

  @override
  void initState() {
    super.initState();
    _shell.addListener(_popup.requestClose);
    _apply(0);
  }

  void _apply(int situation) {
    final now = DateTime.now();
    _situation = situation;
    _userEvents
      ..upcoming = situation == 0 ? [_game(now.add(const Duration(days: 20, hours: 2)))] : const []
      ..started = situation == 1 ? _game(now.subtract(const Duration(minutes: 18))) : null
      ..active = situation == 2 ? _game(now.subtract(const Duration(minutes: 48))) : null
      ..team = situation == 2 ? _team : null;
    _events.list = situation == 3
        ? [
            _public('a', 'Moștenirea Cartografului', 4, 'Sibiu'),
            _public('b', 'Protocolul Cerber', 10, 'Sibiu'),
            _public('c', 'Misterul Turnului Sfatului', 12, 'Sibiu'),
          ]
        : const [];
    _userEvents.changed();
    setState(() {});
  }

  void _popupChanged() {
    final shown = (_popup.isOpen, _popup.isClosing);
    if (shown != _shown && mounted) setState(() => _shown = shown);
  }

  void _say(String what) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(what)));

  @override
  void dispose() {
    _popup.dispose();
    _shell.dispose();
    super.dispose();
  }

  Widget _page(String title) => Column(children: [TabHeader(title: title), const Expanded(child: SizedBox())]);

  @override
  Widget build(BuildContext context) {
    final (open, closing) = _shown;
    final items = playerNavItems(live: _situation == 2, open: open && !closing);
    final pages = <WidgetBuilder?>[
      (_) => Column(
            children: [
              const TabHeader(title: 'Acasă'),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.page),
                child: SegmentedSwitch(
                  labels: const ['Înscris', 'Cod', 'În joc', 'Nimic'],
                  selectedIndex: _situation,
                  onSelected: _apply,
                ),
              ),
            ],
          ),
      (_) => _page('Evenimente'),
      null,
      (_) => _page('Echipe'),
      (_) => _page('Profil'),
    ];
    return AppShell(
      controller: _shell,
      overlay: open
          ? PlayPopup(
              controller: _popup,
              actions: PlayPopupActions(
                openEvent: (_) => _say('Vezi evenimentul'),
                openTeam: (_) => _say('Echipa mea'),
                enterCode: (_) => _say('Codul de start'),
                continueGame: (_, _) => _say('Jocul'),
                openChat: (_, _) => _say('Chatul'),
                browseAll: () => _shell.select(PlayerTab.events),
              ),
            )
          : null,
      onOverlayBack: _popup.requestClose,
      tabs: [
        for (var i = 0; i < items.length; i++)
          i == PlayerTab.play
              ? AppShellTab(item: items[i], onTap: _popup.toggle)
              : AppShellTab(item: items[i], builder: pages[i]),
      ],
    );
  }
}
