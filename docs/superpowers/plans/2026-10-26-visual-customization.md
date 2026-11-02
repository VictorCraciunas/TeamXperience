# Visual customization of events

Umbrella branch: `update-visuals` (from `main`). Each step below is its own branch `visual/NN-name`, merged into `update-visuals` when done and approved. `update-visuals` goes into `main` only when the user says so. Never push.

## Goal

Organisers can make an event look the way they want (fonts, colours, glow, shadow, animations, backgrounds), and the app draws what the mockups showed. Mockups: font gallery, live style sheet, animations demo (see the conversation of 2026-10-26).

## Rules for every step

- **Existing events must look the same.** Every new option is optional and its default is exactly today's look. Nothing is changed for an event that does not use the option.
- A new option goes through all of these, or the step is not done: the `Component` (or `Event`/`Puzzle`) model with `fromMap`/`toJson`; the widget that draws it; the editor control; the importer (`event_json_import.dart`) with its range check; the skill (`docs/skills/event-json/SKILL.md`) and the examples; tests for each (TDD); `docs/`.
- Values the importer accepts must be values the editors can show, and every value must draw on a 360 px wide screen (`test/utils/component_conversion/skill_values_test.dart` grows with each option).
- Downloading files (fonts) needs the user's yes first.

## What the app does today (the reason for steps 01 to 03)

- Text: the block is centered on the screen, so `textAlign: left` only aligns lines inside a centered block.
- Gap between components in the game: fixed 40 px.
- Button: padding 5 px above and below, letter spacing fixed at 8, glow pulses (blur 10, spread 2 to 5).
- Code input: boxes are 1.5 x font size high, 1 px border, always bold; in "Separated" mode the glow is on the outer frame, not the boxes.
- Entrance: every component fades in one after another, over about 2 seconds, always.
- Fonts: Poppins and a monospace.

## Steps

| # | Branch | What |
|---|---|---|
| 01 | `visual/01-layout` | Text block uses the full width so alignment works; `spaceBelow` on every component (0 to 120, default 40). **Done:** `Component.spaceBelow`, `spacedComponents`, `FullWidth`, slider in the component editor, importer range, skill. The builder preview still uses its own 16 px gap. |
| 02 | `visual/02-screen-animation` | Entrance of the whole screen, set once per event (`Event.screenAnimation`): `fade` (today, default) or `none`. **Done:** enum, model, importer, form dropdown, game screen, skill. Duration and delay between components move to step 06 with the other entrances. |
| 03 | `visual/03-button-and-code-box` | Button: `letterSpacing`, `paddingY`. Code input: `boxHeight`, bold on or off, glow on the frame or on each box. |
| 04 | `visual/04-fonts` | Bundle the fonts from the gallery (Orbitron, Share Tech Mono, Press Start 2P, Cinzel, Special Elite, Caveat, Bebas Neue, Playfair Display). Needs the user's yes to download them. |
| 05 | `visual/05-effects` | On every component: shadow, glow, border, opacity. On text: letter spacing, line height, italic, capitals, outline. Colours with transparency. |
| 06 | `visual/06-component-animation` | Entrance per component (slide, zoom, bounce); loop effects (pulse, float, shake, flicker, glitch). |
| 07 | `visual/07-text-effects-and-feedback` | Text decode and glitch effects; shake and flash on a wrong or correct code. |
| 08 | `visual/08-backgrounds` | Background per mission or puzzle; overlays (scanlines, vignette); the missing `assets/images/default_background.png`. |
| 09 | `visual/09-presets` | Themes ("hacker", "pirate", "retro", "detective") that set font, colours, background and button style for a whole event. |

## Open decisions

- Where the screen animation choice is set (event level first, per puzzle later).
- The final list of fonts (the user picks from the gallery).
- Whether presets are built into the app or written into the JSON.
