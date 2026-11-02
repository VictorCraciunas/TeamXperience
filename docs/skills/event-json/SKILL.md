---
name: event-json
description: Writes the JSON of a TeamXperience treasure-hunt event that the app can import ("Creează eveniment" → "Din JSON"). Use when someone describes a city game, quest or treasure hunt (missions, puzzles, codes, places) and wants it as importable JSON.
---

# TeamXperience event JSON

You write one JSON object that describes a whole event: its details, its missions, the puzzles in each mission, and what is on the screen of each puzzle. The organiser pastes it in the app, which saves it as a **draft** to check and publish.

## How to work

1. If the person has not told you the essentials, ask for them first (briefly, all in one message): event name, city/location, start point, date and time, who can join (public or private), how many missions, and for each puzzle what it asks and its answer or place.
2. Write the **content in Romanian** unless asked otherwise.
3. Answer with **one JSON code block** and nothing inside it except JSON (no comments, no trailing commas). Put any notes after the block, not inside it.
4. Keep to the values listed in this file. Do not invent keys or values: the app ignores unknown keys, but it **refuses the whole import** if a value is not one of the listed ones (a wrong `type`, a font weight, a colour that is not `#RRGGBB`, a number outside its range). The message says where the mistake is.
5. Before answering, go through the checklist at the end.

## The whole shape

`?` means optional. Everything is optional for the import itself, but the event can only be **published** when the fields marked **(needed to publish)** are filled in.

```
Event
  name: String                           (needed to publish)
  description: String                    (needed to publish)
  location: String                       (needed to publish)
  punctDeStart: String                   (needed to publish)
  type: "PUBLIC" | "PRIVAT"              (needed to publish)
  startCode: String                      (needed to publish)
  dateEvent: DateText                    (needed to publish)
  dateStartEnrollment: DateText          (needed to publish)
  dateDeadlineEnrollment: DateText       (needed to publish)
  lungimeTraseu: String                  (needed to publish)
  durata: String                         (needed to publish)
  dificultate: String                    (needed to publish)
  landingImageUrl?: String | null
  taskBackgroundImageUrl?: String | null
  screenAnimation?: "fade" | "none"
  missions: List<Mission>                (at least 1 to publish)

Mission
  puzzles: List<Puzzle>                  (at least 1 to publish)

Puzzle
  type: "code" | "imageToUpload" | "geolocation" | "redirect" | "ar"   (needed to publish)
  code?: String                          (needed to publish when type is "code")
  latitude?: Number                      (needed to publish when type is "geolocation")
  longitude?: Number                     (needed to publish when type is "geolocation")
  indiciu?: String
  components: List<Component>            (at least 1 to publish)

Component
  type: "text" | "image" | "button" | "code"        (required)
  spaceBelow?: Number
  text?: String
  textColor?: HexColor
  fontSize?: Number
  fontWeight?: String
  fontFamily?: String
  textAlign?: String
  animation?: "none" | "typewriter"
  typewriterSpeed?: Whole number
  imageUrl?: String
  cornerRadius?: Number
  height?: Number
  buttonLabel?: String
  letterSpacing?: Number
  paddingY?: Number
  buttonColor?: HexColor
  buttonColorOnTap?: HexColor
  buttonTextColor?: HexColor
  buttonTextColorOnTap?: HexColor
  borderColor?: HexColor
  enableGlow?: true | false
  glowColor?: HexColor
  enableFlicker?: true | false
  codeLength?: Whole number
  boxHeight?: Number
  boldText?: true | false
  glowOn?: "frame" | "boxes"
  inputType?: "Separated" | "Free"
  capsLock?: "CapsLock" | "Fără"
  frameCornerRadius?: Number
  inputCornerRadius?: Number
  frameBackgroundColor?: HexColor
  inputBackgroundColor?: HexColor
  colorBorderContainer?: HexColor
  colorBorderInput?: HexColor
  width?: Number

DateText  = String like "2027-05-15T18:00"
HexColor  = String like "#33FF66"
```

## Small example

A one-mission event with a code puzzle. (A fuller one is in `docs/event-import-sample.json`, and a styled 2-mission game in `docs/event-examples/hacker-game.json`.)

