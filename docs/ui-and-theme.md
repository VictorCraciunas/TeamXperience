# UI, theme & shared widgets

## Theme (`lib/main.dart`, `lib/constants/`)
- `MaterialApp` uses `AppTheme.light` / `AppTheme.dark` from `lib/ui/theme/`; `themeMode` comes from `ThemeController` (`lib/ui/theme/theme_controller.dart`), which loads and saves the user's choice (Sistem / Luminos / Întunecat, default Luminos) through `SharedPrefsThemeModeStore` (`shared_preferences`, key `theme_mode`) and falls back to light if storage fails. The choice is changed with `ThemeModeButton` (bottom sheet `ThemeModeSheet`), currently in the player and admin Home app bars; it moves to the Profil tab with the navigation shell. Single-colour SVG icons use `AppSvgIcon` (tinted with `context.colors.text` or a given colour) so they work in dark mode; brand icons (Google, Facebook) and icons with their own explicit colour filter are left as plain `SvgPicture`. Scaffold = `AppColors.page`, canvas = `AppColors.panel`. `AppTheme` also builds the Material `ColorScheme` (primary = accent, surface = panel, onSurface = text, outline = border, error = live) and sets dialog and bottom-sheet backgrounds to the panel colour. App title "Treasure Hunt". Screens read colours with `context.colors`.
- Fonts (`pubspec.yaml`, `assets/fonts/`): **Poppins** 300/400/500/600/700/800; **Monospace** family = SpaceMono Regular/Bold (used for code-input components). `AppFonts.voice` = **Gelasio** (`assets/fonts/Gelasio-Variable.ttf`, weights 400–700, OFL licence in `assets/fonts/licenses/`; the serif of event letters and stories, metric-compatible with Georgia, also listed in `event_fonts.dart` so organisers can pick it). Icons of the redesign come from `flutter_tabler_icons` (`TablerIcons.map_pin`, snake_case names), matching the Tabler icons in the mockups.
- Tokens: `AppColors` (page, panel, border, inset, text, muted, accent, tick, navy, live, soon, plus semantic `success/warning/danger` and their `*Soft` backgrounds; `onNavy`, `onNavyMuted`, `onNavyFaint`, `tickOnNavy` for text and accents on navy fills, `heroButton` for round buttons over a hero image; contrast of the text/accent pairs is tested in `test/ui/theme/contrast_test.dart`), `AppTextStyles` (headline, sectionTitle, title, body, bodyMuted, caption, label, button, wordmark, plus the mockup sizes heroTitle 19, trailHeading 14, cardTitle 12, pageBody 12, smallMuted 11, factValue 18, display 34), `AppSpacing` (xs 4, sm 8, md 12, lg 16, xl 24, page 16), `AppRadius`. `MyColors`, `MyPaddings`, `MyButton`, `MyTextField` and `MyDropdownField` no longer exist. Some screens (game, splash, admin puzzle builder) still use literal colours; they are listed in `test/ui/colour_allowlist.txt`.
- Event palette: `EventPalette` (background, surface, border, ink, muted, faint, accent, secondaryAccent, danger, routeDash, voiceFont) is the look of an event's own screens; `EventPalette.parchment` is the old-map look of mockups 05–08. Wrap a screen in `EventThemeScope(palette: ...)` and read it with `context.eventPalette`, which falls back to `EventPalette.fromApp(context.colors)` outside a scope.
- Component gallery: `flutter run -t lib/dev/gallery_main.dart` shows the redesign components with the mockup copy (no Firebase), to compare with `docs/roadmap/mockups/*.html`.
- Assets: `assets/images/` (SVG icons used with `flutter_svg`, `logo.png`, `splash_background.svg`, `EventGameController` falls back to `assets/images/default_background.png`, which is **not in the repo** — events without a background image would fail to load that asset), `assets/loader/loader.json` (Lottie).
- Language: all user-facing strings are hardcoded Romanian (no l10n/ARB). Dates formatted with `CalendarHelper` (Romanian day/month names).

## Shared widgets (`lib/ui/components/`)

Moved from `lib/widgets/` (and `utils/snackbars.dart`) in UI redesign phase 1: `buttons/`, `inputs/`, `navigation/` (`my_appbar`, `menu`), `event/` (event and registered-event cards, `event_image`, `mission_state_widget`), `news/` (`stire_card`, `stiri_carousel`), `feedback/` (`snackbars`), `misc/`. Theme tokens live in `lib/ui/theme/` (`AppColors` ThemeExtension, `AppTheme.light/dark`, `AppRadius`, `AppSpacing`, `context.colors`); screens migrate to them in later phases.

