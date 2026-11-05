---
name: game-playtest
description: >
  Plans, runs and analyzes playtests: research questions, observation and think-aloud protocols,
  remote and browser sessions (itch.io, Steam Playtest), consent, surveys and evidence-graded
  findings, with AI playtest agents as validated supplements. Use for "playtest", "player feedback",
  "playtest report". Not for bug hunting or test automation (use game-qa-lead).
argument-hint: "[build, feature or question to test]"
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion
effort: medium
---

# AlterLab GameForge -- Structured Playtest

Playtesting is not asking players whether they had fun. It is disciplined observation of what
players do, so you can see where the design communicates and where it fails. What players say is
useful context; what their hands do is evidence. This workflow turns sessions with real people into
findings the team can act on, and keeps the newer tools (AI playtest agents, feedback summarizers,
browser builds) in their proper place: useful supplements, never the primary instrument.

## Purpose & Triggers

**Use this workflow when:**
- A build is ready for outside eyes and you need structured findings, not reactions.
- A specific design question needs an answer: "Do players understand crafting?" rather than "Is it good?"
- Onboarding needs validation: can a new player learn the core verb without a tutorial?
- The difficulty curve needs checking against real players, not the team's muscle memory.
- You have raw notes, recordings, survey exports or Discord/Steam feedback to analyze.
- You want a repeatable remote or browser-based playtest setup as a solo developer.

**Do NOT use this workflow when:**

| Need | Route to |
|---|---|
| Testing one raw mechanic in isolation | `game-prototype` |
| Finding bugs, smoke tests, automated or AI-agent QA runs | `game-qa-lead` |
| Tuning numbers, simulations, win rates | `game-balance-check` |
| Heuristic usability review or onboarding redesign | `game-ux-designer` |
| Testing with disabled players, accommodation checks | `game-accessibility-specialist` (co-run) |
| Building the telemetry pipeline and dashboards | `game-analytics-setup` |
| Market validation, wishlist tests, marketing quotes | `game-market-research` |
| Publishing a public web build to portals | `game-web-publish` |

If the build crashes or softlocks on the path you want to test, stop: run the playtest-build gate
in `game-qa-lead` first. Testers who spend the session hitting bugs give you bug reports, not
design findings.

## Inputs I Read First
- `.gameforge/project.json` (phase, pillars, engine), the GDD sections for the feature under test
  in `design/`, previous reports in `tests/playtests/`, and `production/session-state/active.md`.
- Then ask up to three AskUserQuestion items, each with a default:
  1. **Goal**: first impression (default for early builds), targeted feature, difficulty curve,
     full playthrough.
  2. **Format**: remote moderated over a call (default for solo devs), in person, remote
     unmoderated (browser build or Steam Playtest).
  3. **Tester pool**: friends of friends, the game's Discord, strangers (Steam Playtest, itch.io
     restricted page). Default: people who have never seen the game and match the target audience.

## Critical Rules

1. **Questions before testers.** Every playtest answers 3-5 specific, observable questions. "Is it
   fun?" is not a question. "Do players use the dodge roll unprompted in the first two encounters?" is.
2. **The facilitator does not play, help or react.** Your neutral face is an instrument. If a
   tester asks "what do I do?", answer "what do you think you should do?"
3. **Size the round to the question.** About five testers per round surfaces most qualitative
   usability problems for one homogeneous audience segment (Jakob Nielsen, "Why You Only Need to
   Test with 5 Users", 2000), provided you iterate and test again. Quantitative claims (completion
   rate, average rating, A/B differences) need far more; below about 20 testers, report counts
   ("4 of 6"), not percentages.
4. **The team is not the sample.** Internal sanity passes are fine; they do not count as
   playtests. The team cannot un-know the game.
5. **Behavior outranks words.** "The controls feel fine" plus 11 wrong-button presses in ten
   minutes is a controls finding.
6. **Observe now, interpret later.** Record what happened during the session. Decide what it
   means afterward, with all sessions side by side.
7. **Humans are the primary instrument.** AI playtest agents and feedback summarizers supplement
   human sessions; their output is a lead to check, never a finding on its own.
8. **Consent before recording.** No screen, face, voice or telemetry capture without informed,
   written consent that says who will see it, how long it is kept and whether any AI service
   processes it.
9. **Ground the analysis in theory.** Use Flow and MDA from
   `${CLAUDE_PLUGIN_ROOT}/docs/game-design-theory.md` when reading engagement and difficulty.

## Workflow

