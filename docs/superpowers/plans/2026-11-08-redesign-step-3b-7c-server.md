# Steps 3b and 7c: Rules, Team Functions and Results Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make registering and joining work for real, lock the database down, and work out places, XP, badges, crew stats and the season when an event ends.

**Architecture:** `firestore.rules` tested on the emulator; the five callables already specified in the step 3 plan, one file each in `functions/src/teams/`; a pure `functions/src/results/` module (ranking, XP, badges, season points) driven by a Firestore trigger and a scheduled job; small app additions so what the server now writes is shown.

**Tech Stack:** Firebase Functions v2 (Node 20, TypeScript), firebase-admin, Firestore rules, `@firebase/rules-unit-testing`, `node --test`, Firebase emulators; Flutter on the app side.

**Spec:** `docs/roadmap/mockups-roadmap.md` (L1.5, L1.6, L2, L7.1, the "Step 3b" carry list, the "7b is done" line), `docs/superpowers/plans/2026-11-04-redesign-step-3-teams-and-invites.md` (Tasks 1 and 3: the rules table, every callable's input, output and transaction, the error reasons).

## Global Constraints

- Branch `redesign/server-3b-7c`, merged with `--no-ff` into `redesign/mockups`. Never push.
- **Never `firebase deploy`.** Everything runs on the emulators with the project `demo-teamxperience`. Deploying rules replaces the live ones completely and is Victor's call, each time, with a list of what changes.
- Lighter testing: tests first for all of this, since it is logic and data. App widgets get one overflow check per screen. The final Opus review stays.
- Function errors are `HttpsError` with `details: {reason}`, using the reasons in the step 3 plan; the app already maps them. A signed-out call is `unauthenticated` with `reason: 'notSignedIn'`.
- Dart: no `x!`, one widget per file, one controller per screen, colours from `context.colors`.
- Keep compiled tests out of a deploy. Compare with Task 2's carry-over: quote the test glob, add `@types/node`, escape the combining-mark range, fold Ş/Ș in `nameKey`.
- `firestore.rules` must stay in step with every client write; a write a rule forgets fails silently on a phone in the middle of a game.

## Decisions (Victor can overrule any of these)

1. **Emulator:** pin `firebase-tools@13.35.1` as a dev dependency of `functions/`, because version 14 on this machine needs Java 21 and this machine has Java 17. Nothing is installed on the system. The emulator's jar is downloaded on first run into the Firebase cache.
2. **Live rules:** Victor pastes what the console shows before any deploy. The rules are written from the table in the meantime, and the comparison happens as soon as they arrive.
3. **XP** (roadmap): 100 for a finished game, 20 per mission solved, +50 with no hints. **Each badge earned gives 50 XP** (the roadmap says "badges give XP too" without a number).
4. **Who gets results:** every member of a team that started. A team that never started gets nothing. Finishing all missions is what counts as a "finished game"; `stats.games` counts every game started.
5. **Badge rules from the catalogue's wording:** `night` = the team's last action after 20:00 Bucharest time; `photo` = any approved photo, since the puzzle `badge` field was dropped; `fast` = a mission solved under 5 minutes after the previous one (or the team's start); `crew` = `userIds.length >= numberOfMembers`; `noHints` = finished with no hint opened.
6. **Seasons by calendar, no admin screen:** `seasons/2026-autumn`, "Toamna 2026" (Sep–Nov), Iarna (Dec–Feb, named for the December year), Primăvara (Mar–May), Vara (Jun–Aug), by the event's date in Bucharest. The function creates the season doc when missing. Points as in the roadmap: 100, 75, 60, then 50 minus 5 per place, never under 10.
7. **Crews only:** season points and crew stats go to a team's `crewId`; an old team with no crew is ranked but scores neither.
8. **Registering again uses the crew.** A captain with crews picks one on the register form or makes a new team; this is what makes crew stats and the season mean anything.
9. **"Editează" on team details stays for the captain,** enforced by the rules (`phoneNumber` only when `captainUid` is the caller; an old team with no `captainUid` lets any member).
10. **Storage rules are out of scope:** none are in the repo and the console's stay as they are. Noted in `docs/known-issues.md`.
11. **Hint on results:** a stopped event still gets results. Places rank by the existing leaderboard rule, ported to TypeScript and checked against the same cases as `test/service/` leaderboard tests.

## Review Focus

1. A client write a rule forgets: every update under `events/*/teams/*`, `users/*` and `feedback` must pass as the phones send it, or a game breaks silently.
2. Results run twice (the stop trigger, the schedule, a retry after a crash halfway): no XP, stat, standing or memory counted twice.
3. Two teammates join at the same moment for the last free place: exactly one gets in. Two captains register the same name at once: one `nameTaken`.
4. A player cannot give themselves XP, a badge, a role, a place or an approval, or change another team, through any field.
5. A huge event: more than 500 writes must not break a batch; results for a team whose member's user doc is missing skip that member and carry on.

---

### Task 1: Emulator and rules

**Files:**
- Create: `firestore.rules`, `firestore.indexes.json`, `functions/test/helpers.ts`, `functions/test/rules.test.ts`
- Modify: `firebase.json` (`firestore` block; `emulators`: firestore 8080, functions 5001, auth 9099, `singleProjectMode: true`), `functions/package.json` (`test` script through the pinned `firebase-tools`, `@firebase/rules-unit-testing`, `@types/node`), `functions/tsconfig.json` if tests need it, `docs/platform-and-config.md` (emulators line), `docs/services-and-backend.md` (a "Security rules" section)

**Interfaces:**
- Produces: `npm --prefix functions test` = `firebase emulators:exec --only firestore,auth,functions --project demo-teamxperience "node --test 'lib/test/*.test.js'"` after `tsc`.

- [ ] **Step 1: Audit every client write.** Grep `lib/backend` and `lib/service` for `.update(`, `.set(`, `.add(`, `.delete(`, `batch`. List each one in the plan's ledger with the rule that allows it.
- [ ] **Step 2: Failing tests,** one each, seeded with a user, an admin, an event, a team (members u1, u2, captain u1), a message, a crew, an invite code:
  - the step 3 plan's Task 1 list (reads, own user doc, role, members and non-members on teams, messages, crews, invite codes, admin writes);
  - a member sets `presence.{own uid}`, not another's; `missionCompletedAt.{i}` only when absent; increments `attempts.{key}`; sets `lockedUntil.{key}` with `attempts.{key}` back to 0; sets `hintsUsed.{key}`;
  - a member adds to `walked.{own uid}` only, and not less than before; sets `finishedAt` once, with server time; writes `events/{e}/feedback/{own uid}` only;
  - a member writes `photoApprovals.{key}` only as `{status: 'pending', url, at}`; only an admin sets `approved` or `denied`;
  - a member sets `unreadByAdmin` to `{text, at}`; only an admin deletes it;
  - nobody but an admin changes `place`; no player writes their own `xp`, `level`, `stats`, `badges` or `memories`; a player reads their own `memories`, not another's; anybody signed in reads `seasons` and standings, nobody writes them; `resultsComputedAt` on an event is written by no client;
  - `phoneNumber`: the captain yes, another member no, any member on a team with no `captainUid`.
- [ ] **Step 3: Run.** Expected: FAIL. If the emulator will not start, stop and tell Victor exactly what it says.
- [ ] **Step 4: Write `firestore.rules`** with `diff(...).affectedKeys().hasOnly([...])`. Run until green. Commit: `Firestore rules for every flow the app has`.

### Task 2: The carry-overs from step 3's Task 2

**Files:** `functions/src/teams/names.ts`, `codes.ts`, `functions/src/test/*`, `functions/.gitignore` or `firebase.json` `ignore`.

- [ ] **Step 1:** Failing test: `nameKey` folds Ş/Ș and Ţ/Ț alike. Fix it, escape the combining-mark range, quote the glob, keep compiled tests out of a deploy. Commit: `Team name and test script fixes`.

### Task 3: The five callables

**Files:**
- Create: `functions/src/teams/{shared,errors,notify,check_team_name,create_crew,register_team,preview_invite,join_team}.ts`, `functions/test/teams.test.ts`
- Modify: `functions/src/index.ts`, `docs/services-and-backend.md`

**Interfaces:** exactly the table and transactions in the step 3 plan's Task 3, with these from the carry list: `previewInvite` sends the team's members when there is a next team, else the crew's; `joinTeam` by a player already a member returns `{crewId, eventIds}` of their current events (a join that timed out but committed) rather than failing, and the app's `alreadyMember` path stays for the screen that already knows; `missionCompletedAt` is not touched here.

- [ ] **Step 1: Failing emulator tests:** the step 3 plan's Task 3 list, including the concurrent join, the concurrent name, the already-in-a-team case and crew registration; plus a signed-out call gives `unauthenticated` with `notSignedIn`; `joinTeam` retry returns the event ids.
- [ ] **Step 2: Run, watch them fail.** Step 3: **Implement,** run until green. Commit: `Functions: register a team, check a name, preview and join by invite code`.

### Task 4: `onChatMessage` and mission stamps

**Files:** `functions/src/index.ts`, `lib/backend/repo/teamRepo.dart`

- [ ] **Step 1:** Failing test: an admin message with `announcement: true` sends no push; a plain one does. Implement, with the function split so it can be tested without FCM.
- [ ] **Step 2:** `TeamRepo.updateMissionProgress` writes `missionCompletedAt.{i}` in a transaction, only when absent, so a second phone or a replay does not move the tie-break. No seam: read through. Commit: `One push per announcement; a mission's time is set once`.

### Task 5: The results, pure

**Files:** Create `functions/src/results/{ranking,xp,badges,season}.ts`, `functions/src/test/results.test.ts`

**Interfaces:**
- `rankTeams(teams, missionCount)`: the Dart leaderboard rule, same cases.
- `seasonPoints(place)`: `100, 75, 60`, then `max(10, 50 - 5 * (place - 4))`.
- `seasonOf(date)`: `{id: '2026-autumn', name: 'Toamna 2026', startsAt, endsAt}`, in Bucharest time; December belongs to that winter, January and February to the one before.
- `playerResult(team, place, missionCount, event, previous: {xp, stats, badges})`: `{xp, level, stats, badges, memory}`. `memory` is `{eventName, date, place, totalTime (whole minutes), photoUrls}` with approved photos only and `date` a Timestamp.

- [ ] **Step 1: Failing tests:** points at places 1 to 15; seasons at each boundary and in January; XP for finished, stopped and no-hint games; each of the twelve badges earned and not, and never twice; `km10`, `km50`, `games5`, `podium3`, `missions50` counting previous stats; a badge's 50 XP; the level name at each threshold, matching `home_texts.dart`; `walked` uses the longest phone; a team with nothing solved.
- [ ] **Step 2: Implement, run until green.** Run: `npm --prefix functions run test:unit`. Commit: `Results: places, XP, badges and season points`.

### Task 6: `onEventFinished`

**Files:** Create `functions/src/results/apply_results.ts`, `functions/src/results/on_event_finished.ts`, `functions/test/results.emulator.test.ts`. Modify `functions/src/index.ts`, `docs/services-and-backend.md`, `docs/data-model.md`.

**Interfaces:**
- `applyResults(db, eventId, now)`; `onEventStopped` (`onDocumentUpdated` on `events/{e}`, `isStopped` false to true); `closeExpiredEvents` (`onSchedule` every 15 minutes, events with `dateEvent` + 3 h passed and no `resultsComputedAt`, excluding drafts).
- Idempotent per person and crew, so a crash halfway resumes: one transaction per player (memory missing, then apply xp, stats, badges, memory), one per crew (`crews/{c}/results/{eventId}` missing, then apply stats, standings), and `resultsComputedAt` last. Team `place`s are set in batches of at most 400.

- [ ] **Step 1: Failing emulator tests:** two teams and a stop: places, each player's xp, stats, badges and memory, crew stats, standings; running twice changes nothing; a crash simulated after half the players, then a rerun, counts nobody twice; a member with no user doc is skipped; an old team with no crew; 450 teams; the schedule picks only expired events with no results and no drafts.
- [ ] **Step 2: Implement, run until green.** Commit: `onEventFinished: results when an event stops or runs out`.

### Task 7: The app shows it

**Files:**
- Modify: `lib/model/crew.dart` (`stats{games, wins, distanceMeters}`), `lib/features/register_team/...` (crew choice; passes `crewId`), `lib/features/teams/...` (the crew card's "3 jocuri · 1 victorie · 31 km"; the season leaderboard of mockup 03), `lib/features/shell/...` and `profile_controller.dart` (the user-document watch moves to the shell, so Home's numbers refresh for a player who never opens Profil), `lib/service/team_service/team_service.dart`, `lib/backend/repo/crew_repo.dart`
- Create: `lib/model/season_standing.dart`, `lib/backend/repo/season_repo.dart`, `lib/features/teams/widgets/season_leaderboard.dart`
- Test: `test/model/crew_stats_test.dart`, `test/model/season_standing_test.dart`, `test/features/teams/*`, `test/features/register_team/*`

- [ ] **Step 1: Failing tests:** `Crew.fromMap` reads stats, with defaults for crews without them; `SeasonStanding.fromMap`; the leaderboard sorts by points, highlights the player's crew, says so when empty; `RegisterTeamController` passes the chosen `crewId`, none for a new team; a watch on the user doc updates `UserProvider`.
- [ ] **Step 2: Implement.** One overflow check per changed screen. Run: `flutter test test/features/teams test/features/register_team test/model --timeout 60s`. Commit: `Crew stats, the season leaderboard, registering an existing crew`.

### Task 8: Docs and final

- [ ] **Step 1:** `docs/services-and-backend.md`, `docs/data-model.md`, `docs/features.md`, `docs/known-issues.md`, CLAUDE.md (drop "NOT built yet"), the roadmap (3b and 7c done, a **deploy checklist** for Victor in order: rules comparison, functions, rules, then a real registration).
- [ ] **Step 2:** `npm --prefix functions test`, `flutter analyze`, `flutter test --timeout 60s`. Expected: all pass. Commit.
- [ ] **Step 3:** Whole-branch review on Opus, one fix pass, the suites once more, merge with `--no-ff`, delete the branch, report rulings, deferred minors and what is untested. **Do not deploy.**
