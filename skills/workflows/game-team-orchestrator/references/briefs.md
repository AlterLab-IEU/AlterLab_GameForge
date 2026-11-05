# Briefing the Studio Subagents

A subagent sees only its role definition, its project memory, the files it chooses to read and your
brief. This file gives the question lens for each role, the common ways a brief goes wrong, and a
complete worked panel you can adapt.

## 1. Role lenses

| Role (`subagent_type`) | Give it | Ask it | Off-target when |
|---|---|---|---|
| Creative Director (`gameforge:game-creative-director`) | Pillars, the artifact, the user's intent in their words | Does this serve the pillars and the intended player fantasy? What must change to fit? | It redesigns mechanics instead of ruling on fit |
| Technical Director (`gameforge:game-technical-director`) | Engine and version, platforms, frame and memory budgets, relevant code paths, the engine specialist skill path | Is it feasible within budget? Architecture, risk, smallest viable change | It answers in general terms without reading the code |
| Producer (`gameforge:game-producer`) | Milestones, team size, velocity or sprint history, deadline | What does it cost in schedule, what is the risk, what gets cut or moved? | It approves scope without naming a trade |
| Game Designer (`gameforge:game-designer`) | Design docs, playtest notes, balance data | Is the system sound: loops, edge cases, tuning, failure states? | It restates the spec instead of stress-testing it |
| Economy Designer (`gameforge:game-economy-designer`) | Economy model, prices, sinks and faucets, monetization plan | Are flows stable? Is monetization fair and compliant (PEGI 2026 criteria, loot box rules)? | It optimizes revenue without the trust check |
| Narrative Director (`gameforge:game-narrative-director`) | Story docs, branch maps, character sheets | Does it fit the story and lore? What dialogue or beats are affected? | It writes scenes nobody asked for |
| Art Director (`gameforge:game-art-director`) | Art bible, asset lists, target hardware, AI-asset policy | Visual fit, asset cost, pipeline impact, provenance | It critiques style without a budget view |
| Audio Director (`gameforge:game-audio-director`) | Sound bible, audio middleware, voice plans | Audio cost, adaptive logic, mix, voice rights | It ignores implementation cost |
| QA Lead (`gameforge:game-qa-lead`) | Test commands, recent changes, bug data, the feature spec | What breaks, how to test it, what gates the release? Run the tests and paste output | It lists generic test types without project specifics |
| UX Designer (`gameforge:game-ux-designer`) | Screens or flows, onboarding script, playtest observations | Can a new player understand and operate it? Where do they get lost? | It redesigns visuals instead of flows |
| Accessibility Specialist (`gameforge:game-accessibility-specialist`) | Input scheme, UI, audio cues, target stores and regions | Which accommodations are needed or legally required (EAA, store tags)? | It lists every guideline instead of prioritizing |

## 2. Brief failure modes

- **Missing context:** the brief says "review the dash" and assumes the subagent knows which file,
  which build and what the user disliked. Fix: file paths and the user's words.
- **Two questions in one:** "review the combat and plan the sprint". Fix: one decision per brief;
  split across roles or waves.
- **Leading the witness:** "confirm the parry window is fine". Fix: ask the open question.
- **Overlap:** four roles all comment on scope. Fix: an "Out of scope" section naming who covers what.
- **Unbounded writing:** a subagent writes a 400-line document into `design/` that nobody approved.
  Fix: "report only" unless the plan assigned a deliverable path.
- **Hidden prior decisions:** the Designer reopens a ruling the Creative Director made last week.
  Fix: list decisions already made, with role and date, and say "do not reopen".

## 3. Worked panel: design review of a grapple mechanic

Project: Ember Drift, Godot 4.7, phase `production`, pillars "tense", "readable", "short runs".
User request: "Get the team's take on the grapple design before we build it. I'm worried it makes
the levels trivial."

**Plan:** one parallel wave of four, report only. Shared input `design/gdd/grapple.md`,
`design/levels/act1.md`, `.gameforge/project.json`.

