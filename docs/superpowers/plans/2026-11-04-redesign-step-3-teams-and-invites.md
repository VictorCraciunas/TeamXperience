# Redesign step 3: teams and invite codes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A captain registers a team on one short screen and gets an invite code. Teammates type the code, see the team and join it, and the event appears on their phones. The team lasts beyond one event (mockups 04 and 03-Echipe).

**Architecture:**
- **Teams that last.** A new top-level `crews/{crewId}` holds the team across events: name, captain, members and invite code. Registering for an event still writes `events/{eventId}/teams/{teamName}` (every game screen reads it), now linked to the crew by `crewId`.
- **Writes go through Cloud Functions.** Registering, checking a name, previewing an invite and joining are callable functions using the Admin SDK in transactions. That keeps capacity, unique names and codes right, and it means no client can list invite codes.
- **Security rules.** A `firestore.rules` file comes into the repo for the first time. It keeps every flow that works today and locks `crews` and `inviteCodes` to the functions.
- **Flutter side.** The app calls the functions through `cloud_functions`. A pure-Dart layer maps every result and error to the screens.

**Tech Stack:**
- Flutter, provider, `cloud_functions` (new), and `share_plus` / `Clipboard` for the code
- Cloud Functions v2 in TypeScript (Node 20), `firebase-admin`, and `firebase-functions-test` (already a dev dependency)
- Firebase Emulator Suite for the function and rules tests, with Node's built-in `node:test` (no new test framework)

**Spec:**
- `docs/roadmap/mockups-roadmap.md`: L1.4 (team fields for crews), L1.5 (`crews`, `inviteCodes`), L1.6, L2 and U3.2, plus the team card and code part of U3.4; step 3 of "Order and size".
- Visual reference: `docs/roadmap/mockups/04-register-and-join-team.html` and the right-hand phone of `03-events-and-teams-tabs.html`.

**Not in this step:**
- The crew's stats ("3 jocuri · 1 victorie · 31 km") and the season leaderboard: step 7, when results exist.
- The five-tab shell: step 4. Until then the Echipe screen opens from Profil.
- Hiding the captain's phone and email from other teams: that needs a data split, so it is a follow-up. The rules keep today's read access.
- Leaving a team, removing a member, renaming a crew: not in the mockups.

## Global Constraints

- **Branch:** `redesign/step-3-teams` from `redesign/mockups`. Merge into `redesign/mockups` only. Never `main`, never push.
- **Deploying is Victor's call.** `firebase deploy` (functions or rules) changes the live project `teamxperience-dadc6`, so ask Victor before each deploy, with what will change. All tests run on the emulators with the project id `demo-teamxperience`, so nothing touches production.
- **Rules:** before `firestore.rules` is written, Victor pastes the rules currently live in the Firebase console (Firestore → Rules) into the chat (Task 1, Step 1). Deploying a rules file replaces them completely.
- **UI:** 1 mockup CSS px = 1 logical px, with CSS borders added outside the padding and line height 1.45. Use `OutlineCard` for `.card`.
- **Code:**
  - Colours come from `context.colors`, and `lib/features` contains no colour literals.
  - One widget per file, a controller per screen, and no `x!`.
  - `lib/ui/` takes its copy as parameters.
- **Invite codes:**
  - Shown as `AAA-999` (3 letters, a dash, 3 digits).
  - Stored and compared without the dash, upper-cased: `VLP482`.
  - Codes never use `O` or `I` among the letters, which are confused with 0 and 1.
- **Team names:**
  - The name is trimmed and 2–30 characters long.
  - It cannot contain `/`, `.` at the start or end, or `__`; these are Firestore document-id limits, because the team doc id is its name.
  - Names are unique per event, ignoring case: "Vulpile" and "vulpile" clash.
- **Copy:** every user-visible string is Romanian, as in the mockups. Function errors reach the app as codes, and the app maps them to text (Task 5).
- **Checks after every task:**
  - Flutter: `flutter analyze` shows no new issues and `flutter test` passes.
  - Functions: `npm --prefix functions run build` and `npm --prefix functions test` pass.
- Commit messages end with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- **Docs to update:** `docs/data-model.md`, `docs/services-and-backend.md`, `docs/features.md` and `docs/screens.md`, in the task that changes what they describe.

## Review Focus

1. **Two teammates join at the same moment for the last free place.** Exactly one gets in; the other sees "Echipa e completă", and the team never goes over its size. Covered in Task 3 with a concurrent-join emulator test.
2. **A player already in another team for the same event types a code.** They must be refused with "Ești deja în echipa X la acest eveniment", not added to two teams. Covered in Task 3.
3. **Codes typed loosely** ("vlp 482", "VLP-482", " vlp482 "): all must find the team; a wrong or unknown code gives "Codul nu există" without saying which part was wrong. Covered in Tasks 2 and 3.
4. **A captain registers the same crew twice for one event, or two captains pick the same name at once.** The second attempt fails with "Numele e luat" or "Echipa e deja înscrisă". Covered in Task 3.
5. **Weak signal on the join screen.** A double tap on "Intră în Vulpile" joins once, and a network error shows "Nu a mers. Verifică internetul." instead of a stuck button. Covered in Task 9.

---

### Task 1: Firestore rules and the emulator setup

**Files:**
- Create: `firestore.rules`, `firestore.indexes.json` (empty indexes), `functions/test/rules.test.ts`, `functions/test/helpers.ts`
- Modify: `firebase.json` (add `"firestore": {"rules": "firestore.rules", "indexes": "firestore.indexes.json"}` and an `"emulators"` block: firestore 8080, functions 5001, auth 9099, `"singleProjectMode": true`), `functions/package.json` (scripts `test` and `test:emulator`, plus dev dependency `@firebase/rules-unit-testing`), `functions/tsconfig.json` (include `test`)
- Docs: `docs/services-and-backend.md` (a "Security rules" section)