| Widget | Purpose |
|---|---|
| `AppButton` | Button: label, variants primary / secondary / ghost, `leading`, `isLoading`, optional brand `backgroundColor`/`foregroundColor` |
| `AppTextField` (+ `requiredValidator(label)`) | Text field: label, hint, helper, obscure toggle, leading/trailing, `maxLines` (null = multiline), readOnly+onTap for pickers |
| `AppDropdown<T>` + `AppDropdownItem<T>` | Labelled dropdown matching `AppTextField` |
| `EventPostCard`, `NewsPostCard` | Feed posts: big image with date/tag, title, details, one share icon; the whole post is tappable. `NewsPostCard.onDelete` (admins) adds a small red x at the end of the category and date row |
| `showPeriodSheet` (+ `PeriodPicker`, `PeriodSelection`, `periodPresets`) | Period bottom sheet: quick presets (Oricând, Săptămâna asta, Luna asta) and a month calendar you swipe or step through with arrows (round days, filled ends in `tick`, tinted range); also used by the full-screen `DateRangeSelectionScreen` |
| `SegmentedSwitch`, `FeedSearchBar`, `FeedIconButton`, `RemovableChip` | Feed chrome that scrolls with the feed: switch, search button that grows into a white, tick-bordered field (the leading widget shrinks away; it plays backwards on close), filter button with an active dot, removable active-filter pill |
| `FadeInSection` | Fades a page section in while it drifts down into place; give sections increasing `order` for a top-down stagger. Plays once per section (stable key), skipped with reduced motion. Used on the player and admin Home |
| `showFilterSheet` (`FilterGroup`, `FilterOption`, `FilterSheetResult`) | Admin filter bottom sheet: a period (presets, or "Dată personalizată" with the calendar sheet) plus any number of option groups, each with "Toate", applied together. A group can have an `onAdd` (a "+" chip after its options, to create one on the spot) and an `onOptionLongPress` (long press an option to delete it) |
| `showTextInputDialog` | Asks for one line of text (trimmed); stays open while empty |
| `TickOutlineButton` | Wide pill button with the tick ring (panel fill, icon and label), used for "Creează ..." in feed headers |
| `SectionTitle` | Heading with a tick bar above a group of items |
| `AppChip` (+ `AppChipStyle` plain / outlined / selected) | Small pill with an optional icon: puzzle kinds, filters, the map link |
| `RouteStrip` | The route at a glance: start pin, dashed line with the length on it, finish flag, optional map chip, start and end names |
| `RouteTrail` + `RouteTrailSection`, `WaypointDot`, `DashedLine` | Page sections strung on a vertical dashed route, each with a waypoint (stop = navy ring, finish = teal dot) |
| `FactRow`, `FactTile`, `DateFactTile`, `DifficultyDots` | The event facts row: navy date tile 62 wide, then equal fact tiles ("2 h / durată", "●●○ Medie") |
| `StickyActionBar` (+ `BarTone`) | Bar pinned to the bottom with a status and one action: a navy button (`prominent`) or an accent link; `inlineDetail` puts "· 4 membri" after the title, `highlighted` gives a teal top border |
| `showAppDialog`, `AsyncState`, `MySnackBars` | Confirm dialog (destructive uses `danger`), loading/error/empty/content switcher, semantic snackbars |
| `MyAppBar` | App bar with title, optional icon, `showDropdown` + `event` → shows `MenuWidget` |
| `MenuWidget` (`menu.dart`) | Admin event actions overlay (edit / duplicate / start) |
| `EventCard`, `EventsCarousel`, `EventsList` | Event presentation (admin variant shows `nrTeams`/`nrPerson`) |
| `RegisteredEventCard/Carousel/List` | Player's registered events |
| `StireCard`, `StiriCarousel` | News presentation (`showBadge` for type) |
| `EventImage` | Event image with overlay info (cached network image) |
| `MissionStateWidget` | Mission tile: `MissionState` → locked / unlocked / done look |
| `CustomIconDashBoard` | Icon button with active-filter indicator |
| `StepRegisterWidget` | Step indicator in team registration |
| `SliderWidget`, `ColorPickerDialog`, `TermsText` | Misc (slider for component sizing, flutter_colorpicker dialog, terms link text) |

Conventions in feature code: `Scaffold` per screen, `MyAppBar`, `AppSpacing.page`, feedback through `MySnackBars`, images through `cached_network_image` for URLs / `Image.file` for local paths (check with `startsWith('http')`).

## Runtime component rendering (`lib/utils/component_conversion/`)
`ComponentToWidget.convert(Component, {onTextChanged, onButtonPressed})` switches on `ComponentType`:
- `text` → `TextComponentWidget` (colour, font, size, weight, align, optional typewriter animation)
- `image` → `ImageComponentWidget` (network or local file, radius, height)
- `button` → `ButtonComponentWidget` (colours + on-tap colours, glow, flicker, border, radius; `onButtonPressed`)
- `code` → `CodeComponentWidget` (segmented or free input of `codeLength`, caps handling, frame/input styling; `onTextChanged`)

The same converter is used both in the **admin builder preview** (`PuzzleController.buildComponent`) and the **player game screen** (`PuzzleGameController.loadPuzzles`), so what the admin designs is what the player sees. To add a component kind: add to `ComponentType`, fields to `Component`, a widget in this folder, a case in `convert`, an editor in `admin/.../create_components/`, and handle it in `AddComponentWidget`.

`PuzzleGameScreen` animates components in sequence (fade-in `Opacity` per component via `buildComponentsWithSpacing`, 40 px gap).
