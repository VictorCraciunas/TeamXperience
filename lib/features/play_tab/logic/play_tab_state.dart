import 'package:teamxperience/features/home/logic/home_hero.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';

/// What the Joacă tab offers right now. Interim, until the start-code flow of
/// mockup 05 (redesign step 6).
sealed class PlayTabState {
  const PlayTabState();
}

/// The player's team is playing: continue the game.
class PlayLive extends PlayTabState {
  const PlayLive(this.event, this.team);

  final Event event;
  final Team team;
}

/// The event started less than an hour ago: type the start code.
class PlayEnterCode extends PlayTabState {
  const PlayEnterCode(this.event, this.minutesLeft);

  final Event event;
  final int minutesLeft;
}

/// The next registered event.
class PlayNext extends PlayTabState {
  const PlayNext(this.event, this.untilStart);

  final Event event;
  final Duration untilStart;
}

/// Nothing planned.
class PlayNone extends PlayTabState {
  const PlayNone();
}

/// The Joacă tab state for the Home hero (the same priorities as Home).
PlayTabState playTabState(HomeHero hero) => switch (hero) {
      LiveHero(:final event, :final team) => PlayLive(event, team),
      StartingSoonHero(:final event, :final minutesLeftToEnter) => PlayEnterCode(event, minutesLeftToEnter),
      UpcomingHero(:final event, :final untilStart) => PlayNext(event, untilStart),
      FinishedHero() || RecommendedHero() || NoHero() => const PlayNone(),
    };

/// Whether the centre tab shows "În joc".
bool isLive(PlayTabState state) => state is PlayLive;
