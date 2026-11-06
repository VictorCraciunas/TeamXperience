# Roadmap: building the November 2026 mockups

Written 2026-11-03. Goal: the app looks exactly like the nine mockups and does
everything they show. Part A is the logic (data, services, backend) each
mockup needs. Part B is the UI. Logic phases come first because most screens
show data that does not exist yet.

## The reference mockups

The source of every mockup is in [mockups/](mockups/). Open the files in a
browser; the app should match them side by side at phone width.

| # | File | Screens |
|---|------|---------|
| 01 | [01-event-details.html](mockups/01-event-details.html) | Event page (hero, route strip, facts, story, mission trail, how you play, past photos, logistics, organiser, sticky sign-up bar and its other states) |
| 02 | [02-home.html](mockups/02-home.html) | Home before an event (countdown, team preparation, new events, memories) and during a live event (timer, progress, live leaderboard, team) |
| 03 | [03-events-and-teams-tabs.html](mockups/03-events-and-teams-tabs.html) | Evenimente tab (list/map, filters, your registrations, open events) and Echipe tab (your team, invite code, season leaderboard) |
| 04 | [04-register-and-join-team.html](mockups/04-register-and-join-team.html) | Short registration form, invite-code result, join by code |
| 05 | [05-start-code-and-intro.html](mockups/05-start-code-and-intro.html) | Start-code screen with time left and wrong-code message, themed intro letter |
| 06 | [06-game-route-and-code-puzzle.html](mockups/06-game-route-and-code-puzzle.html) | Mission route as a trail, code puzzle with timer, attempts, wrong-answer message, hint |
| 07 | [07-location-and-photo-puzzles.html](mockups/07-location-and-photo-puzzles.html) | Location puzzle (distance, direction, hotter/colder), photo puzzle pending, approved, rejected |
| 08 | [08-finish-and-profile.html](mockups/08-finish-and-profile.html) | Finish recap, Profil tab (level, stats, badges, memories, settings) |
| 09 | [09-admin-live-control-room.html](mockups/09-admin-live-control-room.html) | Organiser live map, live counts, attention queue, team progress board, announce, stop |

## Decisions already taken by the mockups

These were open questions; the mockups answer them, so they are now in scope:

1. The start code ignores capitals and spaces ("Nu contează literele mari sau mici").
2. Rejecting a photo needs a reason ("Respinsă: „Nu se vede ceasul”").
3. Registration asks only for the team name, size and captain's phone; name and email come from the account, and members join with an invite code.

**Decided by Victor (2026-11-05): a team waits for a photo's approval.** The
photo puzzle keeps today's behaviour: Continue unlocks only after the organiser
approves. Mockup 07's "Puteți merge spre misiunea următoare; o deblocăm când e
aprobată" is replaced by a waiting message (step 6c words it).

**Step 6 is split in three plans (Victor, 2026-11-05):** 6a start code and
intro letter (05), 6b route trail and code puzzle (06), 6c location and photo
puzzles (07). Each gets its own branch and merge.

**Step 6c (2026-11-06):** location and photo puzzles as mockup 07, the
organiser's required rejection reason, `radiusMeters`, and progress that never
goes back. Badges, finishing and the distance walked moved to step 7.

**Decided by Victor (2026-11-06): solved missions stay closed.** On the route
trail a solved mission is only a tick; players cannot reopen it to re-read its
puzzle. The look of every game screen comes from the event's own puzzles; the
organiser sets nothing extra (no style section, no presets).

## Branches

All redesign work lives on `redesign/mockups`. Each step in "Order and size"
gets its own branch from it (`redesign/step-1-foundations`, ...), and merges
back into `redesign/mockups` when done. `redesign/mockups` merges into `main`
only when Victor decides. Nothing is pushed.

## My calls (please check)