```json
{
  "name": "Comoara din Sibiu",
  "description": "O vânătoare de comori prin centrul vechi.",
  "location": "Sibiu",
  "punctDeStart": "Piața Mare, lângă fântână",
  "type": "PUBLIC",
  "startCode": "SIBIU26",
  "dateEvent": "2027-05-15T18:00",
  "dateStartEnrollment": "2027-05-01T09:00",
  "dateDeadlineEnrollment": "2027-05-14T23:59",
  "lungimeTraseu": "3 km",
  "durata": "2 ore",
  "dificultate": "Medie",
  "missions": [
    {
      "puzzles": [
        {
          "type": "code",
          "code": "1521",
          "indiciu": "Anul se vede deasupra intrării.",
          "components": [
            { "type": "text", "text": "În ce an a fost construită prima casă din piață?", "fontSize": 20, "textAlign": "center" },
            { "type": "code", "codeLength": 4, "inputType": "Separated", "capsLock": "Fără" },
            { "type": "button", "buttonLabel": "Verifică", "buttonColor": "#33FF66", "buttonTextColor": "#000000" }
          ]
        }
      ]
    }
  ]
}
```

## Every field and what it can hold

### Event

| Field | What it can hold |
|---|---|
| `name` | Free text. Shown as the event title. |
| `description` | Free text. Shown on the event page. |
| `location` | Free text, the city or area, for example `"Sibiu"`, `"București, Centrul Vechi"`. |
| `punctDeStart` | Free text, where teams meet, for example `"Piața Mare, lângă fântână"`. |
| `type` | `"PUBLIC"` (anyone can join) or `"PRIVAT"` (private). Exactly these two, in capitals. |
| `startCode` | Free text (a number is accepted). Teams type it to start the game. Short and easy to say, for example `"SIBIU26"`. |
| `dateEvent` | Date text `YYYY-MM-DDTHH:MM`, local time, for example `"2027-05-15T18:00"`. The game ends 3 hours after this unless the organiser stops it earlier. |
| `dateStartEnrollment` | Date text. When registration opens. Must be **before** `dateDeadlineEnrollment`. |
| `dateDeadlineEnrollment` | Date text. When registration closes. Must be **before** `dateEvent`. |
| `lungimeTraseu` | Free text, for example `"3 km"`, `"500 m"`. |
| `durata` | Free text, for example `"2 ore"`, `"90 de minute"`. |
| `dificultate` | Free text shown as written. Suggested: `"Ușoară"`, `"Medie"`, `"Grea"`. |
| `landingImageUrl` | A link starting with `https://`, or `null`. The event's cover picture. Files cannot be put in the JSON. |
| `taskBackgroundImageUrl` | A link starting with `https://`, `null`, or the name of a picture that is already inside the app. Background behind every puzzle. Pictures inside the app: `"assets/images/hacker_background.jpg"` (dark, falling green code, use light green text on it). |
| `screenAnimation` | How the components of a puzzle appear when it opens. `"fade"` (default): one after another, each fading in, over about 2 seconds. `"none"`: all at once, no animation. The typewriter of a text and the glow of a button are separate and still work with `"none"`. |
| `missions` | A list. The missions are played in the order written. |

Keys you may see in an exported event but must **not** write: `eventId`, `status`, `isStopped`, `nrMissions`, `wizardStep`, `updatedAt`, `defaults`, and the `id` of missions and puzzles. They are ignored or set by the app.

### Mission

| Field | What it can hold |
|---|---|
| `puzzles` | A list. The puzzles are played in the order written. A mission is finished when its last puzzle is solved. |

### Puzzle

| Field | What it can hold |
|---|---|
| `type` | `"code"`: players type an answer. `"geolocation"`: players must walk to a place. `"imageToUpload"`: players send a photo that an organiser approves in the chat. `"redirect"` and `"ar"` exist in the app but have **no special game behaviour yet**, so do not use them. |
| `code` | Only for `"code"` puzzles. The correct answer. Not case-sensitive, spaces at the ends are ignored. Letters and digits, no longer than `codeLength` of the code component. |
| `latitude` | Only for `"geolocation"`. A number from -90 to 90, for example `45.7983`. |
| `longitude` | Only for `"geolocation"`. A number from -180 to 180, for example `24.1521`. Players count as arrived within **20 metres** of the point, so choose a spot they can reach. |
| `indiciu` | Free text. The hint for the puzzle. Optional. |
| `components` | A list of what is shown on the puzzle screen, from top to bottom in the order written. |

