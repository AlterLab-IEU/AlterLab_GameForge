# Post-Launch Operations

The first weeks after release decide whether a game builds momentum or goes quiet. This file holds
the cadence model, platform update mechanics, community plan, metrics approach and roadmap
template. Numbers marked *rule of thumb* are planning defaults, not industry statistics; replace them
with your own data as soon as you have it.

## 1. Three-tier update cadence

```
UPDATE CADENCE
-------------------------------------------------------------
HOTFIXES   (launch week, then as needed)
  Scope:    crashes, progression blockers, save corruption, exploits
            that break the economy or leaderboards
  Target:   24-72 hours from confirmed report to live (rule of thumb)
  Process:  fix -> abbreviated Phase 1 gate -> beta branch -> verify -> default
  Comms:    "We're aware, fix in progress" within a few hours of a
            confirmed report; players tolerate bugs better than silence

CONTENT PATCHES   (every 2-4 weeks for the first months, rule of thumb)
  Scope:    balance from live data, quality of life, batched fixes,
            small additions
  Process:  plan -> build -> QA -> staging branch -> deploy -> monitor
  Comms:    patch notes for players: say why, not only what
            ("The Iron Sword trivialized mid-game bosses, so its damage
            now matches other tier-2 weapons" beats "-15% damage")

MAJOR UPDATES   (every few months)
  Scope:    new areas, modes, systems, paid DLC
  Process:  full milestone cycle (/gameforge:game-sprint-plan)
  Comms:    announce in advance with a trailer or devlog; each update gets
            a name and a theme so press and creators have a story
-------------------------------------------------------------
```

Public examples of named-update cadences: Supergiant's *Hades* ran in Early Access from December
2018 to its September 2020 1.0 with a series of named major updates; ConcernedApe has shipped free
major *Stardew Valley* updates since its 2016 release, most recently 1.6 in March 2024. Copy the
principle (themed, announced, regular), not the scale.

## 2. Platform update mechanics

| Platform | How updates ship | Notes |
|---|---|---|
| Steam | Upload a build to a branch in Steamworks, test on a password-protected beta branch, then set it live on default | No re-review for updates once the game is approved. Rehearse the promotion and the rollback (set the previous build live) before launch. Post patch notes as a Steam event or announcement. |
| Epic Games Store | Build upload and promotion through the Epic Developer Portal | Keep version parity with Steam or say why not. |
| itch.io | butler pushes per-channel builds | Small diffs; channels per platform. |
| Consoles | Patch submission and certification per platform | Learn each platform's expedited path for critical fixes before launch week. |
| iOS / Android | Store review per update | Apple and Google review times vary; staged rollout on Google Play limits blast radius. |

## 3. Refunds and review scores

- Steam grants refunds on request for purchases within 14 days with under 2 hours of playtime. A
  game whose hook arrives after two hours, or that runs badly on common hardware, will see it in
  refunds first.
- Track refund reasons in Steamworks; they are the most honest feedback you get in week one.
- Steam's review summary labels a game "Mixed" below 70% positive. Respond to negative reviews with
  specifics and fixes, never with arguments. Developer responses are public and permanent.

## 4. Community channels

```
COMMUNITY PLAN (owner per channel)
-------------------------------------------------------------
Discord      set up before launch: announcements, bug reports, feedback,
             general, creations. Moderators named. Pinned "known issues"
             post updated live during launch week.
Steam forums monitored daily for the first month; known-issues thread
             pinned; link fixes to the patch notes that shipped them.
Reddit       launch post in relevant subreddits that allow self-promotion;
             present in the comments; no astroturfing.
Social       short clips of the moments that sell the game; repost player
             creations with permission and credit.
Newsletter   for wishlisters off Steam and for the next project.
-------------------------------------------------------------
```

AI-assisted feedback summarizers (FirstLook, Accord and similar) can triage volume, but none
publishes accuracy benchmarks: spot-check their summaries against the raw reviews before acting.

## 5. Metrics without invented benchmarks

Set targets from your own evidence: demo playtime and completion from Next Fest, playtest retention,
wishlist conversion after your last discount, and comparable titles' public review counts. Write the
target and its source next to each metric.

```
POST-LAUNCH METRICS (daily for 30 days, weekly after)
-------------------------------------------------------------
Retention     D1 / D7 / D30 returning players; target: [from playtests]
              A large D1 to D7 drop points at mid-game content or pacing.
Engagement    median session length vs design target; sessions per player
              per week; completion rate (narrative games)
Funnel        % reaching each milestone (tutorial end, first boss, act 2);
              the steepest drop is the next patch's priority
Revenue       daily revenue and 7-day average; refund rate and reasons;
              wishlist conversion at launch and per discount
Sentiment     review score trend; top praise and complaint themes
Stability     crash-free sessions; crashes by GPU/driver/OS; error volume
              after each patch (rising = regression)
-------------------------------------------------------------
```

Instrumentation and dashboards: `/gameforge:game-analytics-setup`.

## 6. Twelve-month roadmap template

Draft it before launch; share a player-facing version once the first hotfixes land.

```
POST-LAUNCH ROADMAP: [Game]
-------------------------------------------------------------
Month 1     Stability and balance
            - Hotfixes from launch telemetry and reports
            - Balance pass from live data
            - Two or three community-requested quality-of-life changes
Months 2-3  First content update "[name]"
            - [new area / mode / character]
            - Accessibility improvements from player feedback
Months 4-6  Major update "[name]" or DLC
            - Align the release with a Steam seasonal sale or festival
            - Press and creator outreach: "now with [feature]"
Months 6-12 Decision point: growing / stable / declining
            - Growing: plan the next content year, DLC or expansion
            - Stable: quarterly patches; team moves to the next project
            - Declining: final polish patch, honest message to players,
              redirect the team
-------------------------------------------------------------
```

## 7. Communication templates

Holding statement (draft before launch):
```
We're aware of [issue] affecting [who/where]. We're working on a fix and
will update this post by [time + timezone]. If you're affected, [workaround].
Thank you for your patience and for the reports.
```

Patch notes skeleton:
```
[Game] [version] "[update name]"  [date]
Highlights: [1-3 lines a player cares about]
Fixes: [player-visible symptom] (thanks to [community reporter] if they agree)
Balance: [change] because [reason]
Known issues: [list, with workaround]
```

## 8. Early Access to 1.0 checklist

- Store page Early Access questions updated; price change announced in advance
- Save migration from every Early Access version tested
- 1.0 is a marketing beat: new trailer, press outreach, wishlist email fires at the transition
- Review score context: consider whether to reset the narrative with a named 1.0 update rather than
  a quiet version bump
- Run `/gameforge:game-postmortem` on the Early Access period before the 1.0 push