- **Teams persist across events.** The Echipe tab shows "Vulpile · 3 jocuri · 1 victorie · 31 km" and a season leaderboard, so a team is more than one registration. I would add a top-level `crews/{crewId}` collection. Registering for an event creates `events/{eventId}/teams/{teamName}` linked to the crew by `crewId`. The invite code belongs to the crew, so a teammate joins once and plays every event with it.
- **Joining goes through a Cloud Function** (`joinTeamByCode`), not a client-side query. Clients should not be able to list every team to look up a code. The repo has no `firestore.rules` either, so rules are a step of their own (L1.6).
- **Points and XP are worked out by a Cloud Function when an event ends,** so a client cannot change them. Season points: 1st 100, 2nd 75, 3rd 60, then 50 minus 5 for each place below, never less than 10. XP: 100 per finished game, 20 per mission, +50 with no hints, and badges give XP too. Levels: Începător 0, Explorator 500, Cartograf 1000, Legendă 2500.
- **Știri leaves the bottom bar.** It is not one of the five tabs (Acasă, Evenimente, Joacă, Echipe, Profil). News moves to a section on Acasă, with its own screen behind "Vezi toate".
- **Dark mode:** the mockups are light only. Every new component reads `context.colors`, and the dark versions follow the existing dark tokens. The event theme (parchment) looks the same in both modes.

---

# Part A: Logic roadmap

Each phase lists the mockups it unlocks. Fields are optional with defaults, so
old documents still load (same rule as the 2026-10-20 game-flow spec).

## L0: Fix what the mockups rely on today

Small and safe; do it first.

- `EnterCodeController.navigateToGame`: compare with `isCorrectAnswer` (trim plus lower case) instead of `==`. Remove `team!`. Return a result (ok / wrong / no team / window closed) instead of printing. *(05)*
- `TeamService.addTeam`: stop taking `BuildContext`; the controller updates `UserProvider`. *(04)*
- `addUserToTeam` in `teamRepo.dart` exists but nothing calls it. It gets wired in L2. *(04)*

## L1: Data model

### L1.1 Event (`lib/model/event.dart`)

| New field | Type | Mockup text it drives |
|---|---|---|
| `area` | String? | "Sibiu · Orașul de Sus" (`location` stays the city) |
| `routeLengthKm` | double? | "4,5 km" (`lungimeTraseu` is kept as a fallback) |
| `durationMinutes` | int? | "2 h durată", filter "Sub 2 h" |
| `difficulty` | enum `Difficulty { easy, medium, hard }` | "●●○ Medie", chips "● Ușor / ●● Mediu" (old `dificultate` text is mapped across) |
| `teamSizeMin`, `teamSizeMax` | int (2, 6) | "Echipe de 2–6", the size picker on registration |
| `maxTeams` | int? | "Mai sunt 2 locuri" |
| `startLatitude`, `startLongitude` | double? | route strip, the events map, "Hartă" |
| `meetingPointNote` | String? | "Start: Piața Mare, lângă fântână" (falls back to `punctDeStart`) |
| `arriveMinutesBefore` | int (15) | "fii acolo la 9:45" |
| `whatToBring` | List<String> | "Telefon încărcat, încălțări comode" |
| `story` | String? | "Povestea" (falls back to `description`) |
| `introLetter`, `introSignature` | String? | the intro letter on 05 ("— Cartograful") |
| `finishTitle`, `finishLine` | String? | "Harta e completă / Vulpile au moștenit secretul…" (`{team}` is replaced) |
| `hintsPerMission` | int (1) | "1 indiciu / misiune" |
| `enterWindowMinutes` | int (60) | "A început · 42 min să intri" (replaces the hard-coded ~1 h) |
| `organiserId` | String? | the "Organizator" card |
| `seriesId` | String? | "De la ediția trecută" (links editions of the same game) |
| `theme` | `EventTheme?` | the parchment takeover from 05 onwards |

Derived getters, not stored:

- `puzzleKinds`: from puzzle types. It drives the chips "Coduri · Fotografii · Locuri pe hartă".
- `registrationClosesIn`: drives "Înscrieri deschise · încă 5 zile".
- `enterWindowLeft`, `isLive`, `timeLeft`: drive "1:17:42 rămase".
- `spotsLeft`: worked out from `maxTeams` and the team count.