### Component: keys every kind can have

| Field | What it can hold |
|---|---|
| `type` | `"text"`, `"image"`, `"button"` or `"code"`. Required. |
| `spaceBelow` | A number from 0 to 120: the space in pixels left under this component before the next one. When missing it is 40. Use a small value (for example `8`) to keep a title close to the text under it, and a large one (for example `90`) before a button. |

### Component `text`

| Field | What it can hold |
|---|---|
| `text` | Free text. |
| `textColor` | Hex colour `"#RRGGBB"`, for example `"#1B1B1B"`. When missing: black. |
| `fontSize` | A number from 8 to 72. The app's editor starts at 16. |
| `fontWeight` | One of: `"Thin (100)"`, `"Light (300)"`, `"Regular (400)"`, `"Medium (500)"`, `"Bold (700)"`, `"Black (900)"`. Written exactly like that, with the number in brackets. |
| `fontFamily` | One of the fonts listed under "Fonts" below. |
| `textAlign` | `"left"`, `"center"`, `"right"` or `"justify"`. Default: `"center"`. The text takes the whole width of the screen, so `"left"` really puts it at the left edge. |
| `animation` | `"none"` (appears at once) or `"typewriter"` (letters appear one by one). |
| `typewriterSpeed` | Whole number of milliseconds per letter, from 10 to 300. Default 100. Only used with `"typewriter"`. |

### Component `image`

| Field | What it can hold |
|---|---|
| `imageUrl` | A link starting with `https://`. |
| `cornerRadius` | A number from 0 to 50. Default 10. |
| `height` | A number from 150 to 500. Default 150. |

### Component `button`

A `code` puzzle needs a button: pressing it checks the answer. For `geolocation` and `imageToUpload` puzzles the app shows its own button, so do not add one.

| Field | What it can hold |
|---|---|
| `buttonLabel` | Free text, short, for example `"Verifică"`. |
| `buttonColor` | Hex colour. Default white. |
| `buttonColorOnTap` | Hex colour while pressed. Default grey. |
| `buttonTextColor` | Hex colour. Default black. |
| `buttonTextColorOnTap` | Hex colour while pressed. Default white. |
| `borderColor` | Hex colour. Default black. |
| `cornerRadius` | A number from 0 to 50. Default 10. |
| `fontSize` | A number from 8 to 72. |
| `letterSpacing` | A number from 0 to 12: the space between the letters of the label. Default 8. `0` gives a compact button. |
| `paddingY` | A number from 0 to 30: the space above and below the label inside the button. Default 5. A larger number makes a taller button. |
| `fontWeight` | The same six values as for `text`. |
| `fontFamily` | One of the fonts listed under "Fonts" below. Default `"Poppins"`. |
| `enableGlow` | `true` or `false`. |
| `glowColor` | Hex colour of the glow. Only used when `enableGlow` is `true`. |
| `enableFlicker` | `true` or `false`. The button flickers. |

### Component `code`

The place where players type the answer of a `code` puzzle.

| Field | What it can hold |
|---|---|
| `codeLength` | A whole number from 1 to 10: how many characters the answer has. Default 5. It must match the length of the puzzle's `code`. |
| `inputType` | `"Separated"` (one box per character) or `"Free"` (one single box). |
| `capsLock` | `"CapsLock"` (typed letters become capitals) or `"Fără"` (as typed). |
| `frameCornerRadius` | A number from 0 to 50. The outer frame (only with `"Separated"`). Default 15. |
| `inputCornerRadius` | A number from 0 to 50. Each box. Default 15. |
| `width` | A number from 0 to 200: the width of one box. Default 50. |
| `boxHeight` | A number from 20 to 100: the height of one box. When missing it is 1.5 times `fontSize`. |
| `boldText` | `true` (default) or `false`: whether the typed characters are bold. |
| `glowOn` | `"frame"` (default): the glow is around all the boxes together. `"boxes"`: each box glows on its own. Only used with `enableGlow` and `"Separated"`; a single `"Free"` box glows either way. |
| `fontSize` | A number from 8 to 72. Default 16. |
| `fontFamily` | One of the fonts listed under "Fonts" below. |
| `textColor` | Hex colour of the typed characters. |
| `frameBackgroundColor` | Hex colour of the frame (only with `"Separated"`). |
| `inputBackgroundColor` | Hex colour of the boxes. |
| `colorBorderContainer` | Hex colour of the frame border. |
| `colorBorderInput` | Hex colour of each box border. |
| `enableGlow` | `true` or `false`. |
| `glowColor` | Hex colour of the glow. Only used when `enableGlow` is `true`. |

