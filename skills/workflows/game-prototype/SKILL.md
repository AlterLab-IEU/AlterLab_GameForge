---
name: game-prototype
description: >
  Runs hypothesis-driven prototyping: one question per prototype, a falsifiable hypothesis, the
  cheapest fidelity that answers it (paper, simulation, agent-built throwaway), a time box, observed
  playtests and a kill-or-promote call. Use for "prototype", "proof of concept", "test this
  mechanic", "is this fun". Not for building a small shippable game (use game-vibe-code).
argument-hint: "[question or mechanic to test]"
effort: high
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion, Bash(git status *), Bash(git switch *), Bash(git branch *), Bash(mkdir *), Bash(npm create *), Bash(npm install *), Bash(npm run *), Bash(npx playwright *), Bash(godot --headless *)
---

# AlterLab GameForge -- Hypothesis-Driven Prototyping

A prototype is an experiment, not a demo. Every prototype exists to answer one question, usually
"is this worth building?", and the moment you start polishing it you have stopped prototyping and
started building, possibly the wrong thing. This workflow enforces the discipline: name the question,
write a hypothesis that can fail, build the cheapest thing that tests it, watch real players, and
make a binary kill-or-promote call on the evidence.

Coding agents changed the cost of the build step, not the discipline. An agent can produce a playable
throwaway in an hour, which makes it tempting to skip the question and "just build it." Cheap builds
make a clear question more important, not less: without one you get ten prototypes and no answers.

**Continuity through files.** Read `.gameforge/project.json` (pillars, phase), `design/concept.md`,
earlier reports in `design/prototypes/`, and `production/session-state/active.md`. Each prototype
lives in `prototypes/<name>/` with a `QUESTION.md`; the report goes to
`design/prototypes/<name>-report.md`; `active.md` gets the decision and the next step. If the
project's phase is still `concept` or `pre-production`, offer to set it to `prototype`.

## When NOT to use me

| The user wants... | Route to |
|---|---|
| A small, complete, shippable game (web or jam) built with an agent | `/gameforge:game-vibe-code` |
| A jam entry with a deadline | `/gameforge:game-jam-mode` |
| An idea to prototype in the first place | `/gameforge:game-brainstorm` |
| A vertical slice to show investors or a publisher | That is a demo; plan it with `/gameforge:game-producer` |
| Tuning numbers in a mechanic already proven fun | `/gameforge:game-balance-check` |
| A structured playtest of a real build with many players | `/gameforge:game-playtest` |
| Content questions ("do players like this art style?") | `/gameforge:game-playtest` or `/gameforge:game-art-director` |

## Critical Rules

1. **One question per prototype.** Two questions means two prototypes. Combined questions
   contaminate results: when it fails, you will not know which part failed.
2. **Time-box it.** Hours for paper and agent-built throwaways, one to three days at most for anything
   else. If the question cannot be answered inside the box, decompose it.
3. **Prototype code does not graduate.** When the hypothesis is confirmed, production starts from a
   spec, not from the prototype. This is cheaper than ever with agents: hand the agent the report and
   let it build clean. Celeste is a well-documented example: *Celeste Classic* was a PICO-8 game made
   in four days for a 2015 jam; the 2018 game was a separate C# build.
4. **Ugly is correct.** Rectangles, primitives, placeholder sounds. AI-generated placeholders are fine
   if they are logged and never ship by accident (see AI placeholder assets below).
5. **Observe behavior, not opinions.** What players do outranks what they say.
6. **Kill without sentiment.** Clever, beloved, expensive: irrelevant if the evidence says no.
7. **Original designs only.** Prototype genre mechanics and your own ideas, not a recreation of a
   specific existing game; Claude Code declines those, and they teach you nothing about your game.
8. **Use the shared theory.** MDA, Flow and Self-Determination Theory are in
   `${CLAUDE_PLUGIN_ROOT}/docs/game-design-theory.md`.

## Step 1: Name the question

Start with the question, then the hypothesis. Ask the user (one AskUserQuestion round, defaults
offered) what decision this prototype will drive and what kind of question it is:

