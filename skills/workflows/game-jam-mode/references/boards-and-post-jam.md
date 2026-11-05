# Task Boards, Long-Jam Plan and Post-Jam Transition

Templates for `JAM.md` and for the weeks after the jam. Copy what you need; keep the board short
enough to read in ten seconds at 3 a.m.

---

## 1. Jam task board (48-72 hours)

```markdown
## NOW (next 2 hours) -- check-in at [HH:MM]
- [ ] [task] (~[N] min)
- [ ] [task] (~[N] min)

## TIER 1 -- must be done by the halfway mark ([HH:MM])
- [ ] Core mechanic: [specific implementation]
- [ ] One level or scenario: [specific content]
- [ ] Win condition: [trigger]
- [ ] Lose condition: [trigger]
- [ ] Restart without page reload
- [ ] One sound on the player's action
- [ ] Mandatory rules met: [snippet / size / no login / AI policy]
- [ ] Draft build live on the jam platform and played from there

## TIER 2 -- only after Tier 1
- [ ] Levels 2-5
- [ ] Title screen with controls and credits
- [ ] Particles, screen shake, hit flash
- [ ] Music loop
- [ ] Difficulty ramp
- [ ] Score display

## SUBMISSION -- start at [deadline minus 4h (48h) / 6h (72h)]
- [ ] Final build exported and tested from the platform page
- [ ] /gameforge:game-web-publish hardening pass
- [ ] Page: description, AI disclosure, cover, screenshots, GIF, tags
- [ ] Submitted to the jam; visible in the entry list
- [ ] Played as a stranger from the jam page

## STRETCH -- only if everything above is done
- [ ] [stretch goal]

## CUT (do not build)
- [feature] -- why
```

## 2. Two-hour check-in script

Run it out loud, update the jam clock, then commit.

1. Finished in the last two hours: [...]
2. Playable right now? [yes / no -> fix that first]
3. One most important next thing: [...]
4. Anything from CUT being built? [no / stop it]
5. Played the latest build from the platform page? [yes / do it now]
6. Hours left: [N]. On track for Tier 1 by halfway? [yes / cut: ...]

## 3. Long-jam plan (one to four weeks)

Month-long jams (Vibe Jam ran 1 April to 1 May 2026; js13kGames traditionally runs a month) fail
differently: not from panic, but from drift. The scope of a 5-10 minute game does not grow just
because the calendar did; the extra time goes into feel, playtests and polish.

| Week | Goal | Exit check |
|---|---|---|
| 0 (before start) | Rules read into `JAM.md`; template project; deploy pipeline proven | A blank build is live on the target host |
| 1 | Core loop, playable start to end; rule compliance in code | A stranger plays a full run without help |
| 2 | Content and escalation; first round of 3-5 external playtests | The 5-10 minute arc exists; top three confusions fixed |
| 3 | Feel pass, audio, juice; second playtest round; performance on a mid-range phone | Frame rate holds on the slowest target; audio starts after the first tap |
| Final days | Freeze features; submission; buffer | Submitted at least 24 hours before the deadline |

Weekly check-in (in addition to daily commits): what shipped, what players did in the last test,
what gets cut this week, and whether anything on the CUT list has crept back in.

## 4. Post-jam transition plan

Use it only if the evaluation in week 2 says the game deserves a future.

```markdown
## Jam results
- JAM: [name]   RANK: [if any]   PLAYS/RATINGS: [numbers]
- FEEDBACK THEMES: [top 3, with a quote each]

## Keep (players loved it)
- [mechanic or moment]
- [design decision that paid off]

## Rewrite (good idea, held together with tape)
- [system] -- why it cannot be extended

## Cut (did not earn its complexity)
- [feature nobody used]

## Add (missing in the jam version)
- [feature] -- from feedback: "[quote]"

## AI provenance
- AI-USE.md rows: [N]; to move into design/ai-asset-log.md: [list]; to replace: [list]

## Transition steps
1. [ ] New repository (do not continue the jam codebase)
2. [ ] /gameforge:game-start: wiring, engine choice, LFS, agent setup
3. [ ] /gameforge:game-gdd-author: a real design document; the jam build is the reference, not the base
4. [ ] /gameforge:game-market-research: is there an audience beyond the jam?
5. [ ] Rebuild the core mechanic cleanly (/gameforge:game-vibe-code with a proper spec, or by hand)
6. [ ] Port validated decisions, not code
7. [ ] Re-enable every suspended GameForge practice: code review, accessibility, sprints, tests
8. [ ] Move AI-USE.md rows into the provenance log (/gameforge:game-ai-assets)
```

## 5. Post-jam protocol in detail

**Week 1: rest and rate.** Do not open the project. Play and rate other entries; it is the community
part of the jam, and on Ludum Dare it also affects how visible your own entry is. Read every
comment on your game and copy the useful ones into a notes file. Do not act on them yet.

**Week 2: evaluate.** With fresh eyes, answer:
- Did strangers finish it, replay it, or share it? (Behavior, not compliments.)
- Is the hook still interesting to you after a week away?
- Is there a version of it worth 6-18 months of your life, and a market for it?

Most jam games end here, and that is a good outcome: the jam taught you something and produced a
portfolio piece. Publish the source if you want to, write a short post-mortem with
`/gameforge:game-postmortem`, and plan the next jam.

**If it continues:** follow the transition steps above. The single most expensive mistake is
extending the jam codebase; agent-written jam code in particular carries vibe debt (code with no
structural rationale) that compounds with every feature. Rebuilding from a spec with an agent is
faster than it sounds, because the hard part, knowing what the game is, is already done.