**Interfaces:**
- Produces: the rules below, and `npm --prefix functions test`, which runs `firebase emulators:exec --only firestore,auth,functions --project demo-teamxperience "node --test lib/test/"` after `tsc`.

The rules, with `isAdmin()` = `get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'ADMIN'` and `signedIn()` = `request.auth != null`:

| path | read | write |
|---|---|---|
| `users/{uid}` | signedIn | create when `request.auth.uid == uid` and `role == 'USER'`; update when `request.auth.uid == uid` and `role` is not changed; admins any |
| `events/{e}` | signedIn | admin |
| `events/{e}/teams/{t}` | signedIn (event pages count teams, the map shows them) | create: no client (functions only). Update by an admin; or by a member (`request.auth.uid in resource.data.userIds`), touching only `missionProgress`, `puzzleNumber`, `hasStarted`, `hasFinished`, `latitude`, `longitude`, `photoApprovals` and `phoneNumber`. Delete by an admin. |
| `events/{e}/teams/{t}/messages/{m}` | admin or a team member | create by an admin or a team member; update by an admin (photo approval); delete by an admin |
| `stire/{id}`, `categories/{id}` | signedIn | admin |
| `crews/{id}` | a member (`request.auth.uid in resource.data.memberUids`) or an admin | none (functions only) |
| `inviteCodes/{code}` | none | none |
| anything else | none | none |

- [ ] **Step 1: Ask Victor for the live rules.** Ask him to paste what Firebase console → Firestore Database → Rules shows. Compare it with the table: anything the live rules allow that the table forbids, and that the app needs, goes into the table. Record the comparison in the ledger. Do not continue without his answer.
- [ ] **Step 2: Write the failing rules tests** in `functions/test/rules.test.ts`, using `@firebase/rules-unit-testing` against the emulator. Seed a user, an admin, an event, a team (members u1 and u2), a message, a crew and an invite code. Then assert, one test each:
  - a player reads events, teams and news
  - a player updates their own user doc, but not someone else's and not their own `role`
  - a member updates `missionProgress` and `phoneNumber`, but not `numberOfMembers`, `userIds` or `name`
  - a new user doc with `role: 'ADMIN'` is refused; with `'USER'` it is allowed
  - a non-member cannot write a team
  - nobody but an admin deletes a team
  - a member reads and writes messages; a non-member does neither
  - a player cannot create a team
  - a member reads their crew; a non-member doesn't
  - nobody reads or writes `inviteCodes`
  - an admin writes events and news; a player doesn't
- [ ] **Step 3: Run** `npm --prefix functions test`. Expected: the tests fail (no rules file, so the emulator denies everything, or every test errors). If the emulator refuses to start because Java is too old, tell Victor that firebase-tools 14 needs Java 21 and stop until it is installed; Java 17 is on the PC today.
- [ ] **Step 4: Write `firestore.rules`** as in the table, then run the tests until they pass.
- [ ] **Step 5: Commit** with the message "Firestore rules that keep today's flows and lock crews and invite codes". Do not deploy.

### Task 2: Invite codes and team-name rules (functions, pure)

**Files:**
- Create: `functions/src/teams/codes.ts`, `functions/src/teams/names.ts`, `functions/test/codes.test.ts`, `functions/test/names.test.ts`

**Interfaces:**
- Produces, in `codes.ts`:
  - `export function codeLetters(teamName: string): string`, which gives 3 upper-case letters. Strip diacritics (ă→A, ș→S, ț→T, î→I, â→A), drop everything but A–Z, and take the first letter, then the next consonants in order. Fill with the next letters if there are fewer than 3, then with `X`. Replace `O` with `Q` and `I` with `J`. Examples: `"Vulpile"` → `"VLP"`, `"Lupii de Cetate"` → `"LPD"`, `"Oaia"` → `"QXX"`, `"Ii"` → `"JXX"`.
  - `export function makeCode(teamName: string, random: () => number): string`: the letters plus 3 digits from 100–999, with no dash (`"VLP482"`).
  - `export function normaliseCode(input: string): string`: upper-case, keep only A–Z and 0–9 (`" vlp-482 "` → `"VLP482"`).
  - `export function isWellFormedCode(code: string): boolean`: `/^[A-Z]{3}[0-9]{3}$/` on the normalised value.
  - `export function displayCode(code: string): string`: `"VLP482"` → `"VLP-482"`.
- Produces, in `names.ts`:
  - `export function cleanTeamName(input: string): string`: trims and collapses inner spaces.
  - `export function teamNameProblem(name: string): 'short' | 'long' | 'characters' | null`, on the cleaned name. Under 2 characters is short; over 30 is long; `/`, a leading or trailing `.`, or `__` is characters.
  - `export function nameKey(name: string): string`: the cleaned name lower-cased, used to compare names ignoring case.

- [ ] **Step 1: Write the failing tests.** Cover each example above, plus:
  - `makeCode` with `random = () => 0` gives `"VLP100"`, and with `() => 0.999` gives `"VLP999"`.
  - `normaliseCode('vlp 482')` gives `'VLP482'`.
  - `isWellFormedCode('VL4823')` is false.
  - `teamNameProblem` returns `'short'` for `'A'`, `'long'` for 31 characters, `'characters'` for `'A/B'`, `'..'` and `'a__b'`, and null for `'Vulpile'`.
  - `nameKey(' Vulpile ')` equals `nameKey('VULPILE')`.
- [ ] **Step 2: Run** `npm --prefix functions test`. Expected: FAIL, because the modules don't exist.
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run** it. Expected: PASS.
- [ ] **Step 5: Commit** with the message "Functions: invite codes and team-name rules".