### Fonts

Write the name exactly as in this list, with the capitals and the spaces. Anything else makes the import fail.

| `fontFamily` | Looks | Weights |
|---|---|---|
| `"Poppins"` | Clean, modern, rounded. The default. | All six |
| `"Monospace"` | Typewriter or code, every letter the same width. | Regular and bold |
| `"Orbitron"` | Sci-fi, wide, geometric. Good for tech and space. | All six (starts at 400) |
| `"Share Tech Mono"` | Terminal, hacker, code. Narrow monospace. | One weight |
| `"Press Start 2P"` | Retro arcade game. Very wide, use a small `fontSize` (10 to 16). | One weight |
| `"Cinzel"` | Ancient, Roman, medieval. Capitals look best. | All six (starts at 400) |
| `"Special Elite"` | Old typewriter, detective files. | One weight |
| `"Caveat"` | Handwriting, notes, treasure maps. Use a larger `fontSize` (24 to 36). | Up to 700 |
| `"Bebas Neue"` | Tall, bold titles, all capitals. | One weight |
| `"Playfair Display"` | Elegant serif, mystery, luxury. | All six (starts at 400) |

"All six" means the six `fontWeight` values work. For "One weight" fonts the weight changes little or nothing: leave `fontWeight` out. Where a font starts at 400, `"Thin (100)"` and `"Light (300)"` look like regular. Pair a title font with a plain one: for example `"Bebas Neue"` for the title text and `"Poppins"` for the rest.

### Colours

Always `"#RRGGBB"` with 6 hex digits, for example `"#33FF66"`.

The puzzle screen shows the picture in `taskBackgroundImageUrl` behind the components. **Without that picture the components sit on a plain page colour, which is light by default.** So:

- With no `taskBackgroundImageUrl`: leave `textColor` out (it is black) or use dark colours, and do not set dark backgrounds on the code boxes.
- With a dark `taskBackgroundImageUrl`: use light colours such as `"#FFFFFF"` for text, and set `textColor` on the `code` component too, because its typed characters are black unless told otherwise.

## What a playable puzzle looks like

- **`code`**: a `text` component with the question, a `code` component whose `codeLength` equals the length of `code`, and a `button` component. Without the button, players cannot submit.
- **`geolocation`**: a `text` component telling them where to go. The app adds the map and its own "Continuă" button. Both `latitude` and `longitude` are required.
- **`imageToUpload`**: a `text` component telling them what to photograph. The app adds the photo upload; an organiser approves the photo from the chat.
- Every puzzle needs at least one component, otherwise the event cannot be published.

## Checklist before answering

- [ ] One JSON object, valid JSON, no comments, no trailing commas.
- [ ] Dates look like `2027-05-15T18:00` and are in this order: enrolment opens, enrolment closes, event.
- [ ] `type` of the event is `"PUBLIC"` or `"PRIVAT"`.
- [ ] Every puzzle `type` is one of `code`, `imageToUpload`, `geolocation` (avoid `redirect` and `ar`).
- [ ] Every `code` puzzle has `code`, a `code` component with a matching `codeLength`, and a `button` component.
- [ ] Every `geolocation` puzzle has both `latitude` and `longitude`.
- [ ] Every puzzle has at least one component, and every component has a valid `type`.
- [ ] `fontWeight` values are written exactly as listed, `fontFamily` is one of the ten fonts, spelled as in the list.
- [ ] Colours are `#RRGGBB`.
- [ ] No `id`, `eventId`, `status` keys.
- [ ] Images are `https://` links or left out.