`EventTheme` grows from today's `EventDefaults` (`backgroundColor`,
`textColor`, `accentColor`, `fontFamily`). It adds `surfaceColor`,
`secondaryAccent` (gold), `mutedColor`, `displayFont`, `bodyFont`,
`backgroundImageUrl` and `routeStyle` (dashed / ink). `EventDefaults` stays as
the per-component default; `EventTheme` is the screen chrome.

### L1.2 Mission (`lib/model/mission.dart`)

Missions have no title today. Add:

- `title`: "Scara Pasajului"
- `teaser`: "Numără treptele. Nu toate sunt la vedere."
- `isTeaserPublic` (bool): the first N show on the event page; the rest count into "Încă 4 misiuni secrete"
- `latitude`, `longitude` (optional): for the trail and "la 180 m de tine"
- `estimatedMinutes`

### L1.3 Puzzle (`lib/model/puzzle.dart`)

- `maxAttempts` (int?, null means unlimited): "2 încercări rămase"
- `wrongAnswerMessage` (String?): "Nu e anul ăsta. Uită-te mai sus pe ușă."; a default text when empty
- `radiusMeters` (int, 20): replaces `_circleRadiusMeters` in `geolocation_puzzle_widget.dart`
- `indiciu` already exists and is the hint
- `badgeId` (String?): "+ insignă foto"

### L1.4 Event team (`lib/model/team.dart`)

- `crewId`
- `captainUid`. `captainName` and `captainEmail` are filled from the account.
- `members`: `List<TeamMember{uid, displayName, initials}>`, kept next to `userIds` for avatars
- `inviteCode`: a copy of the crew code, for "Gata. Trimite codul"
- `rulesAcceptedAt`, `photoConsent`
- `startedAt`, `finishedAt` (Timestamps): the timer and "1:48 timp total"
- `missionCompletedAt`: `Map<String, Timestamp>`. It drives "Ultima misiune rezolvată acum 6 min", "Cea mai rapidă: misiunea 2 (6 min)" and the admin "acum 2 min" / "blocați 25 min".
- `attempts` (`Map<approvalKey, int>`) and `hintsUsed` (`Map<approvalKey, bool>`): "2 indicii", the admin's "3 încercări greșite"
- `distanceMeters`: "4,7 km pe jos"; `LocationService` adds to it on each update
- `presence`: `Map<uid, Timestamp lastSeen>`. It drives "3 din 4 sunt aici" and "3 jucători activi" (seen in the last 2 min).
- `photoApprovals` values become `{status, reason?, decidedAt}`, so a rejection carries its reason. A plain string is still read as the status.
- `place` (int?): written when the team finishes

### L1.5 New collections

```
crews/{crewId}            name, captainUid, memberUids[], members[], inviteCode, stats{games, wins, distanceMeters}, createdAt
inviteCodes/{code}        crewId   (keeps codes unique, readable only by Functions)
seasons/{seasonId}        name "Toamna 2026", startsAt, endsAt
seasons/{seasonId}/standings/{crewId}   crewName, points, games
users/{uid}               + xp, level, stats{games, distanceMeters, missions, podiums}, badges[]
users/{uid}/memories/{eventId}   eventName, date, place, totalTime, photoUrls[]
events/{eventId}/feedback/{uid}  rating, comment
badges/{badgeId}          title, icon, rule   (static list: primii 10 km, fără indicii, joc nocturn, câștigă un joc, ...)
organisers/{uid}          displayName, initials, eventsCount   (or fields on the admin's user doc)
```

Data reads go through a repo in `backend/repo/` and a service in `service/`,
as today. Update `docs/data-model.md` in the same change.

### L1.6 Firestore security rules

There is no `firestore.rules` in the repo. Before invite codes, write rules
that:

- let members read and update only their own team's progress fields
- keep `inviteCodes`, standings, xp and badges writable only by Functions
- let admins do everything

## L2: Teams and registration (mockups 04, 03-Echipe)