**Step 1: Define Questions and Signals**

Write 3-5 questions. Each must be observable (answerable by watching), actionable (the answer
changes a design decision) and scoped (answerable in one session). For each question, define:
- **Positive signals**: behaviors that mean the design works.
- **Negative signals**: behaviors that mean it fails.
- **Observation window**: where in the session to watch closest.

```
Q2: Do players discover the grapple without the tooltip?
  Positive: uses grapple on the first anchor within 60 s of seeing it
  Negative: walks past 2+ anchors; tries to jump the gap 3+ times
  Window:   Room 4 (first anchor) through Room 6
```

**Step 2: Choose the Format**

| Format | Best for | You lose |
|---|---|---|
| In person, silent observation | First impressions, onboarding, emotion | Scale; testers act politer when watched closely |
| Remote moderated (call + screen share + webcam) | Default for small teams; targeted features | Some body language; hardware variance |
| Remote unmoderated (browser build, Steam Playtest, itch.io restricted page) | Volume, natural setting, difficulty curves via telemetry | The "why"; you see outcomes, not hesitation |
| Think-aloud (any of the above) | Understanding mental models and UI reading | Natural pacing; talking changes play |

Read `${CLAUDE_SKILL_DIR}/references/remote-and-web-playtests.md` before setting up any remote or
browser-build session: it covers itch.io restricted pages and download keys, Steam Playtest,
browser-build hygiene, recording setup, async protocols and leak risk.

**Step 3: Prepare the Build and Environment**
- The build passes the playtest-build gate (quick suite green, no S1 on the tested path).
- Build ID visible on screen; debug overlays, cheats and dev shortcuts disabled.
- Every tester starts from the same clean state (fresh save or named scenario).
- Telemetry, if used, is minimal and disclosed: session start/end, level start/complete, death
  (with position and cause), quit point, settings changed. Nothing identifying.
- Recording tested with a dry run: screen plus game audio, webcam if consented, timestamps synced
  to game events (show a session timer or log real time with each event).
- Consistent hardware and input for in-person sessions; for remote, log each tester's device,
  input and frame rate, because they contaminate difficulty findings.
- Prepare the per-player observation sheet (Output Formats) and the survey.

**Step 4: Consent and Privacy**
Before anyone plays: written consent covering what is recorded, why, who sees it, retention
period, whether any third-party or AI service processes it, and how to withdraw. Pseudonymize
testers (P01, P02) everywhere outside the consent records. Adults only unless you have a
guardian's consent and a real reason to test with minors. Read
`${CLAUDE_SKILL_DIR}/references/consent-and-privacy.md` before the first session for the consent
template, data-handling rules and the extra steps for EU/UK testers and minors.

**Step 5: Run the Session (Silent Observation Protocol)**

Brief helpers: their only job is to observe and record. If a tester is stuck for more than about
90 seconds on something that is *not* the subject of the test, one neutral hint is allowed; log
it as a finding and mark the data after it as contaminated.

Record timestamped observations in five categories:

| Category | What to record | Example |
|---|---|---|
| **Action** | Decisions, routes, input patterns | "02:14 circles boss 15 s before first attack" |
| **Hesitation** | Pauses and where they happen | "05:40 6 s pause on upgrade menu, cursor hovering two options" |
| **Confusion** | Expectation mismatches, repeated failed inputs, re-reading text | "07:02 presses interact on locked door 4x; expected key prompt" |
| **Emotion** | Delight, frustration, engagement, disengagement | "09:15 laughs at ragdoll; leans forward" / "11:30 sighs, checks phone" |
| **Verbal** | Unprompted remarks, think-aloud narration | "'this is easy', then dies three times" |

Expectation mismatches (the player clearly expected X and got Y) are the highest-value
observations in any session. Map emotions to game moments so you can compare the observed arc
with the intended arc in the GDD. Flow shows up as quiet focus, rhythmic input, surprise when told
time is up; anxiety as erratic input and repeated deaths; boredom as phone checks and rushing.

**Step 6: Debrief and Survey**

Keep the debrief to 5-7 minutes while the experience is fresh. Ask in this order:
1. "What was the game about?" (did the fantasy and theme land)
2. "What were you trying to do most of the time?" (did the core loop read)
3. "Was there a moment that stood out as good?" (cross-check against observed delight)
4. "Was there a moment that felt confusing or frustrating?" (cross-check against observed friction)
5. "If you could change one thing, what would it be?"

