# Game flow: creating and playing events (design)

Date: 2026-10-20. Status: draft for the owner's review. Mockups were shown and approved in conversation.

## Intent

Players and organisers use the same app, but today the game itself is silent and the builder is slow. A wrong answer shows nothing, the hint an organiser must write (`Puzzle.indiciu`, required in the save form) is never shown to players, there is no progress bar, no timer and no finish screen. Organisers build every puzzle component by component, edit each one in a long form, and only see the result by playing.

This design improves the **whole flow with the current puzzle types** (code, photo upload, location, redirect, AR) in two parts that can ship separately:

1. **Playing:** the player sees progress, time, clear wrong-answer feedback, attempts, a hint and a finish screen.
2. **Creating:** the organiser builds each puzzle on a canvas that looks like the player screen, styles components with a sheet of palettes and sliders, sets rules apart from looks, manages missions in a list, tests the game and publishes with a checklist.

Puzzles stay fully customisable. Nothing the builder can do today is removed.

## Goals

- A team always knows where it is (mission x of y, time) and what happened after an answer.
- An organiser can build a good-looking puzzle in a few minutes, see it while building, and know before publishing what is missing.
- Every existing event keeps working with no migration.

## Non-goals (later)

- New puzzle types (multiple choice, ordering, matching, QR, cipher, mini-games), branching missions, team-split clues, audio clues. The new fields below are chosen so these can be added without reworking this.
- Event skins/presets as a one-tap theme. Only "event defaults" for new components are in scope (below).
- Admin Evenimente dashboard feed redesign (separate item).

## Anti-goals

- No loss of styling power: every current component option stays reachable.
- No required new fields: an event built before this change must play and edit unchanged.
- Hints, attempts and timers must never block a team from finishing: attempts are optional (default unlimited).

## Part 1: Playing

### Screens and behaviour

