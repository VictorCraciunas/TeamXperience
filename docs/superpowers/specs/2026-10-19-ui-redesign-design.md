# UI redesign: design spec

Approved by the owner through mockups in conversation on 2026-10-19. This is the source of truth for the implementation plan in `docs/superpowers/plans/2026-10-19-ui-redesign.md`.

## Goals
1. One shared UI layer (`lib/ui/`) so any later visual change is a one-place edit.
2. A new look: raised section panels on a tinted page, high contrast, a labelled bottom navigation bar.
3. Light and dark themes, switchable by the user, light being the default.
4. A Home screen whose top card always has a job (live, starting soon, upcoming, recommended).

## Decisions (final)
- Font stays **Poppins** (weights 400/500/600/700). No new fonts.
- Layout style: the **solid full-width bottom bar** (not floating), four tabs: Acasă, Evenimente, Știri, Profil. No search button.
- Each section is a bordered **panel** with a coloured tick, bold title, optional count badge, "Vezi toate" action.
- Primary buttons use a teal→navy gradient with white text; on dark the hero CTA is a light button.
- Dark theme uses neutral blue-grey surfaces plus the existing brand teal/navy. No glows, no gradients on surfaces.
- Admin-designed puzzle components (`Component`, `utils/component_conversion/`) keep the colours the admin chose and are **not** themed.
- Event cover images come from `Event.landingImageUrl`; news from `Stire.principalImage`.

## Tokens
| Token | Light | Dark |
|---|---|---|
| page | `#E7ECF3` | `#0E1116` |
| panel | `#FFFFFF` | `#171B22` |
| border | `#CFD8E4` | `#2A303B` |
| inset (row inside panel) | `#F3F6FA` | `#11151B` |
| insetBorder | `#E1E7EF` | `#252B35` |
| text | `#0C092A` | `#F2F4F8` |
| muted | `#47546A` | `#A3ACBB` |
| accent (teal text/links) | `#1B8A8E` | `#5CC8CB` |
| tick (teal) | `#2AA5A9` | `#53C4C7` |
| navy (date block, 2nd tick) | `#222F62` | `#2A3A80` |
| navActivePill | `#DDF3F3` | `#22393C` |
| iconButtonBg (bell) | `#E3F2F3` | `#232A35` |
| live | `#E5484D` | `#E5484D` |
| soon (amber) | `#F2A93B` | `#F2A93B` |
| ctaGradient | `#2AA5A9 → #222F62` | `#2AA5A9 → #222F62` |

Radii: panel 20, hero 22, card/row 14, button 12, pill 99. Spacing: panel outer margin 14, panel inner padding 12, gap between panels 12. Borders are 1px.

## Components (all in `lib/ui/components/`)
AppButton (primary/secondary/ghost, loading, disabled), AppTextField (focus, error, helper, required marker), SectionCard, StatusPill, AppBottomNav (+AppNavItem with badge dot), HeroCardFrame, EventHeroCard (one configurable hero for all states), CountdownTiles, ChecklistRow, PosterCard, StatTile, ActionTile, AppShell.

## Home screen
Top to bottom: top bar (wordmark + bell), **hero card**, then panels. States chosen by priority:
1. **Live**: team started and not finished, event not over. Red `LIVE` pill, `h:mm:ss rămase` (event start + `Event.maxDuration` − now), "Misiunea N din M", segmented progress, button "Continuă jocul" → `Routes.eventGame`, chat icon button → `Routes.chatScreen`.
2. **Starting soon**: registered event started within the last 60 minutes, not over, team not started. Amber pill "A început", "Mai ai N min să intri", button "Introdu codul de start" → `Routes.enterCodeScreen`.
3. **Upcoming**: nearest registered future event. Pill "Următorul eveniment", countdown tiles zile/ore/min, button "Detalii înscriere" → `Routes.registerTeamDetails`, share icon.
4. **Recommended**: first future, `EventType.PUBLIC`, not registered, enrollment open (`dateStartEnrollment <= now <= dateDeadlineEnrollment`). Pill "Recomandat pentru tine", facts (date, route length, registered teams), button "Înscrie-ți echipa" → `Routes.registerTeam`.
5. **None**: no hero; show "Evenimente" panel only.

Panels below the hero: with a live/soon/upcoming hero show "Înscrierile tale" and "Noutăți"; with upcoming also "Pregătirea echipei" checklist (Înscriere confirmată, Detalii echipă complete, Codul de start available on event day); with recommended show "Cum funcționează" (3 steps) and "Evenimente" posters. "Evenimente noi/Evenimente" panel is shown when there are future events the user is not registered to.

Romanian copy is fixed as written above (sentence case, diacritics with comma-below ș ț).

## Admin Home (no approved design yet, must be accounted for)
The approved mockups cover the **player** Home only. Admin Home is designed later (plan Phase 7) and implemented after the player Home (plan Phase 8). Consequences for everything built before then:
- UI elements are **shared between player and admin**. `lib/ui/` is role-neutral: components take their content (texts, counts, callbacks) through parameters and contain no role-specific copy or logic. Player and admin screens use the *same* components and differ only in the data and labels they pass in; the mapping from domain objects to component parameters lives in `lib/features/<area>/`.
- One generic `EventHeroCard` (status pill + title + subtitle + optional time chip, segmented progress, countdown tiles + primary action + optional secondary icon action) serves every hero state: the player's live / starting soon / upcoming / recommended and the admin's live / soon.
- Other shared components for both roles: `HeroCardFrame`, `SectionCard`, `StatusPill`, `PosterCard`, `ChecklistRow`, `CountdownTiles`, plus generic `StatTile` (value + label + optional icon) and `ActionTile` (icon + label + tap), which the admin Home needs for team/person counts and quick actions.
- The navigation shell is generic (`AppShell` with a list of tabs) so an `AdminShell` can reuse it with its own tabs.
- Theme (dark mode, tokens) and the migrated admin screens (plan Phase 3c) apply to admins from the start. Until the admin shell exists, the theme toggle also sits in the admin Home app bar menu.
- Inputs for the future admin mockup (what exists today): "Eveniment live" card with "Gestionează eveniment" (`EventList.liveEvents`), per-event stats `nrTeams`/`nrPerson` (`TeamRepo.getAllTeamsForEvent`), upcoming events carousel with stats, news carousel, quick actions (create event, create news, send notification), and the dedicated screens event management (notification, map, chat, stop event), registered teams, team chats, builder.
- Likely admin hero states (to confirm in the mockup): live event (management shortcut + teams started/finished), event starting within 24 h, none.

## Out of scope for this plan
Event details, game mission list, auth and the other admin screen redesigns (separate plans; Admin Home itself is Phases 7-8), a `maxTeams` field on `Event`, enforcement of the enrollment window on the register button, Firestore security rules.