### Task 3: Team callables (functions)

**Files:**
- Create: `functions/src/teams/register_team.ts`, `functions/src/teams/check_team_name.ts`, `functions/src/teams/preview_invite.ts`, `functions/src/teams/join_team.ts`, `functions/src/teams/create_crew.ts`, `functions/src/teams/errors.ts`, `functions/src/teams/notify.ts`, `functions/test/teams.test.ts`
- Modify: `functions/src/index.ts` (export the five), `docs/services-and-backend.md` (the new functions, their inputs, outputs and error codes)

**Interfaces:**
- Consumes: Task 2.
- Produces: callables made with `onCall` (v2, region `us-central1`, like the existing functions). Every one requires `request.auth`, else `unauthenticated`. Errors are `HttpsError` with code `failed-precondition` and `details: {reason}`, where `reason` is one of:

  `notSignedIn`, `eventNotFound`, `enrolmentClosed`, `eventFull`, `nameTaken`, `nameInvalid`, `sizeInvalid`, `alreadyInTeam`, `crewAlreadyRegistered`, `notCaptain`, `codeUnknown`, `teamFull`, `alreadyMember`, `rulesNotAccepted`.

  The Flutter side (Task 5) maps `reason`.

| callable | input | output | does |
|---|---|---|---|
| `checkTeamName` | `{eventId, name}` | `{free: boolean, problem?: 'short'\|'long'\|'characters'}` | `free` is false when another team of the event has the same `nameKey(name)`. Read every team of the event and compare `nameKey(team.name)`, because teams made before this step have no `nameKey` field. |
| `createCrew` | `{name}` | `{crewId, inviteCode}` | Creates `crews/{auto}` with the caller as captain and only member, plus `inviteCodes/{code}` holding the `crewId`. The code is tried up to 10 times in a transaction until it is unused. |
| `registerTeam` | `{eventId, name, size, phone, rulesAccepted, photoConsent, crewId?}` | `{teamName, crewId, inviteCode, skippedUids: string[]}` | One transaction (below) |
| `previewInvite` | `{code}` | `{crewId, crewName, captainName, members: [{uid, displayName, initials}], event?: {eventId, name, dateEvent (ISO), teamName, size, count}, alreadyMember}` | Read-only. `event` is the crew's next team in an event that isn't over (`dateEvent` + 3 h in the future, not stopped), the soonest first. |
| `joinTeam` | `{code}` | `{crewId, eventIds: string[]}` | One transaction (below) |