1. `CrewService` / `CrewRepo`: create a crew, get the user's crews, stream a crew.
2. Cloud Function `createCrew` (callable): makes a unique code in the form `AAA-999`, with the letters taken from the team name ("Vulpile" → VLP), and writes `inviteCodes/{code}`.
3. Cloud Function `joinTeamByCode(code, eventId?)`:
   - It looks up the code and checks the team is not full (`numberOfMembers` / `teamSizeMax`).
   - It adds the uid to the crew, and to the event team when the crew is registered for an upcoming event. It also adds the event to the user's `registeredEventIds` (the `arrayUnion` from `addUserToTeam`).
   - It returns a preview: event, team, captain, members and the slot number. This is "2 din 4 · tu ești al 3-lea".
   - Split it into `previewInvite` and `confirmJoin`, so the screen can show the team before the user confirms.
4. `isTeamNameFree(eventId, name)`: a live check while typing, debounced 400 ms. It drives "Numele e liber".
5. `TeamService.registerTeam(event, crew?, name, size, phone, consents)`:
   - It checks capacity (`spotsLeft > 0`) and that registration is open.
   - It replaces `addTeam`. The captain's name and email come from `AppUser`.
6. Share: `share_service` gets a `shareInvite(code, event)` that opens WhatsApp. "Copiază" copies the code.
7. Notifications: `onTeamJoin` (Firestore trigger) tells the captain that someone joined.

## L3: Event page and lists (mockups 01, 03-Evenimente)

1. `EventDetailsController` exposes one view-state:
   - the hero facts
   - public mission teasers and the secret count
   - puzzle kinds
   - the registered teams count (a cheap count query)
   - spots left
   - the organiser
   - the last edition: winner, time and up to 6 approved photos, read through `seriesId`
2. Sign-up bar state machine, `SignupBarState`:
   - `open(daysLeft, teamsCount)`: "Înscrie echipa"
   - `registered(team, members)`: "Vulpile · 4 membri / Echipa ta"
   - `enterWindow(minutesLeft)`: "Introdu codul"
   - `live`, `full`, `closed` and `over`, each with its own copy

   Write it as a pure function with unit tests.
3. Events list filters as a pure function over `EventList`:
   - `Toate`
   - `Luna asta`
   - difficulty
   - `Sub 2 h` (`durationMinutes <= 120`)
   - `Înscrierile tale` split out first

   The open count ("Deschise pentru înscriere 4") comes from the same pass.
4. Events map: markers from `startLatitude/Longitude`, using `flutter_map` like the admin map.
5. Approved photos: a `Message` of type image whose approval is approved feeds both the past-edition grid and memories. Add `isPublic` to the message, or copy approved photos to `events/{id}/gallery` from a Function (recommended).

## L4: Home and the Joacă tab (mockup 02)

1. `UserEventsProvider` already finds the next and active event. Add:
   - countdown parts (days / hours / minutes)
   - the preparation checklist: registered → team complete (members == size) → start code. `preparation_steps.dart` already exists; extend it.
