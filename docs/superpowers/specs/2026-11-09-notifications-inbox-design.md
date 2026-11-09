# Notifications behind the bell

Agreed with Victor on 2026-11-09. Drawings: the private canvas "Home screen scenarios" (https://claude.ai/artifact/3dJbQ3kRMHzBgHWrtQXCX6), the row "Notifications behind the bell". Example texts in the drawings are samples; the copy below wins.

## Why

The bell on Acasă opens the news list, which makes no sense for a bell, and news already has its own carousel and "Toate" link. Pushes go straight to the phone and nothing keeps them, so a missed push is gone.

## Decisions

- **The bell opens a new page, Notificări**, and its red dot means an unread notification. News keeps its carousel and "Toate", and no longer affects the bell.
- **For players only.** Organisers have no bell. Team messages to organisers stay push-only.
- **Each player has their own list** at `users/{uid}/notifications/{id}`: `kind`, `title`, `body`, `createdAt`, `read`, and optionally `eventId`, `teamName`. Only the server writes them. A player can read their own and set `read` to true, nothing else.
- **What goes in the list:**

| Kind | When | Who | Title | Body |
|---|---|---|---|---|
| `announcement` | The organiser's push or "Anunț" | Everyone it's sent to | what the organiser typed | what the organiser typed |
| `chat` | The organiser writes in a team's chat | That team | `Mesaj de la organizator` | the text, cut at 100 characters, or `A trimis o poză.` |
| `team` | Someone joins a crew | The captain | `Echipa ta crește` | `{name} a intrat în {crew}` |
| `team` | A captain signs the crew up | The other players on the team | `Echipa ta s-a înscris` | `{team} merge la {event}, pe {14 nov}` |
| `results` | An event's results are worked out | Every player counted | `Rezultatele sunt gata` | `Echipa {team} a ieșit pe locul {n} la {event}.` |

- The last two rows and the results are **new pushes too**, so a list entry and a push always go together. A list entry is also kept for a player with no push token.
- **A failure never gets in the way:** a list that can't be written is logged and the push, the sign-up or the results carry on. Results are recorded once per player, even when they're worked out again.

## The page

As drawn:
- App bar `Notificări`, with `Marchează citite` when something is unread.
- Newest first, the latest 50, grouped under `Azi` and `Mai devreme`.
- Unread rows are tinted with a red dot.
- Time: `chiar acum`, `acum 10 min`, `acum 1 h`, and from yesterday back the date, `7 nov`.
- Empty: `Nicio notificare încă` and `Aici apar mesajele organizatorului, noutățile echipei tale și rezultatele jocurilor.`
- It can't load: `Nu am putut încărca notificările.`

**Tapping** marks a row read and opens what it's about:
- `chat`: the team chat.
- `results`: the memory page.
- `team` or `announcement` with a loaded event: the event page.
- `team` with no event: the Echipe tab.
- Anything else stays on the page. If what it points to is gone, it stays on the page without an error.

## Left out for now

Opening the right page when a push itself is tapped (today it only opens the app), an organiser's list, deleting or expiring old entries, and a notification when a photo is approved.

## What Victor has to do

A **functions deploy** (`sendNotification`, `onChatMessage`, `joinTeam`, `registerTeam`, `onEventStopped`, `closeExpiredEvents`) and the **rules deploy** that was already waiting. Until the functions go out the page stays empty. Only notifications sent after that appear.