**Brief: Creative Director**
```markdown
# Brief for Creative Director: grapple mechanic fit
## Your task
Does the grapple in design/gdd/grapple.md serve the pillars "tense", "readable", "short runs",
or does it undercut tension? Rule on fit and name what must change.
## Context you cannot see
- User's words: "I'm worried it makes the levels trivial."
- Decided: no double jump (2026-10-12, Creative Director, pillar "readable").
## Read these files
- design/gdd/grapple.md, design/pillars.md, design/levels/act1.md
## Output
Report only: write no files. Label guesses ASSUMPTION:.
## Out of scope
Feasibility (Technical Director), schedule (Producer), tuning numbers (Game Designer).
```

**Brief: Game Designer**
```markdown
# Brief for Game Designer: grapple stress test
## Your task
Stress-test the grapple rules: which act 1 encounters and gaps does it bypass, what are the edge
cases (grapple during dash, onto moving platforms, out of hitstun), and what constraint keeps it
from trivializing traversal?
## Context you cannot see
- User's words: "I'm worried it makes the levels trivial."
- Decided: no double jump (2026-10-12). Runs target 20-30 minutes (design/pillars.md).
## Read these files
- design/gdd/grapple.md, design/levels/act1.md, design/balance/movement.csv
## Output
Report only. Propose at most three constraints, each with the encounters it protects.
## Out of scope
Pillar ruling (Creative Director), implementation (Technical Director), schedule (Producer).
```

**Brief: Technical Director**
```markdown
# Brief for Technical Director: grapple feasibility
## Your task
Can the grapple ship within the movement frame budget on Steam Deck, and what is the smallest
robust implementation (rope physics or kinematic pull) given the current player controller?
## Context you cannot see
- Engine: Godot 4.7.2, Jolt physics (default for new 3D projects since 4.6). Target 60 fps on Deck.
- Read the Godot specialist skill for conventions:
  <plugin root>/skills/engine-specialists/game-godot-specialist/SKILL.md
## Read these files
- design/gdd/grapple.md, src/player/player_controller.gd, docs/architecture.md
## Output
Report only. If you run anything, paste the command and its output.
## Out of scope
Whether the grapple is fun or on-pillar.
```

**Brief: Producer**
```markdown
# Brief for Producer: grapple scope
## Your task
What does the grapple cost against milestone M3 (2026-12-18), what is at risk, and what would you
cut or defer to fit it?
## Context you cannot see
- Team: two people, part time. Last three sprints delivered 70-80% of plan (production/sprints/).
## Read these files
- design/gdd/grapple.md, production/milestones/m3.md, production/sprints/
## Output
Report only. Give two scope options with dates.
## Out of scope
Design quality and feasibility (other roles cover them in parallel).
```

**Synthesis (excerpt):**
```markdown
## Team synthesis: grapple mechanic  (2026-11-05, mode: Panel)
**Recommendation:** Build the grapple with anchor-only targets and a cooldown, as a kinematic
pull; defer moving-platform grapple to after M3.
| Role | Verdict |
|---|---|
| Creative Director | Fits "tense" only if anchors are scarce and visible; free aim undercuts it |
| Game Designer | Bypasses 4 of 9 act 1 gaps; anchor-only plus a 2 s cooldown protects all 9 |
| Technical Director | Kinematic pull fits budget; rope physics risks Deck frame spikes |
| Producer | Anchor-only fits M3 with the dash polish moved to M4; full version does not |
**Where the team agrees:** constrain targets (CD, Designer); keep it simple (TD, Producer).
**Conflicts and rulings:**
- Designer wants a visible rope for readability; TD flags rope rendering cost -> technical ->
  Technical Director: draw a cheap line renderer, no simulated rope.
**Questions for you:** Move dash polish to M4? (recommended: yes)
**Next steps:** Game Designer updates design/gdd/grapple.md; then run the Core mechanic build preset.
```

## 4. Ruling brief

```markdown
# Ruling requested from [resolver]: [conflict]
Position A ([role]): [two or three lines, verbatim where possible]
Position B ([role]): [two or three lines]
Relevant constraints: [pillars / budgets / deadline]
Rule on it: which position, or what third option, with rationale, and what each side must change.
Record the ruling in your memory. Report only.
```

## 5. Re-brief after an off-target report

```markdown
# Follow-up for [role]: [topic]
Your report answered [what it answered]. The decision we need is [question].
Specifically missing: [verdict / numbers / file evidence / command output].
Everything else from the first brief still applies: [repeat the context block].
```

If the second report also misses, run the role inline and note it in the synthesis.
