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
| 03 | `visual/03-button-and-code-box` | Button: `letterSpacing` (0 to 12, default 8), `paddingY` (0 to 30, default 5). Code input: `boxHeight` (20 to 100, default 1.5 x text), `boldText` (default on), `glowOn` (`frame` default, or `boxes`). **Done:** model, widgets, editors (the box height slider says "automat" until moved), importer, skill. |
| 04 | `visual/04-fonts` | Bundle the fonts from the gallery (Orbitron, Share Tech Mono, Press Start 2P, Cinzel, Special Elite, Caveat, Bebas Neue, Playfair Display). **Done:** downloaded with the user's yes, `lib/utils/event_fonts.dart` is the one list (editors, importer, skill, tests), variable fonts get `FontVariation` weights, licences in `assets/fonts/licenses/`. |
| 05 | `visual/05-text-effects` | Text: `letterSpacing`, `lineHeight`, `italic`, `uppercase`, glow (`enableGlow`, `glowColor`), shadow (`shadowColor`, `shadowBlur`, `shadowDistance`). **Done:** model, `TextEffects`, text and typewriter widgets, editor, importer, skill. The text outline is not done (it needs the text drawn twice). |
| 05b | `visual/05b-box-effects` | `opacity` on every component; shadow (`shadowColor`, `shadowBlur`, `shadowDistance`) on image, button and code input; `borderWidth` and `borderColor` on an image, `borderWidth` on a button (default 1.5); glow on an image. **Done:** model, `BoxEffects`, widgets, shared editor controls (opacity, shadow) plus image and button controls, importer, skill. Not done: colours with transparency in the JSON (the editor picker has it already). |
| 06 | `visual/06-entrance-animations` | The event's entrance now has eight kinds (`fade`, `none`, four slides, `zoom`, `bounce`) and a timing (`animationDuration` 200 to 1500, `animationDelay` 0 to 600; automatic = today's 2 seconds). Set once for the whole event, not per component. **Done:** enum, `entranceFrame`, `EntranceTiming`, game screen, form (dropdown and two sliders), importer, skill. |
| 06b | `visual/06b-loop-effects` | `loopEffect` on any component: pulse, float, shake, flicker, glitch. **Done:** enum, `loopFrame`, `LoopEffectWidget` (stops when the phone has animations off), model, converter, shared editor dropdown, importer, skill. The glitch is a quick jump sideways, without the colour split of the mockup. |
| 07 | `visual/07-decode-and-feedback` | Text `animation: "decode"` (scrambled letters settle on the real ones, with the typewriter speed). Answer feedback on a code input: shake and red flash when wrong, pop and green flash when right (`answerFeedback`, on unless `false`); after a right answer the game waits 0.6 s so the pop can be seen. **Done:** both, in the editor, importer and skill. A separate text glitch was left out: the loop effect `glitch` covers it. |
| 08 | `visual/08-backgrounds` | Background per mission or puzzle; overlays (scanlines, vignette); the missing `assets/images/default_background.png`. |
| 09 | `visual/09-presets` | Themes ("hacker", "pirate", "retro", "detective") that set font, colours, background and button style for a whole event. |

## Step 04 notes: the font files

Source: the Google Fonts repository, `github.com/google/fonts` (files fetched from `raw.githubusercontent.com/google/fonts/main/...`), all under the SIL Open Font License except Special Elite (Apache 2.0). The licence texts are kept next to the fonts in `assets/fonts/licenses/`. The user said yes to downloading these on 2026-11-02.

| Font | File in the repository | Size |
|---|---|---|
| Orbitron | `ofl/orbitron/Orbitron[wght].ttf` (variable) | 38,576 B |
| Share Tech Mono | `ofl/sharetechmono/ShareTechMono-Regular.ttf` | 43,272 B |
| Press Start 2P | `ofl/pressstart2p/PressStart2P-Regular.ttf` | 118,204 B |
| Cinzel | `ofl/cinzel/Cinzel[wght].ttf` (variable) | 125,468 B |
| Special Elite | `apache/specialelite/SpecialElite-Regular.ttf` | 166,180 B |
| Caveat | `ofl/caveat/Caveat[wght].ttf` (variable) | 403,648 B |
| Bebas Neue | `ofl/bebasneue/BebasNeue-Regular.ttf` | 61,400 B |
| Playfair Display | `ofl/playfairdisplay/PlayfairDisplay[wght].ttf` (variable) | 300,724 B |

About 1.2 MB in total. Four are variable fonts with no static files, so the weight is set with a `FontVariation('wght', ...)` next to the `fontWeight` (one helper used by the text, button and code widgets). The other four have a single weight: asking for bold gives the font's own faux bold or nothing, and the editor says so.

## Open decisions

- Where the screen animation choice is set (event level first, per puzzle later).
- The final list of fonts (the user picks from the gallery).
- Whether presets are built into the app or written into the JSON.