**`registerTeam` transaction**, refusing at the first failure:
1. Read the event: `eventNotFound` if missing.
2. Enrolment must be open (start ≤ now, deadline not passed, using the same midnight = end-of-day rule as `enrolment_window.dart`, and now before `dateEvent`), else `enrolmentClosed`.
3. `size` must be within the event's `teamSizeMin`–`teamSizeMax` (default 2–6), else `sizeInvalid`.
4. `rulesAccepted` must be true, else `rulesNotAccepted`. `photoConsent` is stored as given.
5. The name must pass `teamNameProblem`, else `nameInvalid`; and no team in the event may have the same `nameKey` (computed from each team's `name`, as in `checkTeamName`), else `nameTaken`.
6. The caller must not be in any team of this event (`userIds` array-contains), else `alreadyInTeam`.
7. When `maxTeams` is set, fewer teams than that must exist, else `eventFull`.
8. With a `crewId`: the caller must be its captain (`notCaptain`), the crew must have no team in this event yet (`crewAlreadyRegistered`), and its members must fit in `size` (`sizeInvalid`). None of its members may be in another team of this event; members who are get left out of this team, and the result lists them as `skippedUids`. Without a `crewId`, create the crew and its code as `createCrew` does.
9. Write the team doc `events/{e}/teams/{cleanName}`:
   - `name`, `nameKey`, `crewId`, `inviteCode`
   - `captainUid`, plus `captainName` and `captainEmail` from `users/{uid}` (`firstName lastName`, `email`)
   - `phoneNumber`, `numberOfMembers: size`
   - `userIds` and `members` (`[{uid, displayName, initials}]`) for the crew members who fit
   - `teamMembers`: the names joined by `", "` (old screens read it)
   - `rulesAcceptedAt: serverTimestamp`, `photoConsent`
   - the existing progress fields at their defaults (`missionProgress: 0`, `puzzleNumber: 0`, `hasStarted: false`, `hasFinished: false`, `latitude: 0`, `longitude: 0`, `photoApprovals: {}`)
10. Add the `eventId` to `registeredEventIds` of every member written (`arrayUnion`).

**`joinTeam` transaction:**
1. Normalise the code and look up `inviteCodes/{code}`: `codeUnknown` if missing or malformed.
2. Read the crew: `alreadyMember` if the caller is in `memberUids`.
3. Add the caller to the crew's `memberUids` / `members`.
4. For every team of this crew in an event that isn't over:
   - if the caller is in another team of that event, skip it;
   - if `userIds.length >= numberOfMembers`, skip it;
   - otherwise add the caller to `userIds` / `members` / `teamMembers` and the event to their `registeredEventIds`.
5. When the next event's team is full and the caller was going to join because of it, refuse with `teamFull` and change nothing (the preview showed that event). When the caller is already in another team for that next event, refuse with `alreadyInTeam` and the team name in `details.teamName`. Otherwise the crew join stands even when there is no event at all.
6. Return the `eventIds` joined.
7. After the commit, `notify.ts` sends the captain an FCM message: title "Echipa ta crește", body "{displayName} a intrat în {crewName}". Use the token on `users/{captainUid}` with the same `getMessaging()` call style as `onChatMessage`. A send failure is only logged.

`initials`: the first letter of the first name and of the last name, upper-case ("Victor Crăciunaș" → "VC").

- [ ] **Step 1: Write the failing emulator tests** in `functions/test/teams.test.ts`. Use `firebase-functions-test` `wrap()` against the Firestore emulator. Seed `users/u1..u5` with names and an event dated in the future with enrolment open, `teamSizeMin 2`, `teamSizeMax 4` and `maxTeams 2`. Tests:
  - `registerTeam` by u1 with name "Vulpile", size 4: returns a code matching `/^VLP\d{3}$/`; the team doc has `userIds ['u1']`, `members[0].initials 'VC'` (when u1 is Victor Crăciunaș), `teamMembers`, `nameKey 'vulpile'`; u1's `registeredEventIds` contains the event; a crew and an invite code exist.
  - The same name with other capitals by u2 → `nameTaken`.
  - u1 registering again with another name → `alreadyInTeam`.
  - Size 5 → `sizeInvalid`. Rules not accepted → `rulesNotAccepted`. A deadline in the past → `enrolmentClosed`. A third team with `maxTeams 2` → `eventFull`.
  - `checkTeamName` for "vulpile " → `{free: false}`, for "Lupii" → `{free: true}`, for "A" → `{free: false, problem: 'short'}`.
  - `previewInvite` with `'vlp-xxx'` (the real digits, typed loosely) → the crew, captain and members, plus `event.count 1` and `size 4`. With `'ZZZ999'` → `codeUnknown`.
  - `joinTeam` by u2 → u2 is in the crew and the team, `registeredEventIds` has the event, and `eventIds` is `[eventId]`. Again by u2 → `alreadyMember`.
  - **Review Focus 1:** with the team at 3 of 4, u4 and u5 call `joinTeam` together (`Promise.allSettled`). Exactly one is fulfilled, the other is rejected with `teamFull`, and the team has 4 `userIds`.
  - **Review Focus 2:** u3 is in team "Lupii" of the same event and joins Vulpile's code → `alreadyInTeam` with `details.teamName 'Lupii'`, and the crew is unchanged.
  - **Review Focus 4:** two `registerTeam` calls with the same name at once → one `nameTaken`.
  - `registerTeam` with the `crewId` of an existing crew whose member is u2 → the team's `userIds` are `['u1', 'u2']`. A second registration of that crew in the same event → `crewAlreadyRegistered`. By u2, who isn't captain → `notCaptain`.
- [ ] **Step 2: Run** `npm --prefix functions test`. Expected: FAIL, because the functions don't exist.
- [ ] **Step 3: Implement** each callable in its own file. Shared reads (event, enrolment check, a user's display name and initials) go in `functions/src/teams/shared.ts`.
- [ ] **Step 4: Run** the tests. Expected: all PASS, including the rules tests from Task 1.
- [ ] **Step 5: Commit** with the message "Functions: register a team, check a name, preview and join by invite code". Do not deploy.

### Task 4: Crew and team models (Flutter)

**Files:**
- Create: `lib/model/crew.dart`, `lib/model/team_member.dart`
- Modify: `lib/model/team.dart`, `docs/data-model.md` (`crews`, `inviteCodes`, the new team fields, and the Firestore layout block)
- Test: `test/model/crew_test.dart`, `test/model/team_fields_test.dart`

**Interfaces:**
- Produces:
  - `class TeamMember { final String uid; final String displayName; final String initials; factory fromMap; Map toJson(); }`
  - `class Crew { final String id; final String name; final String captainUid; final List<String> memberUids; final List<TeamMember> members; final String inviteCode; factory Crew.fromMap(String id, Map<String, dynamic> map); String get displayCode; TeamMember? get captain; }`
    - `displayCode` gives `"VLP-482"`.
    - `captain` is the member whose `uid` is `captainUid`.
  - New `Team` fields: `crewId` (`String?`), `captainUid` (`String?`), `members` (`List<TeamMember>`, default `[]`), `inviteCode` (`String?`), `photoConsent` (`bool`, default false), with `String? get displayCode` and `List<TeamMember> get memberList`.
    - `memberList` is `members`, or for old teams the names in `teamMembers` split by comma, with initials and an empty uid.
    - `toJson` and `fromMap` carry the fields. `rulesAcceptedAt` is server-written, so the app doesn't model it.
- Also produce, in `lib/utils/invite_code.dart`, the Dart twins of Task 2: `normaliseCode`, `isWellFormedCode` and `displayCode`, with the same rules. Test them with the same examples.

- [ ] **Step 1: Write the failing tests.**
  - `Crew.fromMap` with every field; `displayCode` and `captain`.
  - A `Team` round-trip with the new fields.
  - An old team map (no new keys) gives `members` empty, and `memberList` from `teamMembers: 'Ana Pop, Ion'` gives `[('Ana Pop','AP'), ('Ion','I')]`.
  - The invite-code twins.
- [ ] **Step 2: Run** `flutter test test/model test/utils`. Expected: FAIL.
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run** the tests. Expected: PASS.
- [ ] **Step 5: Commit** with the message "Crew and team member models, invite-code helpers".

### Task 5: Team functions client and messages (Flutter)

**Files:**
- Create: `lib/backend/functions/team_functions.dart`, `lib/backend/repo/crew_repo.dart`, `lib/service/team_service/team_errors.dart`, `lib/service/team_service/invite_preview.dart`
- Modify: `pubspec.yaml` (`flutter pub add cloud_functions`), `lib/service/team_service/team_service.dart`, `lib/service/share_service.dart`
- Test: `test/service/team_service/team_errors_test.dart`, `test/service/team_service/invite_preview_test.dart`

**Interfaces:**
- Produces:
  - `class TeamFunctions`, a thin wrapper over `FirebaseFunctions.instance.httpsCallable(name)` with one method per callable, each returning the decoded `Map<String, dynamic>`. It contains no logic.
  - `enum TeamError`, holding the 14 reasons of Task 3 plus `network` and `unknown`, with `static TeamError fromException(Object e)`:
    - a `FirebaseFunctionsException` with `details['reason']` gives that reason
    - code `unavailable` or `deadline-exceeded` gives `network`
    - anything else gives `unknown`
  - `String teamErrorText(TeamError e, {String? teamName})`:

    | reason | text |
    |---|---|
    | nameTaken | "Numele e luat" |
    | nameInvalid | "Numele are 2–30 de litere, fără /" |
    | sizeInvalid | "Mărimea echipei nu se potrivește" |
    | alreadyInTeam | "Ești deja în echipa {teamName} la acest eveniment" (without a name: "Ești deja într-o echipă la acest eveniment") |
    | crewAlreadyRegistered | "Echipa e deja înscrisă" |
    | notCaptain | "Doar căpitanul poate înscrie echipa" |
    | codeUnknown | "Codul nu există" |
    | teamFull | "Echipa e completă" |
    | alreadyMember | "Ești deja în echipă" |
    | enrolmentClosed | "Înscrierile s-au închis" |
    | eventFull | "Nu mai sunt locuri" |
    | eventNotFound | "Evenimentul nu mai există" |
    | rulesNotAccepted | "Acceptă regulamentul ca să continui" |
    | notSignedIn | "Intră în cont din nou" |
    | network | "Nu a mers. Verifică internetul." |
    | unknown | "Ceva n-a mers. Încearcă din nou." |

  - `class InvitePreview` with `crewId, crewName, captainName, members, alreadyMember` and `InviteEvent? event` (`eventId, name, dateEvent, teamName, size, count`); `factory fromMap`; `String? get slotLine`; `bool get isFull`.
    - `slotLine`: with an event, `'{count} din {size} · tu ești al {count+1}-lea'`, with Romanian ordinals for 2 and up (`'al 2-lea'`, `'al 3-lea'`) and `'primul'` for 1. Without an event, null.
    - `isFull`: `count >= size`.
  - `CrewRepo.streamUserCrews(String uid)`: `crews` where `memberUids` array-contains `uid`, ordered by name.
  - `TeamService` gains:
    - `Future<RegisterResult> registerTeam(...)`
    - `Future<bool?> isTeamNameFree(String eventId, String name)` (null on a network error)
    - `Future<InvitePreview> previewInvite(String code)`
    - `Future<List<String>> joinTeam(String code)`
    - `Future<({String crewId, String inviteCode})> createCrew(String name)`

    The old `addTeam` is deleted, along with its caller in Task 7.
  - `ShareService.shareInvite(BuildContext context, {required String code, required String teamName, required String eventName})` shares the text "Intră în echipa {teamName} la {eventName}: deschide TeamXperience → Echipe → Intră și scrie codul {code}."

- [ ] **Step 1: Write the failing tests.**
  - `teamErrorText` for every reason.
  - `TeamError.fromException` for a fake `FirebaseFunctionsException(code: 'failed-precondition', details: {'reason': 'teamFull'})`, for `unavailable`, and for a plain `Exception`.
  - `InvitePreview.fromMap` and `slotLine` for counts 0, 1 and 2 with size 4 ("0 din 4 · tu ești primul", "1 din 4 · tu ești al 2-lea", "2 din 4 · tu ești al 3-lea"), and `isFull`.
- [ ] **Step 2: Run** the tests. Expected: FAIL.
- [ ] **Step 3: Implement.** `TeamFunctions` and `CrewRepo` are the Firebase seam; they get no unit tests.
- [ ] **Step 4: Run** `flutter test`. Expected: PASS. Fix any test that used `addTeam`.
- [ ] **Step 5: Commit** with the message "Team functions client, error texts and invite preview".

### Task 6: Shared components for teams (UI)

**Files:**
- Create in `lib/ui/components/`:
  - `misc/avatar_stack.dart`
  - `inputs/code_boxes_input.dart`
  - `inputs/size_picker.dart`
  - `team/invite_code_card.dart`
  - `feedback/field_status_line.dart`
- Modify: `lib/dev/component_gallery.dart` (a "Echipe" section with the mockup copy)
- Test: `test/ui/components/team_components_test.dart`

**Interfaces:**
- Produces:
  - `AvatarStack({required List<String> initials, int? total, double size = 28})`:
    - circles in `navy` with `onNavy` initials (11 / w500), each overlapping the one before by 8, with a 2 px `panel` ring
    - when `total` is greater than the circles shown, a last `inset` circle shows `+N`
  - `CodeBoxesInput({required int length, int? dashAfter, required ValueChanged<String> onChanged, ValueChanged<String>? onCompleted, bool error = false, TextInputType keyboardType = TextInputType.text})`:
    - one hidden `TextField` drives the boxes
    - boxes are 38 × 46, radius 10, `panel` fill, 1.5 px `border`; the active box's border is `tick`, and with `error` every border is `danger`
    - characters are mono 20 / w700, upper-cased
    - a dash is drawn after `dashAfter` boxes
    - pasting fills every box; Backspace on an empty box goes back
  - `SizePicker({required int min, required int max, required int value, required ValueChanged<int> onChanged})`:
    - a row of 40 px round buttons
    - the selected one has a `navy` fill with `onNavy` text; the others are `OutlineCard`-style with `text`
  - `InviteCodeCard({required String code, required String shareLabel, required String copyLabel, required VoidCallback onShare, required VoidCallback onCopy, String? caption})`, matching mockup 04's middle phone:
    - the code in mono 26 / w700 on `inset`
    - two buttons: a `navy` fill with `TablerIcons.brand_whatsapp`, and an outlined one with `TablerIcons.copy`
  - `FieldStatusLine({required String text, required FieldStatus status})`, with `enum FieldStatus { neutral, checking, ok, problem }`:
    - 11 px text, with a 13 px icon of `circle_check` (ok, `success`), `alert_circle` (problem, `danger`) or a 10 px `CircularProgressIndicator` (checking)

Sizes not given here come from `docs/roadmap/mockups/04-register-and-join-team.html`; read the CSS there.

- [ ] **Step 1: Write the failing tests.**
  - `AvatarStack(['VC', 'AM'], total: 4)` shows `'VC'`, `'AM'` and `'+2'`.
  - `CodeBoxesInput(length: 6, dashAfter: 3)`: typing `'vlp482'` calls `onCompleted('VLP482')`, shows six characters upper-cased, and shows one dash. With `error` the box border is `AppColors.light.danger`.
  - `SizePicker(min 2, max 6, value 4)`: tapping `'5'` calls `onChanged(5)`, and `'4'` has the navy fill.
  - `InviteCodeCard`: both callbacks fire on their buttons.
  - `FieldStatusLine` ok shows the check icon.
  - Each passes at 320 / 1.3× with no exception.
- [ ] **Step 2: Run** `flutter test test/ui/components/team_components_test.dart`. Expected: FAIL.
- [ ] **Step 3: Implement.** Add the gallery section.
- [ ] **Step 4: Run** `flutter test test/ui test/dev`. Expected: PASS.
- [ ] **Step 5: Commit** with the message "Avatar stack, code boxes, size picker, invite code card".

### Task 7: Register screen (mockup 04, left phone)

**Files:**
- Create: `lib/features/register_team/logic/team_name_check.dart`, `lib/features/register_team/widgets/register_form.dart`, `lib/features/register_team/widgets/consent_row.dart`
- Modify: `lib/features/register_team/controller/register_team_controller.dart` (rewritten), `lib/features/register_team/screen/register_team_screen.dart` (rewritten)
- Delete: `lib/features/register_team/widgets/step1.dart`, `step2.dart`, `step3.dart`, and their entries in `test/ui/colour_allowlist.txt`
- Test: `test/features/register_team/team_name_check_test.dart`, `test/features/register_team/register_form_test.dart`

**Interfaces:**
- Consumes: Tasks 5 and 6.
- Produces:
  - `class TeamNameCheck`, with `TeamNameCheck({required Future<bool?> Function(String) isFree, Duration debounce = const Duration(milliseconds: 400)})`, `ValueListenable<(FieldStatus, String)> state` and `void onChanged(String name)`. The states, in order:
    - empty: `(neutral, '')`
    - a local problem (`cleanTeamName` + the Dart twin of `teamNameProblem`): `(problem, 'Numele are 2–30 de litere, fără /')`
    - while waiting: `(checking, 'Verificăm numele…')`
    - free: `(ok, 'Numele e liber')`
    - taken: `(problem, 'Numele e luat')`
    - network null: `(neutral, 'Nu am putut verifica numele')`

    Only the last call's answer counts. The Dart twin of `teamNameProblem` and `cleanTeamName` go in `lib/utils/team_names.dart`, tested with Task 2's examples.
  - `RegisterTeamController` (a `ChangeNotifier`) holding:
    - `nameController`, `phoneController`, `int size` (starting at `event.teamSizeMax` clamped to 4), `bool rulesAccepted`, `bool photoConsent`, `bool sending`
    - `TeamNameCheck nameCheck`
    - `String? get blocker`: the first reason the button is disabled — empty name, name not ok, empty phone, or rules not accepted
    - `Future<void> submit()`: calls `TeamService.registerTeam`, then `UserProvider.addRegisteredEvent`, then `pushReplacementNamed(Routes.inviteResult, arguments: {'event': event, 'teamName': ..., 'inviteCode': ...})`. Errors are shown with `MySnackBars.errorSnackBar` and `teamErrorText`. It does nothing while `sending`.

Layout from mockup 04's left phone (CSS px):
- `page` background, with `MyAppBar(appBarText: 'Înscrie echipa')`.
- Under the app bar, `'{event.name} · {dayAndMonth(dateEvent)}'` in `smallMuted`.
- "Numele echipei" with `AppTextField` and the `FieldStatusLine` under it.
- "Câți veți fi?" with the `SizePicker`, from `event.teamSizeMin` to `teamSizeMax`.
- "Telefonul căpitanului" with `AppTextField` (`TextInputType.phone`).
- The note "Numele și emailul le luăm din contul tău." in `smallMuted`.
- Two `ConsentRow`s (checkbox and label): "Accept regulamentul" and "Sunt de acord cu foto și video".
- `AppButton` "Înscrie echipa", disabled while `blocker != null` or `sending`.

- [ ] **Step 1: Write the failing tests.**
  - **`TeamNameCheck`** with a fake `isFree` and `fakeAsync`:
    - typing "Vu", "Vul" and "Vulpile" within 400 ms calls `isFree` once, with "Vulpile"
    - the states above, each in turn
    - an earlier answer arriving after a later one is ignored
  - **`RegisterForm`** (a pure widget taking the controller's values and callbacks):
    - shows the mockup copy
    - the button is disabled until the name is ok, the phone is filled and the rules box is ticked
    - `SizePicker` shows 2–6 for an event with 2–6
- [ ] **Step 2: Run** `flutter test test/features/register_team`. Expected: FAIL.
- [ ] **Step 3: Implement.** The screen builds `RegisterForm` from the controller, and the controller does the work.
- [ ] **Step 4: Run** `flutter test` and `flutter analyze`. Expected: PASS, no new issues.
- [ ] **Step 5: Commit** with the message "Register a team on one short screen".

### Task 8: Invite result screen (mockup 04, middle phone)

**Files:**
- Create: `lib/features/invite_result/screen/invite_result_screen.dart`, `lib/features/invite_result/controller/invite_result_controller.dart`
- Modify: `lib/constants/routes.dart` (`inviteResult = '/invite_result'`), `lib/main.dart`, `docs/features.md`
- Test: `test/features/invite_result/invite_result_screen_test.dart`

**Interfaces:**
- Consumes: Task 6's `InviteCodeCard` and `AvatarStack`, Task 4's helpers, and `ShareService.shareInvite`.
- Produces:
  - The route arguments `{'event': Event, 'teamName': String, 'inviteCode': String}`.
  - `InviteResultController`:
    - `share()`
    - `copy()`: `Clipboard.setData` with the display code, then a `MySnackBars.successSnackBar` "Cod copiat"
    - `done()`: `Navigator.popUntil` the first route, then push `Routes.eventDetails` with the event (so back leads home)

Layout:
- A success tick.
- The title "Gata. Trimite codul coechipierilor" (`trailHeading`).
- `InviteCodeCard` with "WhatsApp" and "Copiază".
- A row with `AvatarStack([captain initials], total: size)` and `'1 din {size} în echipă'`.
- `AppButton` "Gata" (secondary).

- [ ] **Step 1: Write a failing widget test.** Built with a fake controller: it shows `'VLP-482'`, `'Gata. Trimite codul coechipierilor'` and `'1 din 4 în echipă'`; tapping "Copiază" calls `copy`; there's no exception at 320 / 1.3×.
- [ ] **Step 2: Run** it. Expected: FAIL.
- [ ] **Step 3: Implement.** The screen takes the controller through its constructor (the route builder makes the real one) so the test can pass a fake.
- [ ] **Step 4: Run** `flutter test`. Expected: PASS.
- [ ] **Step 5: Commit** with the message "Invite result: the code to send teammates".

### Task 9: Join screen (mockup 04, right phone)

**Files:**
- Create: `lib/features/join_team/controller/join_team_controller.dart`, `lib/features/join_team/screen/join_team_screen.dart`, `lib/features/join_team/widgets/invite_preview_card.dart`, `lib/features/join_team/logic/join_state.dart`
- Modify: `lib/constants/routes.dart` (`joinTeam = '/join_team'`), `lib/main.dart`, `docs/features.md`, `docs/screens.md`
- Test: `test/features/join_team/join_state_test.dart`, `test/features/join_team/join_team_view_test.dart`

**Interfaces:**
- Consumes: Tasks 5 and 6.
- Produces:
  - `sealed class JoinState`:
    - `Typing`
    - `Looking`
    - `Found(InvitePreview p)`
    - `Problem(String text)`
    - `Joining(InvitePreview p)`
    - `Joined(List<String> eventIds)`
  - `class JoinFlow({required Future<InvitePreview> Function(String) preview, required Future<List<String>> Function(String) join})`:
    - `ValueListenable<JoinState> state`
    - `void codeChanged(String code)`: back to `Typing` while not complete; when it's 6 characters and `isWellFormedCode`, it calls `preview`
    - `Future<void> confirm()`: from `Found` only, ignored while `Joining` (Review Focus 5). Errors become `Problem(teamErrorText(...))`, and a preview whose `isFull` is true becomes `Problem('Echipa e completă')` without calling `join`.
  - `JoinTeamController` wires `JoinFlow` to `TeamService`. On `Joined` it adds each event to `UserProvider` and goes to the event page of the first event, or to the Echipe screen when the list is empty.

Layout from the mockup:
- "Intră într-o echipă" (`MyAppBar`).
- "Ai primit un cod?" (`trailHeading`), with "Îl găsești în mesajul de la căpitan." (`smallMuted`).
- `CodeBoxesInput(length: 6, dashAfter: 3)`, with `error` while in `Problem`, and the problem text under it in `danger`.
- With `Found`, an `InvitePreviewCard`:
  - event name (`smallMuted`)
  - team name (`trailHeading`)
  - `'Căpitan: {captain} · {Sâm 14 nov, 10:00}'`: a short day name, then `dayAndMonth`, a comma and the time
  - `AvatarStack` with `slotLine`
  - with no event, only "Căpitan: {captain}" and the members
- `AppButton` `'Intră în {crewName}'`, enabled only in `Found`, with a spinner while `Joining`.
- The footnote "Evenimentul apare la Înscrierile tale și primești notificări." (`smallMuted`).

Add `shortDay(DateTime)` to `lib/utils/event_formats.dart`, giving `'Lun', 'Mar', 'Mie', 'Joi', 'Vin', 'Sâm', 'Dum'`, tested there.

- [ ] **Step 1: Write the failing tests.**
  - **`JoinFlow`** with fakes:
    - 5 characters stays `Typing`
    - `'vlp482'` goes `Looking` → `Found`
    - an unknown code → `Problem('Codul nu există')`
    - `confirm` twice in a row calls `join` once (Review Focus 5)
    - a network error → `Problem('Nu a mers. Verifică internetul.')`, and the button is enabled again after editing the code
    - a full preview → `Problem('Echipa e completă')` with no `join` call
  - **The view** (built from a `JoinState`): `Found` with the mockup data shows `'Vulpile'`, `'Căpitan: Victor · Sâm 14 nov, 10:00'`, `'2 din 4 · tu ești al 3-lea'` and `'Intră în Vulpile'`, with no exception at 320 / 1.3×.
- [ ] **Step 2: Run** `flutter test test/features/join_team`. Expected: FAIL.
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run** `flutter test`. Expected: PASS.
- [ ] **Step 5: Commit** with the message "Join a team with an invite code".

### Task 10: Echipe screen, team details and admin team card

**Files:**
- Create:
  - `lib/features/teams/controller/teams_controller.dart`
  - `lib/features/teams/screen/teams_screen.dart`
  - `lib/features/teams/widgets/crew_card.dart`
  - `lib/features/teams/widgets/new_crew_sheet.dart`
  - `lib/features/teams/widgets/join_link.dart`
- Modify:
  - `lib/constants/routes.dart` (`teams = '/teams'`), `lib/main.dart`
  - `lib/features/profile/widgets/profile_view.dart` (an "Echipele mele" row opening `Routes.teams`)
  - `lib/features/team_details/screen/team_details_screen.dart` (members from `memberList` as an `AvatarStack` with names, and an `InviteCodeCard` when `inviteCode` is set and the viewer is the captain)
  - `lib/features/team_details/controller/team_details_controller.dart` and `lib/backend/repo/teamRepo.dart`: editing changes only the captain's phone (`update({'phoneNumber': ...})`). The team name and the free-text members can no longer be edited: renaming deleted and recreated the document, which the new rules forbid and which lost the team's chat. A rename through a function is a follow-up. `TeamRepo.updateTeamDetails` is removed.
  - `lib/features/event_see_registered_teams/widgets/team_card_widget.dart` (the "Componență" row shows `memberList` names and `'{userIds.length} din {numberOfMembers}'`; the white-on-accent avatar becomes `onTick`)
  - `docs/features.md`, `docs/screens.md`
- Test: `test/features/teams/teams_view_test.dart`

**Interfaces:**
- Consumes: Tasks 4, 5 and 6.
- Produces:
  - `TeamsController` streams `CrewRepo.streamUserCrews(uid)`, with `createCrew(name)` and `openJoin()`.
  - `TeamsView({required List<Crew> crews, required String myUid, required VoidCallback onNewCrew, required VoidCallback onJoin, required void Function(Crew) onShare, required void Function(Crew) onCopy})`

Layout from the right phone of mockup 03:
- Title "Echipe" with a "Echipă nouă" `AppChip` (outlined, `TablerIcons.plus`) on the right.
- For each crew, a `CrewCard`:
  - the name (`trailHeading`)
  - `'Căpitan: {captain} · {n} membri'` (`smallMuted`)
  - an `AvatarStack` of up to 4 members
  - a row "Cod invitație" with the display code (mono) and the copy and share icons
  - the stats tiles and season leaderboard are step 7, not drawn now
- At the bottom, the `JoinLink` "Ai primit un cod de la altă echipă? **Intră**", which opens `Routes.joinTeam`.
- With no crews: "Nu ești încă într-o echipă." with the same two actions.
- "Echipă nouă" opens `NewCrewSheet`, a bottom sheet with a name field and "Creează". It calls `createCrew`, then shows the new crew's code.

- [ ] **Step 1: Write the failing tests.**
  - `TeamDetailsController.savePhone` (or the name the controller uses) calls the repo with only the phone. Use a fake `TeamService` injected through the constructor.
  - For `TeamsView`:
    - with the mockup crew, it shows `'Vulpile'`, `'Căpitan: Victor · 4 membri'`, `'VLP-482'` and `'Intră'`
    - tapping `'Intră'` calls `onJoin`
    - with no crews, it shows the empty text
    - no exception in dark mode or at 320 / 1.3×
- [ ] **Step 2: Run** `flutter test test/features/teams`. Expected: FAIL.
- [ ] **Step 3: Implement.** Make the profile row, team details and admin card changes, and update the colour allow-list count for `team_card_widget.dart` (it goes down).
- [ ] **Step 4: Run** `flutter test` and `flutter analyze`. Expected: PASS, no new issues.
- [ ] **Step 5: Commit** with the message "Echipe screen, members on team details and the admin team card".

### Task 11: Gallery, review, deploy questions and merge

**Files:**
- Modify: `lib/dev/component_gallery.dart` and `lib/dev/` (previews of the register form, the invite result, the join screen in its `Found` state and the Echipe screen, with mockup data and fakes), `test/dev/`
- Modify: `CLAUDE.md` (a line on the team functions and `firestore.rules`), `docs/platform-and-config.md` (`cloud_functions`, the emulators, and Java 21 when it was needed)

- [ ] **Step 1: Write a failing test.** Each new preview renders in light and dark with no exception.
- [ ] **Step 2: Implement** the previews. Run `flutter test`, `flutter analyze` and `npm --prefix functions test`. Expected: all pass.
- [ ] **Step 3: Commit** with the message "Gallery: register, invite, join and Echipe with mockup data".
- [ ] **Step 4: Review the whole branch** with a fresh reviewer on the most capable model. The diff includes `functions/` and `firestore.rules`, and Review Focus 1–5 go to the reviewer. Fix Critical and Important findings test-first.
- [ ] **Step 5: Merge** with `git checkout redesign/mockups && git merge --no-ff redesign/step-3-teams`, then run `flutter test`. Do not push.
- [ ] **Step 6: Ask Victor about deploying.** Tell him:
  - The app on `redesign/mockups` now needs the five new functions to register and join, so testing on a phone needs them deployed: `firebase deploy --only functions`. That adds functions and changes nothing existing.
  - The rules (`firebase deploy --only firestore:rules`) replace the live rules, compared in Task 1. They should be deployed only when the app version that uses the functions is the one on phones, because the old app writes teams from the phone and the new rules forbid that.

  Deploy only what he says yes to.
