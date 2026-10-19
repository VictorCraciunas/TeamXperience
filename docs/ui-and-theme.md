# UI, theme & shared widgets

## Theme (`lib/main.dart`, `lib/constants/`)
- `MaterialApp` uses `AppTheme.light` (from `lib/ui/theme/`) with `primaryColor`/`scaffoldBackgroundColor`/`canvasColor` overridden to white for now (keeps today's look until screens move onto tokens), `darkTheme: AppTheme.dark` and `themeMode: ThemeMode.light`. No custom `ColorScheme` yet. App title "Treasure Hunt".
- Fonts (`pubspec.yaml`, `assets/fonts/`): **Poppins** 300/400/500/600/700/800; **Monospace** family = SpaceMono Regular/Bold (used for code-input components).
- `MyColors` (`constants/colors.dart`): `lightBlue #53C4C7` (primary accent), `transparentLightBlue`, `facebookBlue`, `yellow #F6AF1A`, `transparentYellow`, `greyText #858494`, `blackColor #0C092A`, `backgroundColor` white, `myGradient` (horizontal `lightBlue → #222F62`, used for primary buttons).
- `MyPaddings.appHorizontalPadding = 25.0`. Some screens still hardcode colours (e.g. `Color(0xFF001833)` for headings) and padding.
- Assets: `assets/images/` (SVG icons used with `flutter_svg`, `logo.png`, `splash_background.svg`, `EventGameController` falls back to `assets/images/default_background.png`, which is **not in the repo** — events without a background image would fail to load that asset), `assets/loader/loader.json` (Lottie).
- Language: all user-facing strings are hardcoded Romanian (no l10n/ARB). Dates formatted with `CalendarHelper` (Romanian day/month names).

## Shared widgets (`lib/ui/components/`)

Moved from `lib/widgets/` (and `utils/snackbars.dart`) in UI redesign phase 1: `buttons/`, `inputs/` (+`my_dropdown/`), `navigation/` (`my_appbar`, `menu`), `event/` (event and registered-event cards, `event_image`, `mission_state_widget`), `news/` (`stire_card`, `stiri_carousel`), `feedback/` (`snackbars`), `misc/`. Theme tokens live in `lib/ui/theme/` (`AppColors` ThemeExtension, `AppTheme.light/dark`, `AppRadius`, `AppSpacing`, `context.colors`); screens migrate to them in later phases.

| Widget | Purpose |
|---|---|
| `MyButton` | Primary button: text, `buttonColor` or `gradient`, border, radius, optional `leading` |
| `MyTextField` | Styled text field (label, hint, obscure toggle, leading/trailing, readOnly+onTap for pickers) |
| `my_dropdown/MyDropdownField<T>` + `DropdownItem<T>` | Custom dropdown (recently redesigned) |
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

Conventions in feature code: `Scaffold` per screen, `MyAppBar`, `MyPaddings.appHorizontalPadding`, feedback through `MySnackBars`, images through `cached_network_image` for URLs / `Image.file` for local paths (check with `startsWith('http')`).

## Runtime component rendering (`lib/utils/component_conversion/`)
`ComponentToWidget.convert(Component, {onTextChanged, onButtonPressed})` switches on `ComponentType`:
- `text` → `TextComponentWidget` (colour, font, size, weight, align, optional typewriter animation)
- `image` → `ImageComponentWidget` (network or local file, radius, height)
- `button` → `ButtonComponentWidget` (colours + on-tap colours, glow, flicker, border, radius; `onButtonPressed`)
- `code` → `CodeComponentWidget` (segmented or free input of `codeLength`, caps handling, frame/input styling; `onTextChanged`)

The same converter is used both in the **admin builder preview** (`PuzzleController.buildComponent`) and the **player game screen** (`PuzzleGameController.loadPuzzles`), so what the admin designs is what the player sees. To add a component kind: add to `ComponentType`, fields to `Component`, a widget in this folder, a case in `convert`, an editor in `admin/.../create_components/`, and handle it in `AddComponentWidget`.

`PuzzleGameScreen` animates components in sequence (fade-in `Opacity` per component via `buildComponentsWithSpacing`, 40 px gap).