Short on time, use the four-question version: "What confused you? When were you bored? When did
you want to stop? What would you show a friend?" The last answer is often the hook your trailer
should lead with.

Do not ask "Did you like it?" (social pressure makes it useless), "Would you buy it?" (puts them in
reviewer mode), or leading questions ("Did you notice the lighting change?").

Then hand over the written survey built from `${CLAUDE_PLUGIN_ROOT}/templates/playtester-survey.md`
(pre-play profile, facilitator observation sheet, post-play ratings and open questions, hypothesis
block). Trim it to the questions this round needs; long surveys produce careless answers.

**Step 7: Analyze**

Wait until all sessions in the round are done so the last tester does not dominate your thinking.
- **Cross-player matrix**: rows are game moments or features, columns are testers, cells are
  observations. Patterns across 3+ testers are systemic; single-tester observations are leads.
- **Divergence points**: moments where testers split into distinct behaviors usually mark a design
  fork to resolve or embrace.
- **Triangulate**: behavior + survey + telemetry. A finding supported by two sources outranks one
  supported by a single source.
- **Classify severity with evidence thresholds** (per round of about five):

| Severity | Definition | Minimum evidence |
|---|---|---|
| **Critical** | Core experience breaks or the intended emotion inverts | 4+ of 5 testers show it, or 1 session-ending failure (crash, softlock, cannot proceed) |
| **Major** | Experience noticeably degraded but player proceeds | 3+ of 5 with behavioral confirmation |
| **Minor** | Noticed, little impact | 2 of 5 verbally, or 1 behaviorally |
| **Observation** | Interesting, no action yet | Any smaller signal |

  A 2-of-5 split is a finding to watch, not to act on; if it recurs next round, escalate to Major.