2. Live state (stream of all the event's teams):
   - time left
   - "misiunea 4 din 6"
   - live leaderboard
   - active members (`presence`)
   - last mission solved (`missionCompletedAt`)
3. `LeaderboardService.rank(teams)`: a pure function. Sort by finished first, then missions done, then the time of the last mission. "Locul 2 din 12" and the admin board use the same function.
4. Joacă tab target, also pure: no event → explain and link to Evenimente; registered event later → countdown; within the enter window → start code; started → the game. The tab label becomes "În joc" while live.
5. User stats (`3 jocuri · 12,4 km · Explorator`) are read from `users/{uid}.stats`, written by L7.

## L5: Starting the game (mockup 05)

1. Start-code check: L0 normalisation, and the window from `enterWindowMinutes`. The wrong-code message has its own state.
2. Presence: on the start screen and during play, the client writes `presence.{uid} = serverTimestamp` every 60 s. The start screen streams the team and shows who is here.
3. `startTeam` sets `startedAt` once, in a transaction: the first member to press "Pornește jocul" starts the clock for everyone. Later members go straight in.
4. "Nu ai codul? Scrie-i organizatorului" opens the existing team chat.
5. The intro letter shows once per team (keyed on `startedAt`). "Spre prima misiune" opens the route.

## L6: Playing (mockups 06, 07)

1. **Route screen:** missions in order, with each state from `missionProgress` (done / now / locked). The distance to the current mission comes from `LocationService` and the mission's coordinates. The header shows place, time played and time left.
2. **Code puzzle:**
   - `PuzzleGameController` counts attempts per puzzle into `team.attempts`.
   - When `maxAttempts` is reached: the hint opens automatically, the input locks for 60 s and the admin sees it in the attention queue. *(My call.)*
   - Show the wrong-answer message.
   - Using the hint writes `hintsUsed`; there is a limit per mission from `hintsPerMission`.
3. **Location puzzle:**
   - Distance and bearing from `Geolocator.bearingBetween`, giving "spre nord-est".
   - Walking time at 80 m/min, giving "~2 min".
   - Hotter/colder from the last 3 distance readings, giving "mai aproape".
   - "Intră în cerc" is enabled inside `radiusMeters`.
4. **Photo puzzle:**
   - Upload → chat message → approval set to pending (as today). Continue unlocks only after approval (decided; see above).
   - A team can finish only when every photo is approved. A rejected photo comes back as a task on the route ("Fă altă poză").
   - `setPhotoApproval` takes a reason; the admin dialog makes it required for rejections.
   - Approval with a `badgeId` awards the badge.
5. **Finishing:** the last puzzle sets `finishedAt`, works out the place from the leaderboard and opens the finish screen. `EventGameController` already watches `isStopped` and expiry; when the event ends early it opens the finish screen with the partial result.
6. **Distance walked:** `LocationService` adds the distance between fixes to `team.distanceMeters`, ignoring jumps over 50 m in 5 s and fixes less accurate than 30 m.

## L7: After the game (mockup 08)

1. Cloud Function `onEventFinished` (fires when `isStopped` turns true, plus a scheduled job for 3 h expiry):
   - It ranks the teams and writes each `place`.
   - It updates crew stats and season standings.
   - For each player it adds xp, stats, badges and `memories/{eventId}`.
   - It is idempotent: it writes `events/{id}.resultsComputedAt`.
2. Finish screen data:
   - place / number of teams, total time, km, fastest mission, hints used
   - team photos (approved)
   - the rating, saved to `feedback`
   - "Distribuie" (an image or text through `share_service`) and "Vezi clasamentul"
3. Profil: level name, XP to the next level, stats, badges (earned out of total), memories, theme (the existing `ThemeController`), notifications toggle, sign out.

## L8: Organiser live room (mockup 09)

1. `LiveRoomController` streams teams and messages for one event.
2. Counts: in play / finished / not started (`admin_event_stats.dart` already has this, so extend it).
3. Attention queue, a pure function with unit tests, newest first:
   - photos pending
   - a team with no mission solved in 20 min ("stau de 25 min")
   - 3 or more wrong attempts on the current puzzle
   - unread team messages, using an `unreadByAdmin` flag set by `onChatMessage` and cleared when the admin opens the chat
4. Board: rank, team, missions done / total and status text, with filters Toate / Blocate / Neporniți.
5. "Sună căpitanul": a `tel:` link to the team phone (`MyMapController.callTeam` already does this).
6. "Anunț": calls `sendNotification` with `eventId`, which exists, and also posts the text into every team chat.
7. "Oprește": the existing stop. It now also triggers `onEventFinished`.
8. Map: team markers coloured per team, initials, and tap for a team sheet. A "Hartă mare" full-screen route (`Routes.map` exists).

## L9: Organiser authoring for the new fields

Everything above needs data that admins can enter, so the event wizard
(`create_event`) gets:

- Event step: area, km, minutes, difficulty, team size, max teams, start pin on a map, meeting note, arrive-before, what to bring, story, intro letter, finish text, hints per mission, enter window, series, theme.
- Mission editor: title, teaser, public toggle, pin, minutes.
- Puzzle rules (`puzzle_rules_form.dart`): max attempts, wrong-answer message, radius, badge.
- Completeness checks in `event_completeness.dart` for the new required bits: start pin and mission titles.
- The JSON import in `event_json_import.dart` and the examples in `docs/event-examples/` read the new fields.

---

# Part B: UI roadmap

Rules for every step:

- Colours come from `context.colors`, or from `EventTheme` inside a game.
- Text styles come from `AppTextStyles`, and spacing from `AppSpacing` / `AppRadius`.
- Each widget gets its own file, and each screen its own controller.
- Shared widgets go in `lib/ui/components/` and take their copy as parameters.
- Each screen is checked against its mockup file at 390 px wide, in light and dark.

## U0: Design tokens and theme

- Check every colour in the mockups against `AppColors`, and add the missing tokens (live red, soon amber, route dash, gold, `liveSoft`, ...) for light and dark.
- Add any missing text styles (big numbers in stats and the countdown, the uppercase section label, the mono code boxes) to `AppTextStyles`.
- `EventThemeScope`: an `InheritedWidget` plus a `context.eventTheme` that turns `Event.theme` into colours and fonts. Every screen from 05 onwards wraps its body in it. It falls back to the app theme when an event has no theme.
- Fonts: the mockups' serif "voice" font for letters and stories. Add a font asset (for example a free serif such as Lora or EB Garamond) and register it in `pubspec.yaml`.

## U1: Shared components (`lib/ui/components/`)

Build these once, with widget tests, before any screen:

| Component | Folder | Used on |
|---|---|---|
| `RouteLine` (`CustomPainter`: dashed path, waypoint dots, done / now / locked states, horizontal strip and winding vertical trail) | `route/` | 01, 02, 06, 09 |
| `RouteStrip` (`RouteLine` plus start and end labels) | `route/` | 01, 03 |
| `RouteTrail` (vertical winding trail with mission stops) | `route/` | 01, 06 |
| `FactTile` / `FactRow` (big value with a small label: "14 nov · 10:00", "2 h", "●●○ Medie", "12 echipe") | `event/` | 01, 03 |
| `DifficultyDots` | `event/` | 01, 03 |
| `ChipRow` / `FilterChip` (the mockup style) | `misc/` | 01, 03 |
| `AvatarStack` (initials circles, overlap, "+N") | `misc/` | 02, 03, 04, 05 |
| `StickyActionBar` (pinned bottom bar, left text, right button, every `SignupBarState`) | `buttons/` | 01, 05 |
| `CountdownTiles` (exists, restyled: days / hours / minutes) | `event/` | 02 |
| `ChecklistRow` (exists, restyled as a three-step line) | `event/` | 02 |
| `LeaderboardRow` / `LeaderboardList` (place, name, "voi" highlight, score) | `leaderboard/` | 02, 03, 09 |
| `StatTile` (exists, checked against the mockups) | `layout/` | 02, 03, 08 |
| `SectionHeader` (title and "Vezi toate / Tot / Toate" link; replaces `section_title.dart` where needed) | `misc/` | all |
| `PhotoGrid` (2–4 images with a "+38" tile) | `media/` | 01, 08 |
| `CodeBoxesInput` (one box per character, mono, error shake, paste) | `inputs/` | 04, 05, 06 |
| `SegmentedSwitch` (exists: Listă / Hartă) | `misc/` | 03 |
| `SizePicker` (2 3 [4] 5 6) | `inputs/` | 04 |
| `TimerPill` / `LiveBadge` ("● LIVE · 1:17:42 rămase", "0:42:18") | `feedback/` | 02, 06, 07, 09 |
| `BadgeTile` (earned and locked) | `profile/` | 08 |
| `MemoryCard` | `event/` | 02, 08 |
| `InviteCodeCard` (code, WhatsApp, Copiază) | `team/` | 03, 04 |
| `AttemptsMeter` and `HintButton` | `game/` | 06 |
| `DistanceCompass` (distance, direction arrow, hotter/colder) | `game/` | 07 |
| `PhotoStatusBanner` (pending / approved / rejected with reason) | `game/` | 07 |

Delete the six unused components (`events_carousel`, `registered_events_carousel`, `registered_events_list`, `async_state`, `custom_icon_dashboard`, `theme_mode_button`) or reuse them, so the folder stays clean.

## U2: Shell and navigation (02, 03, 08)

- `UserShell`: five tabs, Acasă · Evenimente · Joacă (centre, raised) · Echipe · Profil. The centre label changes to "În joc" while live.
- `AppBottomNav` / `AppNavItem`: the raised centre item.
- News moves to an Acasă section with its own route.
- New routes in `Routes` and `main.dart`:
  - `teams` (Echipe tab content)
  - `joinTeam`
  - `inviteResult`
  - `gameIntro`
  - `gameRoute` (replaces `eventGame`)
  - `finish`
  - `liveRoom` (admin; replaces or wraps `eventManagement`)
- Update `docs/features.md` with every new route.

## U3: Screens, in build order

Each step needs the logic phase shown in brackets.

1. **Event details (01)** [L1, L3]:
   - Rebuild `event_details_screen.dart` as sections, one widget file each, in `features/event_details/widgets/`: hero, route strip, facts, story with "Citește tot", mission trail with secret count, kind chips, how-you-play, last edition, logistics, organiser.
   - Add the `StickyActionBar` in every state, which replaces `AlreadyRegisteredCard`.
   - Admin variants keep their own actions.
2. **Register and join (04)** [L2]:
   - `register_team` becomes one short screen: name with the live check, `SizePicker`, phone, two checkboxes.
   - Then the invite result screen.
   - Then the new `features/join_team` (code boxes → team preview → join).
3. **Evenimente tab (03 left)** [L3]: list and map toggle, filter chips, "Înscrierile tale", open events with "Mai sunt N locuri". Uses `features/events_dashboard/events_dashboard_user`.
4. **Echipe tab (03 right)** [L2, L7 for stats and season]: team card with avatars and stats, invite code, season leaderboard, "Echipă nouă", "Ai primit un cod? Intră". This is a new `features/teams`.
5. **Home (02)** [L4]: before-event layout, then the live layout. Rebuild `features/home/widgets/` to the mockup order: greeting with stats, next game with countdown, team preparation, new events, memories / live card, leaderboard, team.
6. **Start code and intro (05)** [L5]:
   - `enter_code` restyled with `CodeBoxesInput`, the enter-window pill and team presence.
   - The new `features/game_intro` letter screen in the event theme.
7. **Route and code puzzle (06)** [L6]:
   - `event_game_screen.dart` becomes the trail.
   - `puzzle_game_screen.dart` gets the header (mission x of y, title, timer), attempts, wrong message and hint.
   - Replace the hardcoded "Ai nevoie de ajutor ?" pill with the hint and chat buttons.
8. **Location and photo puzzles (07)** [L6]:
   - `geolocation_puzzle_widget.dart` gets the map, `DistanceCompass` and "Intră în cerc".
   - The `image_upload/` flow gets the pending banner, "Refă", approved and rejected states.
   - The admin approval dialog gets a required reason.
9. **Finish and Profil (08)** [L7]: the new `features/finish` in the event theme. `features/profile` is rebuilt (level, stats, badges, memories, settings).
10. **Organiser live room (09)** [L8]:
    - Map with markers, counts, attention queue, board with filters, announce / stop bar.
    - Fix the white-on-accent avatars (`team_card_widget.dart:39`, `map_screen.dart:168`) with `onTick` while there.
    - Move the hardcoded colours in `image_message_bubble.dart:87,172` to tokens.
11. **Organiser authoring (L9 UI):** the new fields in the wizard, mission editor and puzzle rules, styled like the rest of the admin side.

## U4: Polish and checks

- Dark mode pass on every new screen. The event theme stays as authored.
- Empty, loading and error states for each list: no events, no team, no memories, offline.
- Outdoor use: tap targets at least 48 px, high contrast in the game, works one-handed. Text sizes follow the mockups 1:1 (1 CSS px = 1 dp, so 11 px captions stay 11).
- Animations from the mockups: countdown tick, route dot pulse on "now", code box shake, pop on correct answer (exists).
- `flutter analyze` and `flutter test` clean. `no_hardcoded_colors_test` keeps passing (new feature files add nothing to the allow-list).
- Golden tests for the U1 components and the main screens at 390×844.

---

# Order and size

Roadmap phases do not stand alone; this is the order I would build in. Each
line is roughly one plan, branch and merge.

| Step | Logic | UI | Result you can try |
|---|---|---|---|
| 1 | L0 | U0, U1 (route, chips, facts, sticky bar) | Nothing visible yet; the parts exist |
| 2 | L1.1–L1.3, L9 (event + mission fields) | U3.1 | New event page, with data you can enter |
| 3 | L1.4, L1.5 (crews), L2 app side | U3.2, U3.4 (team card, code) | The register, join and Echipe screens (they show an error until 3b is deployed) |
| 3b | L1.6 rules, L2 Cloud Functions | — | Registering and joining work for real |
| 4 | L3 | U2, U3.3 | Five-tab shell and the new Evenimente tab |
| 5 | L4 | U3.5 | New Home before and during an event |
| 6 | L5, L6 | U3.6–U3.8 | The whole game in the event theme |
| 7 | L7 | U3.9, U3.4 (stats, season) | Finish screen, profile, XP, badges, season |
| 8 | L8 | U3.10 | Organiser live room |
| 9 | — | U3.11, U4 | Authoring polish, dark mode, edge states, goldens |

Each step gets its own spec check and a plan in `docs/superpowers/plans/` before
code, and merges into `redesign/mockups` (see "Branches"; no push).

**Step 7 is split in three (Victor, 2026-11-07):** 7a the finish screen (app
side: `finishedAt`, distance walked, the recap from the team's own data,
rating, share), 7b the Profil tab, 7c the results Cloud Function
`onEventFinished` (L7.1: places, XP, badges, season standings, crew stats,
memories). **7c is parked with 3b** and done together with it later; until
then Profil shows starter values.

**Step 3b (parked by Victor on 2026-11-05, to do later).** Tasks 1 and 3 of
`docs/superpowers/plans/2026-11-04-redesign-step-3-teams-and-invites.md`:
`firestore.rules` with the emulator tests (start by comparing with the rules
live in the Firebase console) and the five callables (`checkTeamName`,
`createCrew`, `registerTeam`, `previewInvite`, `joinTeam`). Carry into it:
- registering an existing crew for a new event (the register screen never
  passes `crewId` today, so every registration makes a new crew);
- `joinTeam` returning the event ids for a player who is already a member (a
  join that timed out but committed), and `previewInvite` sending the team's
  members rather than the crew's;
- a signed-out call answers `unauthenticated` with `reason: 'notSignedIn'`;
- from Task 2: quote the test glob, add `@types/node`, escape the
  combining-mark range, fold Ş/Ș in `nameKey`, keep compiled tests out of a
  deploy;
- the emulators line in `docs/platform-and-config.md`;
- from step 5: the rules must let a team member update `presence.{uid}` (their own uid) and `missionCompletedAt.*` on their own team doc; otherwise presence fails silently and the mission-progress update (same write) fails;
- from step 5: write `missionCompletedAt.{i}` only when absent (a transaction or the step 7 function), so a second phone or a replay does not move the tie-break;
- from step 6b: the rules must let a team member increment `attempts.{key}`, set `lockedUntil.{key}` (with `attempts.{key}` back to 0) and set `hintsUsed.{key}` on their own team doc;
- from step 7a: a team member may increment only `walked.{their uid}`, set `finishedAt` only once (server time) and write only `events/{id}/feedback/{their uid}`; 7c reads `finishedAt`, `walked` and the feedback;
- from step 6c: a team member may write `photoApprovals.{key}` only as `{status: 'pending', url, at}`; only an organiser may set `approved` / `denied` (with `reason`);
- whether "Editează" on team details is for the captain only, decided with
  the rules.
Deploying the functions and the rules stays Victor's call.
