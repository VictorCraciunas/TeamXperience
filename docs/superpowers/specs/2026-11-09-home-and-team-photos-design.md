# Home screen with pictures, team photos and memories

Agreed with Victor on 2026-11-09. Drawings: the private canvas "Home screen scenarios" (https://claude.ai/artifact/3dJbQ3kRMHzBgHWrtQXCX6), the two rows at the right ("Picture-led version" and "Team photos and memories"). The 13 screens at the left are the older idea, kept for comparison. Where they differ, this document wins.

## Why

With no events open, Acasă shows only a greeting and three small boxes, and that is what most players see between events. Questo's page never looks empty, and most of that comes from big pictures. Amintiri has few photos, because the only source today is approved photo puzzles.

## Decisions

- **Pictures lead.** The main Home card and the new-events cards show the event's main picture (`landingImageUrl`). An event without one gets a flat colour with a dashed route line.
- **Our look, not Questo's.** Same colours, type and spacing as the app. No prices, passes, filter chips, other-city rows or star averages.
- **Section titles stay plain text**, with no dot in front.
- **Team photos are optional and never block anything.** There is one start photo and one final photo per team. Any member can take or retake them, and the last one wins. No organiser approval, because every team would send one at the start, when the organiser is busiest.
- **Where they are taken:** a small card on the start-code screen, above "Pornește jocul" (before the clock runs), and a card on the finish screen, which teams reach whether they finished or ran out of time. They use the camera.
- **Who sees them:** in the app, only that team, on its finish screen and in its memories. This is about what the app shows: team documents are readable by any signed-in user, as puzzle photos already are.
- **A memory's photos** run: start, approved puzzle photos by mission, final.

## How memories get their photos

Memories keep their existing document, and the app reads the photos from the player's team (`getUserTeamForEvent`) when it shows a memory. This also solves late photos: a final photo taken after the event ended still appears, because nothing was copied.

So this work needs **no Cloud Functions change and no functions deploy**. If the team can't be read, the memory falls back to its stored `photoUrls`, then the event's picture, then the map icon.

`firestore.rules` needs a rule for the new field, to go out whenever Victor deploys the rules. The live rules allow it until then. Storage needs nothing new, because the photos go under `events/{eventId}/team_photos/`, where puzzle photos already go.

## Acasă, from top to bottom

During a game: unchanged (live card, leaderboard, team).

Otherwise, showing only the parts that have content:

1. **Greeting.** A player with no games and no XP sees a tagline and "Cum funcționează" instead of three boxes of zeros. Everyone else sees the stats. "1 joc", not "1 jocuri".
2. **Newest memory first**, if its event was in the last 3 days (photos and "Vezi pozele").
3. **Main card**, in this order of priority:
   - "Ați terminat" while the team has finished and the event still runs
   - "A început" (start code)
   - "Următorul tău joc"
   - "Recomandat pentru tine"
   - otherwise the "Niciun joc deschis acum" banner
4. **Evenimente noi:** up to 4 picture cards in two columns, without the event already recommended above.
5. **Amintiri:** the newest game, unless it already went first.
6. **Jocuri trecute:** only with no main card. Up to 4 public past events, without a "Vezi toate" link, because the Evenimente tab has no past events.
7. **Sezonul tău:** the player's best-placed crew, if it is in the season's top 10.
8. **Știri:** the latest item.

## Amintiri pages

- Tapping a memory opens a new memory page: event name, date, team, place, time, the photos with their labels, and a link to the event page when that event is still loaded. Tapping a photo opens it full screen.
- "Toate" opens a new list of all the player's memories.
- Profil uses the same album and opens the same page.

## Also fixed

- A team that finished while the start code was still open was asked for the code again. "Ați terminat" replaces this.
- The same event could appear as both the recommendation and a new event.
- The iOS app has no camera or photo library permission text, so it would crash when opening either. This already affects photo puzzles.

## Left out for now

Star averages, a shared public gallery, showing team photos on the event page (these would need approval), and using the camera for photo puzzles (they still pick from the gallery).
