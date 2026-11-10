import 'package:teamxperience/model/team.dart';

/// The line on the route while an organiser walks through their own event.
const previewLine = 'Previzualizare: nimic nu se salvează.';

/// The throwaway team of an organiser's walk-through: it lives only on this
/// phone, and solving moves it forward.
Team previewTeamOf({DateTime? now}) => Team(
      name: 'Previzualizare',
      teamMembers: '',
      captainName: '',
      phoneNumber: '',
      captainEmail: '',
      hasStarted: true,
      startedAt: now ?? DateTime.now(),
    );
