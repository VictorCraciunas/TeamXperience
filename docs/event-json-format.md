# Importing an event from JSON

In the app: admin Home → **Creează eveniment** → **Din JSON**. Copy the text from wherever you wrote it, press **Lipește** (or paste in the box), then press **Importă ca ciornă**. The event is saved as a draft and opened in the event form, where you check it and publish it. Nothing is published by the import.

To have an AI write the JSON for you, give it [skills/event-json/SKILL.md](skills/event-json/SKILL.md): the full shape, a small example and every value the app accepts. A complete example is in [event-import-sample.json](event-import-sample.json). A test checks that it imports and could be published.

## Rules

- Everything is optional while importing. What is missing is listed when you publish.
- Dates are text: `2026-11-20T18:00`.
- Numbers can be whole (`18`) or decimal (`18.5`).
- Ids are not written: missions and puzzles are numbered by their place in the list. `eventId`, `status` and `isStopped` in the file are ignored.
- Images are links (`https://...`) or left out. Pictures cannot be inside the file.
- A mistake is reported with its place, for example `Misiunea 2, puzzle 1, componenta 3: „type” nu poate fi „video”`. Nothing is saved until all mistakes are fixed.

## Event

| Key | Value |
|---|---|
| `name`, `description`, `location`, `punctDeStart` | text |
| `type` | `PUBLIC` or `PRIVAT` |
| `startCode` | text (a number is accepted) |
| `dateEvent`, `dateStartEnrollment`, `dateDeadlineEnrollment` | date text |
| `lungimeTraseu`, `durata`, `dificultate` | text, for example `"3 km"`, `"2 ore"`, `"Medie"` |
| `landingImageUrl`, `taskBackgroundImageUrl` | link or `null` |
| `missions` | list of missions |

To publish, the enrolment opens before it closes, and closes before the event.

## Mission and puzzle

A mission is `{ "puzzles": [ ... ] }`.

| Key | Value |
|---|---|
| `type` | `code`, `imageToUpload`, `geolocation`, `redirect` or `ar` |
| `code` | the answer, for `code` puzzles |
| `latitude`, `longitude` | numbers, for `geolocation` puzzles |
| `indiciu` | the hint (optional) |
| `components` | what is on the puzzle screen; at least one to publish |

A `code` puzzle is played with a `code` component (where players type) and a `button` component (to check the answer).

## Components

`type` is required: `text`, `image`, `button` or `code`. The other keys are optional; the app uses its own look when they are missing.

- **text**: `text`, `textColor`, `fontSize`, `fontWeight`, `fontFamily`, `textAlign`, `enableGlow`, `glowColor`, `enableFlicker`, `animation` (`none` or `typewriter`), `typewriterSpeed`
- **image**: `imageUrl`, `width`, `height`, `cornerRadius`, `borderColor`
- **button**: `buttonLabel`, `buttonColor`, `buttonColorOnTap`, `buttonTextColor`, `buttonTextColorOnTap`, `borderColor`, `cornerRadius`, and the glow and flicker keys
- **code**: `codeLength`, `inputType` (`Separated` or `Free`), `capsLock` (`CapsLock` or `Fără`), `frameBackgroundColor`, `inputBackgroundColor`, `colorBorderInput`, `colorBorderContainer`, `frameCornerRadius`, `inputCornerRadius`

Colours are hex text such as `#33FF66`.