| Question type | Example | Cheapest fidelity | Evidence that answers it |
|---|---|---|---|
| **Feel** | Does a momentum grapple feel exhilarating? | Digital throwaway | Testers chain swings unprompted; lean in; retry instantly |
| **Comprehension** | Do players understand the rewind rule without text? | Digital throwaway or paper | Time to first correct use; number of interventions |
| **Decision tension** | Does stamina create real choices with two enemies? | Paper or digital | Visible pauses before acting; varied choices across testers |
| **Systems and balance** | Does the economy stay tight for ten runs? | Spreadsheet or headless simulation | Distribution of outcomes over hundreds of simulated runs |
| **Technical feasibility** | Can 500 units path on a mid-range phone at 60 fps? | Technical spike (not a design prototype) | Profiler numbers on the target device |
| **Desirability** | Will strangers click this hook on a portal? | Clip, mock store page, or 5-minute build | Click-through, plays, replays |

Then write the hypothesis in this exact form:

> "We believe that **[mechanic or system]** will produce **[player behavior or emotion]** when
> **[specific condition]**."

And the falsification criteria: at least two observable signals that would prove it false. If you
cannot say what failure looks like, the hypothesis is untestable.

| Strong | Weak (and why) |
|---|---|
| "We believe a grappling hook with momentum preservation will make traversal feel exhilarating when the player chains three or more swings without touching the ground." | "The combat will be fun." Fun for whom, when, measured how? |
| "We believe asymmetric co-op roles (one builds, one defends) will produce spontaneous call-outs when the builder can see threats the defender cannot." | "Players will like the art style." A content question; no prototype needed. |

Map the hypothesis to one MDA aesthetic (Sensation, Fantasy, Narrative, Challenge, Fellowship,
Discovery, Expression, Submission). If it maps to several, it is several questions; split it. The
signal table per aesthetic is in `${CLAUDE_SKILL_DIR}/references/evaluation-and-bake-offs.md`.

## Step 2: Choose the fidelity

Start at the lowest fidelity that can answer the question.

| Level | Method | Best for | Time |
|---|---|---|---|
| **Paper** | Cards, dice, tokens | Turn-based rules, economies, card loops | Hours |
| **Spreadsheet or script** | Formulas, Monte Carlo in a notebook | Probability, progression math | 1-2 hours |
| **Headless simulation** | Agent-built AI-vs-AI or bot runs | Balance and degenerate strategies at volume | Hours |
| **Digital throwaway** | One scene, hardcoded values, primitives; usually agent-built | Feel, input-to-feedback, spatial play | Hours to 3 days |

A stamina economy can be checked in a spreadsheet in 30 minutes; a grappling hook's feel needs a
digital build. Jumping to digital when paper would do wastes most of the time box.

## Step 3: Scope ruthlessly

Ask "what is the minimum that tests this?", then cut it in half.

- **Out:** menus, multiple levels, save/load, UI beyond the core interaction, animation (snap and
  lerp), edge cases, audio unless audio is the question.
- **In:** the core input-to-feedback loop at representative speed (if the question is about feel,
  latency matters), just enough game state to create the tension being tested, and a restart in
  under five seconds.

| Must have (tests the hypothesis) | Nice to have (clearer test) | Out of scope (production) |
|---|---|---|
| [max 5 items] | [...] | [...] |

More than five Must items means the scope is not ruthless enough; decompose.

## Step 4: Build fast (usually with an agent)

Prototype code lives in `prototypes/<name>/` on a throwaway branch (`git switch -c proto/<name>`),
never imported by production code. Before building, write `prototypes/<name>/QUESTION.md` (template
below) and tell the agent to read it first.

Read `${CLAUDE_SKILL_DIR}/references/agent-built-prototypes.md` before the first build prompt; it has
the kickoff prompt, minimal scaffolds per stack, the test hooks, and the simulation pattern. The
short version:

1. **One file is fine.** No architecture, hardcoded values, copy-paste over abstraction. You are
   writing code that will be deleted.
2. **Expose the knobs.** Every tuning value in one `TUNING` object (or exported fields in an engine),
   with a live debug panel. Most feel questions are answered by turning knobs during a session.
3. **Give the agent a check.** For web prototypes: a fixed-step `step(dt)`,
   `window.render_game_to_text()` and `window.advanceTime(ms)`, plus one Playwright test that takes a
   screenshot. For engines: one headless smoke run. The agent proves the build works before a human
   spends a playtest on it.
4. **Instant restart and a seed.** `R` restarts; `?seed=` makes runs reproducible.
5. **Budget in agent turns.** Decide up front, for example "eight prompts to playable." If the agent
   is fighting the engine past that, the scope is wrong.
6. **Bake-offs build in parallel.** Two variants, two sessions or two folders, same test hooks, same
   restart key, so the only difference is the design variable.

Target split of the time box: about 40% build, 30% test, 30% analysis. With an agent, the build share
should shrink, not the testing.

