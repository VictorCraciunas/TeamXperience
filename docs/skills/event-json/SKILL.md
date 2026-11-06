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
  finishPoint: String                    (needed to publish)
  startLatitude: Number                  (needed to publish)
  startLongitude: Number                 (needed to publish)
  routeLengthKm: Number                  (needed to publish, or lungimeTraseu)
  durationMinutes: Whole number          (needed to publish, or durata)
  difficulty: "easy" | "medium" | "hard" (needed to publish, or dificultate)
  area?: String
  teamSizeMin?: Whole number             (default 2)
  teamSizeMax?: Whole number             (default 6)
  maxTeams?: Whole number
  meetingPointNote?: String
  arriveMinutesBefore?: Whole number     (default 15)
  whatToBring?: List<String>
  story?: String
  organiserName?: String
  introLetter?: String
  introSignature?: String
  hintsPerMission?: Whole number         (default 1)
  enterWindowMinutes?: Whole number      (default 60)
  lungimeTraseu?: String                 (older events; write routeLengthKm instead)
  durata?: String                        (older events; write durationMinutes instead)
  dificultate?: String                   (older events; write difficulty instead)
  landingImageUrl?: String | null
  taskBackgroundImageUrl?: String | null
  screenAnimation?: "fade" | "none" | "slideFromLeft" | "slideFromRight" | "slideFromBottom" | "slideFromTop" | "zoom" | "bounce"
  animationDuration?: Whole number
  animationDelay?: Whole number
  missions: List<Mission>                (at least 1 to publish)

Mission
  title: String                          (needed to publish)
  teaser?: String
  isTeaserPublic?: true | false          (default false)
  latitude?: Number
  longitude?: Number
  puzzles: List<Puzzle>                  (at least 1 to publish)

Puzzle
  type: "code" | "imageToUpload" | "geolocation" | "redirect" | "ar"   (needed to publish)
  code?: String                          (needed to publish when type is "code")
  latitude?: Number                      (needed to publish when type is "geolocation")
  longitude?: Number                     (needed to publish when type is "geolocation")
  indiciu?: String
  maxAttempts?: Whole number             (code puzzles; default no limit)
  wrongAnswerMessage?: String            (code puzzles)
  components: List<Component>            (at least 1 to publish)