- **Recommendations** for every Critical and Major finding: what to change (concrete: "add a
  checkpoint before the room 3 ambush" not "make it easier"), why (the observed behavior), the
  expected effect in the next round, and likely side effects.
- **Longitudinal comparison**: for each previous finding, Fixed / Improved / Unchanged / Regressed.
  Problems that survive two fix attempts are structural; flag them to `game-designer`.

**Step 8: Report and Hand Off**
- Write the report (Output Formats) to `tests/playtests/YYYY-MM-DD-[build].md` with a two-sentence
  executive summary at the top.
- Bugs go to `game-qa-lead` in its bug format; usability findings to `game-ux-designer`; balance
  signals (deaths per encounter, completion times) to `game-balance-check`.
- Delete or archive raw recordings on the schedule promised in the consent form.
- Update `production/session-state/active.md` with the top findings and the next playtest date.

## AI-Assisted Workflow

AI tools speed up the work around a playtest. They do not replace watching people play.

**Good uses**
- Drafting test questions, observation sheets and trimmed surveys from the GDD.
- Adding the telemetry events above and a script that turns event logs into per-player timelines
  and death heatmaps (`/gameforge:game-vibe-code` builds these quickly for web and engine games).
- First-pass clustering of survey free text and debrief transcripts, with every cluster linked to
  its source lines.
- Running AI playtest agents *before* humans to clear softlocks and broken paths. modl.ai
  (black-box agents that read the screen and take plain-language test tasks) and nunu.ai
  (end-to-end agent testing) target this; `game-qa-lead` owns evaluating them.

**Feedback summarizers need validation on your data.** Tools such as FirstLook (aggregates Steam
and Discord feedback, with an MCP agent) and Accord (AI community-feedback analysis) publish no
accuracy benchmarks as of November 2026. Before relying on one:
1. Hand-code 50-100 real feedback items from your own game into themes.
2. Run the summarizer on the same items and compare: which of your themes did it miss, which
   did it invent, and did it keep low-frequency but serious signals (accessibility complaints,
   motion sickness, crashes on one GPU)?
3. Check every quote it surfaces against the source. Reject any tool that paraphrases into quotes.
4. Re-check quarterly or after the tool updates its model.

**Guardrails**
- Critical findings are confirmed by a human watching the recording, never from a summary alone.
- Recordings and transcripts go to a third-party AI service only if the consent form said so.
  Strip names, voices and faces first where possible.
- AI agents have no expectations to violate, no feelings and no social behavior. They cannot
  measure first impressions, frustration, delight or readability.

**Prompt that works**: "Here are 6 observation sheets and the survey export. Build the
cross-player matrix (moments x testers), list patterns seen in 3+ testers with the timestamps that
support each, and flag anything you inferred rather than read. Do not assign severity yet."

## Output Formats

**Session Plan**
```
SESSION PLAN -- [Game] [Build ID] -- [YYYY-MM-DD]
Goal: [first impression / targeted feature / difficulty / full playthrough]
Format: [in person / remote moderated / remote unmoderated / think-aloud]
Testers: [n] from [pool]; screened for [target audience criteria]; never seen the game: [y/n]
Session: [10 min setup] + [40 min play] + [7 min debrief] + [5 min survey]

Questions (max 5) and signals:
Q1: [question] | +[positive signal] | -[negative signal] | window: [where]
Q2: ...

Build: [ID], start state [save / scenario], debug off, telemetry events [list or none]
Recording: [screen+audio tool], webcam [consented / not used], timestamps [session timer on screen]
Consent: form v[x] signed by all; retention [30 days]; AI processing [none / tool name]
Known issues to ignore: [list]
```

**Per-Player Observation Sheet**
```
Tester: P03 | Date: [YYYY-MM-DD] | Build: [ID] | Device/input: [PC, Xbox pad, 60 fps]
Facilitator interventions: [none / 12:40 hint about lever -- data after this point contaminated]

[MM:SS] [Category] [Observation]                                   [Q#]
04:12   Confusion  Presses interact on locked door 4x, no feedback  Q1
06:30   Hesitation 8 s on skill menu, hovers dash then shield       Q3
09:15   Emotion    Laughs at enemy ragdoll, leans in                --

Debrief (verbatim): Q1 "..." Q2 "..." Q3 "..." Q4 "..." Q5 "..."
```

**Playtest Report**
```markdown
# Playtest Report: [Build ID] -- [YYYY-MM-DD]
**Facilitator:** [name] | **Testers:** [n] ([pool, audience notes]) | **Format:** [format] | **Avg session:** [min]

## Executive Summary
[Two sentences: the most important finding and the recommended priority action.]

## Questions
| # | Question | Answer | Evidence |
|---|---|---|---|
| Q1 | Do players find the grapple unprompted? | Partially: 2 of 5 | Sheets P1-P5, 04:00-07:00 |

## Findings
| ID | Finding | Severity | Testers | Moment | Recommendation | Expected effect next round |
|---|---|---|---|---|---|---|
| F1 | Locked door gives no feedback; 4 of 5 retried interact | Critical | 4/5 | Room 2 | Add locked SFX + key icon prompt | Retries drop to 1 or fewer |

## Emotional Arc (observed vs intended)
Opening: curious (intended: curious) -> Room 2: frustrated (intended: tense) -> Boss: engaged (intended: triumphant) -> End

## Onboarding
- Core verb understood without help: [x of n] | Time to first successful use: [median]
- Tutorial text read vs skipped: [x / y] | Most common first failure: [cause]

## Flow Read (per game-design-theory.md)
- Anxiety spikes: [moments] | Boredom dips: [moments] | Apparent flow: [moments]

## Compared with Previous Round
| Previous finding | Status | Notes |
|---|---|---|
| F3 (camera snap on dash) | Fixed | 0 of 5 commented, no observed disorientation |

## AI-Assisted Inputs (if used)
- [Tool]: [what it produced], validated by [method], discrepancies: [list]

## Actions
1. [Action] -- addresses F1, owner [role], before next round
2. [Action] -- addresses F2, F4

## Data Handling
Recordings stored at [location], deleted on [date] per consent v[x].
```

## Quality Criteria
- Every question is observable, actionable and scoped; none is "is it fun?"
- At least 80% of findings rest on behavior, with verbal data as support.
- Critical and Major findings meet the evidence thresholds; splits are reported as splits.
- Every Critical and Major finding has a concrete recommendation and an expected effect.
- Facilitator interventions are logged and the affected data marked.
- Consent was collected before recording; retention and AI processing were disclosed.
- Any AI-produced summary or cluster is traceable to source observations and was spot-checked.
- The report compares against the previous round when one exists.

## Example Use Cases
1. "First playable build is ready. Plan a remote playtest for five strangers with an itch.io link."
2. "Here are my notes on 6 players. Build the cross-player matrix and a prioritized report."
3. "Players keep dying in level 3. Design a targeted playtest to tell a difficulty spike from a
   readability problem."
4. "We changed the controls after last month's test. Design a follow-up that checks the fix."
5. "Is FirstLook's summary of our Steam Playtest feedback trustworthy? Help me validate it."
6. "I'm a solo dev on a browser game. Set up an unmoderated playtest with consent and minimal
   telemetry."