### AI placeholder assets and the AI-use log

Generated placeholders (sprites, sounds, a voice line, a temp music loop) are fine in a prototype if
three rules hold:

1. **Log every generated asset** in `prototypes/<name>/AI-USE.md` as you create it.
2. **Mark it `placeholder`** in the log and, ideally, in the file name (`ph_slime.png`).
3. **Nothing marked placeholder goes into a public build, screenshot, trailer or store page** without
   review and replacement or a recorded decision to keep it. The Indie Game Awards rescinded
   *Clair Obscur: Expedition 33*'s awards in December 2025 over generative-AI placeholder textures
   that had shipped and were later patched out.

```markdown
# AI Use Log -- prototypes/[name]
| Date | File | Kind | Tool (version) | Prompt or source (short) | Terms checked | Human edits | Status | Ship? |
|---|---|---|---|---|---|---|---|---|
| 2026-11-05 | art/ph_slime.png | sprite | [image model] | "green slime, 32 px, side view, flat colors" | [commercial use allowed?] | recolored | placeholder | no |
| 2026-11-05 | sfx/ph_dash.wav | sfx | [sfx model] | "short whoosh, airy" | [...] | trimmed | placeholder | no |
```

In the project-wide log's terms these rows are disclosure `dev-only`. Code written by an agent needs
no Steam disclosure (code assistants are exempt under Steam's 2026-01-16 rules), but jam rules
sometimes ask about it; note it when they do. When an asset graduates from placeholder to final, add
it to `design/ai-asset-log.md` (format: `${CLAUDE_PLUGIN_ROOT}/templates/ai-asset-log.md`) through
`/gameforge:game-ai-assets`, which handles license checks, human edits and disclosure.

## Step 5: Evaluate with real players

Your own opinion of your own prototype is the least valuable data you can collect. Minimum: three to
five people outside the team, observed silently.

- **Silent observation.** No explaining, hinting or reacting. If a player is stuck, wait at least 60
  seconds, then intervene and log the intervention as a finding.
- **Record** the screen (and face, if they agree). Note timestamps of delight, frustration,
  confusion, strategic pauses and disengagement.
- **Three to five questions after:** what were you trying to do; a moment that felt good; a moment
  that felt frustrating; would you play again (watch the body language).
- **Flow lens:** anxiety (too hard), boredom (too easy), or absorbed?

For systems questions, the evidence is the simulation output, not a playtest. Full protocol, the
MDA signal table, bake-off rules and solo-developer workarounds are in
`${CLAUDE_SKILL_DIR}/references/evaluation-and-bake-offs.md`. AI playtest agents can smoke-test
reachability and crashes; they do not answer feel or comprehension questions, so they never replace
the human session here.

## Step 6: Kill or promote

Binary. "Iterate on the prototype" is not an option; a new question is a new prototype.

**Kill if any one is true:**
- Fewer than two of five testers showed the target behavior or emotion.
- It works as designed but does not produce the intended feeling.
- It needs extensive explanation to be understood.
- The fun came from a different interaction than the one under test (write that down; it may be the
  next hypothesis).
- A degenerate strategy makes the intended interaction unnecessary.

**Promote only if all are true:**
- At least three of five showed the target behavior without prompting.
- The feeling appears reliably, not occasionally.
- At least one tester asked to play again, unprompted.
- No degenerate strategy trivializes it.
- It serves at least one design pillar.

**On kill:** write what you learned, share it, delete the prototype code (the report survives).
**On promote:** write a production brief (what was proven, what is still open), then build clean.

### Hand-offs after the decision

| Situation | Next |
|---|---|
| Promoted mechanic in a larger project | `/gameforge:game-gdd-author` for the spec, then `/gameforge:game-sprint-plan` |
| Promoted, and the game is a small web or jam-sized game | `/gameforge:game-vibe-code`, starting from the report as the spec (a fresh build, not the prototype code) |
| The question was really "can I make a small game this weekend?" | `/gameforge:game-vibe-code` now; this skill was the wrong tool |
| Numbers need tuning | `/gameforge:game-balance-check` |
| Ready for a broader test | `/gameforge:game-playtest` |
| Art direction or final assets needed | `/gameforge:game-art-director`, `/gameforge:game-ai-assets` |

## Working with AI Coding Agents

- **Delegate:** scaffolding, the one-file build, the debug panel, test hooks, the Playwright check,
  headless simulations that run hundreds of matches, and summarizing observation notes into the
  report. Agent-built instruments are close to free: for his browser RTS *Battle Drones*, Simon
  Willison ran more than 1,200 AI-vs-AI balance matches and had Claude build a debug tool he called
  "effectively free" (Oct 2026).
- **Verify by hand:** play every build before a tester sees it; read the simulation code that
  produces a balance conclusion (a buggy bot proves nothing); check that the variant under test
  differs only in the design variable.
- **Prompt for the question, not the game.** "Build the smallest thing that tests QUESTION.md. One
  file. Primitives only. Expose every number in TUNING. Add R to restart. Stop when the check passes
  and tell me what you did not build."
- **Ask for critique before code.** "Before building, list three ways this prototype could give a
  misleading answer." Fix the test design, then build.
- **Guard against vibe debt leaking.** Prototype code never moves into `src/`. If someone proposes
  "just cleaning it up", the answer is a new spec for a clean build.
- **Provenance:** keep `AI-USE.md` current as assets are generated, not reconstructed later.
- **Engine bridges:** if the project has an MCP server set up (via `/gameforge:game-start`), the
  agent can run the prototype and read its output itself; keep those servers on localhost.
- **Background:** verification patterns and failure modes of agent-built games are collected in
  `${CLAUDE_PLUGIN_ROOT}/docs/vibe-coding.md`.

## Output Format

### `prototypes/[name]/QUESTION.md` (before building)

```markdown
# Prototype: [name]   Time box: [N hours/days], ends [YYYY-MM-DD HH:MM]
**Decision this drives:** [build the grapple system or cut it]
**Question type:** [feel / comprehension / tension / systems / feasibility / desirability]
**Hypothesis:** We believe that [mechanic] will produce [behavior/emotion] when [condition].
**Falsified if:** [signal 1]; [signal 2]
**MDA aesthetic:** [one]   **Pillar served:** [one]
**Fidelity:** [paper / spreadsheet / simulation / digital throwaway]
**Must have (max 5):** [...]
**Out of scope:** [...]
**Testers booked:** [names, times]   **Recording:** [tool, tested yes/no]
```

### `design/prototypes/[name]-report.md` (after testing)

```markdown
# Prototype Report: [name]
**Date:** [YYYY-MM-DD]   **Time box:** [allocated] / [used]   **Built with:** [hand / Claude Code, N prompts]

## Hypothesis and falsification criteria
[as written in QUESTION.md, unchanged]

## What was built
[2-3 sentences; screenshot or clip link; tuning values at test time]

## Observations
| Tester | What they did | Delight | Friction | Flow? | Interventions |
|---|---|---|---|---|---|
| P1 | [...] | [...] | [...] | Y / N / Partial | [0] |

## Evidence
**For:** [behavioral observations]
**Against:** [behavioral observations]

## Decision: [KILL / PROMOTE]
**Reasoning:** [2-3 sentences that follow from the evidence above]

## Lessons that apply beyond this prototype
- [...]

## AI use
[Summary of AI-USE.md: tools, asset count, all placeholders? yes/no]

## Next
- KILL: [what to test next, or what we no longer need to test]
- PROMOTE: [production brief summary, open questions, hand-off skill]
```

## Quality Criteria

- The question and the decision it drives are named before any build.
- A stranger could read the hypothesis and know exactly what is being tested.
- The fidelity was the cheapest that could answer the question.
- Evidence is behavioral; the decision follows from it and could be defended to a skeptic.
- The time box held, and testing got at least as much time as building.
- No prototype code moved to production; every generated asset is in the AI-use log.
- At least one lesson applies beyond this prototype.

## Example Use Cases

1. **"Does a rewind mechanic feel good in my platformer?"** Feel question, agent-built throwaway with a
   tuning panel for rewind length and cost, five silent testers.
2. **"Turn-based with action elements, or real-time with pause?"** Bake-off: two variants built in
   parallel with identical hooks, separate tester groups, behavioral comparison.
3. **"Our GDD assumes players enjoy base-building between dungeon runs."** Decision-tension question;
   paper first, digital only if paper is inconclusive.
4. **"Is our crafting economy too generous?"** Systems question: headless simulation of 500 runs, no
   playtest needed until the distribution looks right.
5. **"Two of three testers looked bored, one confused. Kill or promote?"** Apply the criteria: kill,
   and record the confusion as a comprehension finding.
6. **"Can I make a little browser game about this idea this weekend?"** Not a prototype question;
   hand off to `/gameforge:game-vibe-code`.