- **Puzzle screen** gains a header: a segmented progress bar (one segment per mission, current highlighted), `Misiunea x/y`, and the elapsed time since the team started. Time keeps counting while the app is closed (computed from `Team.startedAt`).
- **Wrong answer** (code puzzles): the answer field shakes, a message appears under it (the puzzle's `wrongAnswerMessage`, default `Răspuns greșit. Mai încearcă.`), light haptic feedback. The input keeps what was typed.
- **Attempts:** if `maxAttempts` is set, dots show attempts left. At zero attempts the puzzle locks and says `Ai epuizat încercările. Cere ajutor organizatorilor.` with a shortcut to the team chat. (Organisers can already answer in chat; no new unlock flow in this version.)
- **Hint:** a `Indiciu` button appears after `hintDelaySeconds` (default 90) from opening the puzzle, showing `Puzzle.indiciu`. Using it is recorded (`hintsUsed`). Puzzles without a hint text show no button.
- **Mission list:** current mission highlighted, finished ones checked, locked ones dimmed; the elapsed time and a small `Ai nevoie de ajutor?` chat entry stay.
- **Finish screen:** shown when the last mission completes: total time, missions done, hints used, rank among finished teams and a button to the leaderboard. The leaderboard lists finished teams ordered by total time, then by hints used.

### Data (all optional, old documents read as defaults)

- `Team`: `startedAt` (timestamp, set when the code is entered), `finishedAt` (set when `hasFinished` becomes true), `hintsUsed` (int, default 0). Total time = `finishedAt - startedAt`.
- `Puzzle`: `maxAttempts` (int?, null = unlimited), `wrongAnswerMessage` (string?), `hintDelaySeconds` (int?, null = default).
- Leaderboard reads `events/{id}/teams` ordered by finish time; no new collection.

### Logic placement

Answer checking, attempts left, hint availability and rank move out of `PuzzleGameController.buttonPressed` into small pure functions with tests: `checkAnswer(puzzle, input)`, `attemptsLeft`, `hintAvailable(now, openedAt, puzzle)`, `rankTeams(teams)`. The controller only calls them and updates the screen.

## Part 2: Creating

### Flow (six steps, as in the mockups)

0. **Start** (`Eveniment nou`): from scratch, from an old event (copies missions and style) or from a template, with the list of drafts to continue.
1. **Event wizard**, five steps replacing the single long form: Informații de bază (cover image, name, short description with counter), Când și unde (date and time, location, start point, enrolment window with plain checks), Acces și reguli (public or private, start code with a Generează button, difficulty chips, route length, duration), Aspectul jocului (mission background, colour, accent, font; these are the event defaults, with a live preview) and Verifică (the event card as players see it). Each step validates before Continuă; the form no longer crashes on empty fields.
2. **Missions list** (the wizard continues here as the sixth step): drag to reorder, duplicate a mission, an `incompletă` marker per mission (missing answer, missing location, no components), `Misiune nouă`, and **event defaults** (background colour, text colour, accent colour, font) that every new component starts with.
3. **Canvas** per puzzle: the puzzle drawn like the player screen using the same component renderer. Tap a component to select and edit it, `+` row to add text, image, button or code input, drag handles to reorder, delete in the style sheet.
4. **Style sheet** (bottom sheet, tabs `Stil`, `Efecte`, `Layout`) per selected component, described below.
5. **Rules** screen per puzzle, separate from looks: puzzle type, correct answer (and accepted variants as a toggle), hint text, hint delay, attempts (3, 5 or unlimited), wrong-answer message.
6. **Test-play** and **Publish**: test-play runs the real game screens with a throw-away test team (nothing written to Firestore), with `Sari la misiune`. Publish shows a checklist (details complete, every mission complete, start code set, tested at least once) and offers `Salvează ca ciornă`.

### Style sheet

Per component type. Colours come from two palettes plus a free picker: the **event palette** (the event defaults) and the **app palette** (AppColors accents), with a rainbow circle opening the picker for custom colours. Numeric values use the **compact slider row** (decided): label left, value chip right (tap the chip to type an exact value), a thick thumb and a few tick marks. A live preview of the component sits above the sheet.

| Component | Stil | Efecte | Layout |
|---|---|---|---|
| Text | colour, size, weight, letter spacing, font, alignment | glow, typewriter | padding, width |
| Button | fill, text colour, border colour | corners, border width, shadow (blur, offset, strength), glow, flicker, colour on tap | padding, width |
| Code input | box or free, characters, box fill, border colour, capitals | box corners, spacing between boxes | padding, width |
| Image | fit (cover / contain / fill) | corners, opacity, border width, shadow, fade-in | height, width |

Every option the current editors have stays; options not shown on the first screen live under `Mai multe opțiuni`.

New component fields (all optional, null = today's look): `letterSpacing`, `borderWidth`, `shadowBlur`, `shadowOffsetY`, `shadowOpacity`, `shadowColor`, `opacity`, `imageFit`, `padding`. Existing: colours, `cornerRadius`, glow, flicker, fonts, alignment, sizes.

### Event data

- `Event.defaults` (map: `backgroundColor`, `textColor`, `accentColor`, `fontFamily`), optional. Used only when a component is created; changing defaults later does not rewrite existing components.
- `Event.status`: `draft` or `published`; missing = published (so old events are untouched). Drafts are hidden from players and from `EventList.upcomingEvents` for players, visible to admins with a `Ciornă` tag. A draft also stores `wizardStep` (int) so it resumes where the organiser left off.
- **Admin Home** gets a `Ciorne` panel (between Acțiuni rapide and Evenimente viitoare, shown only when drafts exist): each row has the name, a progress bar, a short status (step, or the first missing item) and `Continuă`.

### Logic placement

The builder logic stays in controllers next to each screen. Pure helpers get tests: `missionIssues(mission)` (what is missing), `publishChecklist(event)`, `applyDefaults(component, defaults)`, and the reorder/duplicate operations on `Event.missions`.

## Phases

1. **Player feedback:** wrong-answer feedback, attempts, hint, `Puzzle` fields, answer-check functions. (Smallest, visible at once.)
2. **Progress and finish:** `Team` timing fields, header with progress and time, mission list states, finish screen, leaderboard.
3. **Style sheet and new component fields:** the sheet, palettes, compact sliders, new fields rendered by the component widgets.
4. **Canvas and rules:** canvas editor on the shared renderer, rules screen, mission list with reorder, duplicate and markers, event defaults.
5. **Test-play, drafts and publish:** test team, `Event.status`, checklist.

Each phase is its own branch, merged `--no-ff` to local `main` after a device check, same workflow as the UI redesign (TDD, `flutter analyze` and `flutter test` green, no push unless asked).

## Constraints

- Flutter app with Firebase; Firestore rules and Cloud Functions are not changed by this design except that the leaderboard needs read access players already have on `events/{id}/teams`. **To verify before phase 2:** that a player can read other teams' documents under the current rules.
- All strings Romanian. New widgets that more than one area uses go in `lib/ui/components/`, flow-specific ones under `lib/features/<area>/widgets/`.
- Old events must load without new fields.

## Decided in conversation

- Style sheet uses palettes (event + app) and compact slider rows (variant A), not S/M/L and not steppers.
- Puzzles remain component-based and fully customisable.
- New puzzle types, skins and branching come later.

## My calls (not yet confirmed)

- Hint delay default 90 s; attempts offered as 3, 5 or unlimited; hints are free in this version (no time penalty).
- Leaderboard ranks by total time, ties broken by fewer hints.
- At zero attempts the team is pointed to chat instead of being unlocked automatically.
- Drafts are hidden from players; publishing is one-way in the UI (no unpublish).
- Elapsed time is measured from when the team enters the start code.
- Test-play writes nothing to Firestore.

## Left to the builder

Exact layout and animation of the shake and progress bar, haptic strength, ordering of the style sheet controls within a tab, drag-to-reorder implementation, and the visual detail of the finish screen.