Component
  type: "text" | "image" | "button" | "code"        (required)
  spaceBelow?: Number
  opacity?: Number
  loopEffect?: "pulse" | "float" | "shake" | "flicker" | "glitch"
  text?: String
  textColor?: HexColor
  fontSize?: Number
  fontWeight?: String
  fontFamily?: String
  textAlign?: String
  letterSpacing?: Number
  lineHeight?: Number
  italic?: true | false
  uppercase?: true | false
  enableGlow?: true | false
  glowColor?: HexColor
  shadowColor?: HexColor
  shadowBlur?: Number
  shadowDistance?: Number
  animation?: "none" | "typewriter" | "decode"
  typewriterSpeed?: Whole number
  imageUrl?: String
  borderWidth?: Number
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
  answerFeedback?: true | false
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
  "finishPoint": "Turnul Sfatului",
  "startLatitude": 45.7971,
  "startLongitude": 24.1520,
  "routeLengthKm": 3,
  "durationMinutes": 120,
  "difficulty": "medium",
  "missions": [
    {
      "title": "Prima casă",
      "teaser": "Un an scris deasupra unei uși.",
      "isTeaserPublic": true,
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
| `area` | Free text, the part of town under the city on the event page, for example `"Orașul de Sus"`. |
| `finishPoint` | Free text, where the route ends, for example `"Turnul Sfatului"`. Shown at the end of the route strip. |
| `startLatitude`, `startLongitude` | Numbers, the start pin (latitude −90 to 90, longitude −180 to 180). "Hartă" on the event page opens it in Google Maps. Copy them from Google Maps: right-click the place, click the numbers. |
| `routeLengthKm` | Number from 0.1 to 100, the route in km, for example `4.5`. Shown as "4,5 km". |
| `durationMinutes` | Whole number from 10 to 600, for example `120`. Shown as "2 h", `90` as "1 h 30". |
| `difficulty` | `"easy"`, `"medium"` or `"hard"`, shown as one, two or three dots with "Ușoară", "Medie", "Grea". |
| `teamSizeMin`, `teamSizeMax` | Whole numbers from 1 to 20, how many people a team can have. Default 2 and 6, shown as "Echipe de 2–6". |
| `maxTeams` | Whole number from 1 to 500, how many teams can register. Leave it out for no limit. |
| `meetingPointNote` | Free text, exactly where teams meet, for example `"Piața Mare, lângă fântână"`. Shown as "Start:" in the logistics. When missing, `punctDeStart` is shown. |
| `arriveMinutesBefore` | Whole number from 0 to 120, default 15: "fii acolo la 9:45" for a 10:00 start. |
| `whatToBring` | A list of short texts, for example `["Telefon încărcat", "încălțări comode"]`. |
| `story` | Free text, the story on the event page ("Povestea"). Longer than three lines it folds, with "Citește tot". When missing, `description` is shown. |
| `organiserName` | Free text. Leave it out for TeamXperience. |
| `introLetter` | Free text: the letter teams read before the first mission, in the event's serif. Optional. |
| `introSignature` | Who signs the letter, for example `"Cartograful"` (shown as "— Cartograful"). |
| `hintsPerMission` | Whole number from 0 to 5, default 1: how many puzzle hints a team may open in each mission. `0` hides "Indiciu". |
| `enterWindowMinutes` | Whole number from 10 to 180, default 60: how long after the start teams can still type the start code. |
| `lungimeTraseu`, `durata`, `dificultate` | Text from older events, still read when the number fields are missing. Write `routeLengthKm`, `durationMinutes` and `difficulty` instead. |
| `landingImageUrl` | A link starting with `https://`, or `null`. The event's cover picture. Files cannot be put in the JSON. |
| `taskBackgroundImageUrl` | A link starting with `https://`, or `null`. Background behind every puzzle. Pictures are not kept inside the app: host the picture somewhere and paste its link. A dark picture needs light text (the hacker examples use light green). A sample dark picture is in `docs/event-examples/images/hacker_background.jpg`. |
| `screenAnimation` | How the components of a puzzle come in when it opens. The components come one after another, from top to bottom: `"fade"` (default) fades each in; `"slideFromLeft"`, `"slideFromRight"`, `"slideFromBottom"`, `"slideFromTop"` slide each in from that side while fading in; `"zoom"` grows each from small to full size; `"bounce"` brings each up from below, a little past its place, and settles it back. `"none"`: no animation, everything is there at once. A text with `"typewriter"`, and the glow of a button, still work with `"none"`. Pick one kind for the whole event and keep it calm: `"fade"` or `"slideFromBottom"` suit most games, `"bounce"` a playful one, `"slideFromLeft"` a terminal or hacker one. |
| `animationDuration` | Whole milliseconds from 200 to 1500: how long one component takes to come in. When missing, the whole puzzle takes 2 seconds. Not used with `"none"`. |
| `animationDelay` | Whole milliseconds from 0 to 600: how long after the one before the next component starts. `0` makes them all come in together. Missing means automatic. Not used with `"none"`. |
| `missions` | A list. The missions are played in the order written. |

**How the game looks comes from your components.** The route, the puzzle header, the progress bars, the attempts and the "Indiciu" button take their colours and fonts from the puzzles: the most common button colour (else the code field's border) is the accent, the text pieces' colour and font are the ink and the title font, the code field's fill is the cards' colour, a code frame's colour is the page, and the glow colour is the second accent. Unreadable combinations are corrected automatically. There is nothing else to set.

Keys you may see in an exported event but must **not** write: `eventId`, `status`, `isStopped`, `nrMissions`, `wizardStep`, `updatedAt`, `defaults`, and the `id` of missions and puzzles. They are ignored or set by the app.

### Mission

| Field | What it can hold |
|---|---|
| `title` | Free text, the name of the mission, for example `"Scara Pasajului"`. Needed to publish. |
| `teaser` | Free text, one short line for the event page, for example `"Numără treptele. Nu toate sunt la vedere."`. |
| `isTeaserPublic` | `true` shows the title and teaser on the event page before the game; `false` (default) counts the mission as secret ("Încă 4 misiuni secrete"). Show one or two, keep the rest secret. |
| `latitude`, `longitude` | Optional: where the mission is (-90 to 90, -180 to 180), for "la 180 m de tine" on the route. Without them the mission's first `"geolocation"` puzzle is used, else no distance is shown. |
| `puzzles` | A list. The puzzles are played in the order written. A mission is finished when its last puzzle is solved. |

### Puzzle

| Field | What it can hold |
|---|---|
| `type` | `"code"`: players type an answer. `"geolocation"`: players must walk to a place. `"imageToUpload"`: players send a photo that an organiser approves in the chat. `"redirect"` and `"ar"` exist in the app but have **no special game behaviour yet**, so do not use them. |
| `code` | Only for `"code"` puzzles. The correct answer. Not case-sensitive, spaces at the ends are ignored. Letters and digits, no longer than `codeLength` of the code component. |
| `latitude` | Only for `"geolocation"`. A number from -90 to 90, for example `45.7983`. |
| `longitude` | Only for `"geolocation"`. A number from -180 to 180, for example `24.1521`. Players count as arrived within **20 metres** of the point, so choose a spot they can reach. |
| `indiciu` | Free text. The hint for the puzzle. Optional. |
| `maxAttempts` | Only for `"code"` puzzles. Whole number from 1 to 20: how many wrong answers the team gets before the puzzle pauses for 60 seconds (the hint opens by itself). Leave it out for no limit. |
| `wrongAnswerMessage` | Only for `"code"` puzzles. What players read after a wrong answer, for example `"Nu e anul ăsta. Uită-te mai sus pe ușă."`. Default "Nu e corect. Mai încearcă." |
| `components` | A list of what is shown on the puzzle screen, from top to bottom in the order written. |

### Component: keys every kind can have

| Field | What it can hold |
|---|---|
| `type` | `"text"`, `"image"`, `"button"` or `"code"`. Required. |
| `loopEffect` | A movement the component repeats for as long as the puzzle is open. `"pulse"`: grows a little and comes back. `"float"`: rises a little and comes back. `"shake"`: a short shake left and right every 2 seconds. `"flicker"`: dims and comes back, like a faulty light. `"glitch"`: still, with a quick jump sideways now and then. Missing means no effect. Works on every kind, together with the entrance of the event. Use one or two per puzzle, on what matters (a button, a title): everything moving at once is tiring. The movement is only drawn; it stops if the phone has animations switched off. |
| `opacity` | A number from 0 to 1: how visible the component is. `1` (default) is fully visible, `0.5` half see-through, `0` invisible. Works on every kind. |
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
| `animation` | How the letters appear: `"none"` (all at once), `"typewriter"` (one by one, like typing) or `"decode"` (scrambled letters and signs that settle on the real letters from left to right, good for a hacker or spy game). Both `"typewriter"` and `"decode"` use `typewriterSpeed`. A decoding text takes the room of the finished text from the start. |
| `typewriterSpeed` | Whole number of milliseconds per letter, from 10 to 300. Default 100. Used with `"typewriter"` and `"decode"`. |
| `letterSpacing` | A number from 0 to 12: extra space between the letters, in pixels. Default 0. Good for titles. |
| `lineHeight` | A number from 0.8 to 2: the height of a line as a multiple of the font size. Default is the font's own (about 1.2). Use 1.5 or more for easy reading of long text. |
| `italic` | `true` slants the text. Default `false`. |
| `uppercase` | `true` shows the text in CAPITALS, also the Romanian letters. The text stays as written in the event. Default `false`. |
| `enableGlow` | `true` puts a soft glow around the letters in `glowColor`. When `glowColor` is missing the glow has the colour of the text. A steady glow, it does not pulse. |
| `glowColor` | Hex colour of the glow. Only used when `enableGlow` is `true`. |
| `shadowDistance` | A number from 0 to 20: how far the shadow of the letters is moved down and to the right. Default 0. |
| `shadowBlur` | A number from 0 to 30: how soft the shadow is. Default 0 (a hard edge). A shadow exists when `shadowDistance` or `shadowBlur` is more than 0. |
| `shadowColor` | Hex colour of the shadow. Default is a dark shadow. |

The glow and the shadow can be used together: the shadow is drawn behind the glow. On a dark background use a glow; on a light background use a shadow.

### Component `image`

| Field | What it can hold |
|---|---|
| `imageUrl` | A link starting with `https://`. |
| `cornerRadius` | A number from 0 to 50. Default 10. |
| `height` | A number from 150 to 500. Default 150. |
| `borderWidth` | A number from 0 to 6: the thickness of a border around the picture. Default 0 (no border). |
| `borderColor` | Hex colour of the border. Default black. Only used when `borderWidth` is more than 0. |
| `enableGlow` | `true` puts a steady glow around the picture, in `glowColor`. |
| `glowColor` | Hex colour of the glow. Only used when `enableGlow` is `true`. |
| `shadowDistance` | A number from 0 to 20: how far the shadow is moved down and to the right. Default 0. |
| `shadowBlur` | A number from 0 to 30: how soft the shadow is. Default 0. A shadow exists when `shadowDistance` or `shadowBlur` is more than 0. It follows the rounded corners. |
| `shadowColor` | Hex colour of the shadow. Default is a dark shadow. |

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
| `borderWidth` | A number from 0 to 6: the thickness of the border. Default 1.5. `0` removes the border. |
| `shadowDistance` | A number from 0 to 20: how far the shadow is moved down and to the right. Default 0. |
| `shadowBlur` | A number from 0 to 30: how soft the shadow is. Default 0. A shadow exists when `shadowDistance` or `shadowBlur` is more than 0. It follows the rounded corners. |
| `shadowColor` | Hex colour of the shadow. Default is a dark shadow. |
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
| `shadowDistance` | A number from 0 to 20: how far the shadow is moved down and to the right. Default 0. |
| `shadowBlur` | A number from 0 to 30: how soft the shadow is. Default 0. A shadow exists when `shadowDistance` or `shadowBlur` is more than 0. It follows the rounded corners. |
| `shadowColor` | Hex colour of the shadow. Default is a dark shadow. |
| `answerFeedback` | `true` (default) or `false`. When on, a wrong answer shakes the code input left and right and flashes it red, and a right answer makes it pop and flash green before the game goes on (about half a second). Write `false` to switch it off. It works with the phone's own setting: with animations off nothing moves. |
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
| `"Gelasio"` | Book serif like Georgia: letters, diaries, old maps, long story text. | 400 to 700 |

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
- [ ] The event has `finishPoint`, `startLatitude`, `startLongitude`, `routeLengthKm`, `durationMinutes` and `difficulty` (`easy`, `medium` or `hard`).
- [ ] Every mission has a `title`; one or two have `isTeaserPublic: true` and a `teaser`.
- [ ] Every puzzle `type` is one of `code`, `imageToUpload`, `geolocation` (avoid `redirect` and `ar`).
- [ ] Every `code` puzzle has `code`, a `code` component with a matching `codeLength`, and a `button` component.
- [ ] Every `geolocation` puzzle has both `latitude` and `longitude`.
- [ ] Every puzzle has at least one component, and every component has a valid `type`.
- [ ] `fontWeight` values are written exactly as listed, `fontFamily` is one of the ten fonts, spelled as in the list.
- [ ] Colours are `#RRGGBB`.
- [ ] No `id`, `eventId`, `status` keys.
- [ ] Images are `https://` links or left out.
