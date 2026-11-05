---
name: game-design-review
description: >
  Reviews an existing game design document or feature spec with a severity-rated rubric:
  pillar alignment, MDA and player-psychology fit, internal consistency, scope, testability for
  agent-built games, originality and IP risk, AI-content disclosure, and accessibility hooks.
  Ends in a build-readiness verdict. Use for "review my GDD", "design feedback", "critique this
  spec", "is this design ready to build". Not for writing a GDD from scratch (use game-gdd-author).
argument-hint: "[path to design document or section]"
effort: high
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion
---

# AlterLab GameForge -- Design Document Review

A game design document is a contract between ambition and execution capacity. A bad GDD is not
badly formatted; it is one that lets the team build confidently in the wrong direction for weeks
before anyone notices. Most fail because they describe a game without constraining it: anything
goes, so nothing coheres.

This is not a checklist review. A checklist confirms sections exist. This review confirms they are
good: internally consistent, psychologically grounded, scope-honest, and specific enough to drive
implementation. In 2026 that last test is literal. When a GDD section goes to Claude Code or a
similar agent, every vague sentence becomes a guess in code, so this review also asks: **could an
agent build this, and could a test tell whether it built it right?** And because players, stores
and regulators now care how a game was made, it checks originality, AI-content disclosure and
accessibility while changes are still cheap.

## When to Use / When Not To

Use before implementation starts, as a gate before a section is handed to a coding agent, after
significant design changes, when a playtest went badly and the cause may be in the design, or when
the team disagrees about what the game is.

| Instead of this skill... | Use |
|---|---|
| Writing or rebuilding GDD sections | `/gameforge:game-gdd-author` |
| Generating new ideas | `/gameforge:game-brainstorm` |
| Tuning numbers against play data | `/gameforge:game-balance-check` |
| Timeline vs capacity in depth | `/gameforge:game-scope-check` |
| Reviewing code or architecture | `/gameforge:game-code-review` |
| Full accessibility audit | `/gameforge:game-accessibility-specialist` |
| Store compliance and disclosure forms at launch | `/gameforge:game-launch` |

## Critical Rules

1. **Read the whole document before commenting.** A mechanic that looks orphaned in §5 may be
   justified in §11. Read everything, including linked pillars and the systems index, then analyze.
2. **Severity is explicit.** Critical, Major, Minor or Suggestion on every finding, with a reason.
   A missing core loop is Critical; a vague art reference is Minor.
3. **Specific, cited, actionable.** "Combat could be better" is useless. "§5.1 specifies player
   attacks but no enemy behaviour, so difficulty cannot be tuned" is a finding. Name the problem,
   cite the section, propose a fix.
4. **Propose, do not prescribe.** The designer owns the vision. Offer directions with reasons; do
   not rewrite their sections. Route rewrites to `/gameforge:game-gdd-author`.
5. **Ground it in theory.** Tie findings to `${CLAUDE_PLUGIN_ROOT}/docs/game-design-theory.md`:
   "this spike violates Flow because §11 has no skill-building ramp before Stage 3" beats "Stage 3
   is too hard."
6. **Contradictions beat omissions.** The costliest GDD failures are sections that disagree, not
   sections that are missing.
7. **Separate design quality from document quality.** A brilliant design can be badly documented
   and a polished document can describe a weak game. Say which problem you found.
8. **Compliance findings are flags, not legal advice.** State the rule and its date, say what it
   implies for the design, and recommend professional review where real exposure exists.

## Step 0: Intake

1. Locate the document: the argument, else `Glob` for `design/**/*.md`, `docs/design/**`, `*gdd*`.
   Also read `design/pillars.md`, `design/systems-index.md` and `.gameforge/project.json`
   (engine, phase, pillars) when present.
2. Ask **one** AskUserQuestion to set the mode (default in bold):
   - **Full review** -- all thirteen dimensions.
   - **Build-readiness gate** -- dimensions 1, 2, 5, 10, 11, 12, 13 on the sections about to be built.
   - **Focused** -- the user names the concern (scope, pillars, psychology, playtest diagnosis, compliance).
3. Note the phase. A concept-phase GDD is not penalised for missing §13 numbers; a GDD about to go
   into production is.

## The Review Rubric

| # | Dimension | Question it answers | Typical worst severity |
|---|---|---|---|
| 1 | Section completeness | Is everything needed to build present? | Critical (no core loop) |
| 2 | Pillar alignment | Does every mechanic serve a pillar? | Critical (no pillars) |
| 3 | MDA consistency | Do mechanics produce the target aesthetics? | Major |
| 4 | Player psychology | Are SDT needs and Flow supported? | Major |
| 5 | Internal consistency | Do sections agree with each other? | Critical |
| 6 | Scope feasibility | Can this team build it by this date? | Critical |
| 7 | Edge cases | What happens when players do the unexpected? | Major |
| 8 | Onboarding | Can a new player learn it unaided? | Major |
| 9 | Differentiation | Is the hook real and communicable? | Major |
| 10 | Testability for agent-built games | Could an agent build it and a test verify it? | Critical (for agent-built T1 systems) |
| 11 | Originality and IP risk | Is it the team's own game, with clean assets? | Critical |
| 12 | AI content and disclosure | What does the AI use in this design oblige? | Critical (runtime AI without guardrails) |
| 13 | Accessibility hooks | Is accessibility designed in, not bolted on? | Major (Critical for EAA-scope features) |

### 1. Section completeness

Compare against `${CLAUDE_PLUGIN_ROOT}/templates/game-design-document.md` (§1-§13) plus the
sections `game-gdd-author` appends: Direction, Technical Approach, AI Use & Originality, Scope &
Milestones. Optional but valuable: narrative, monetization, multiplayer, competitive analysis.
Record each as Present / Partial / Missing with one line on what is missing.

### 2. Pillar alignment

No pillars defined is a Critical finding. Otherwise build the matrix for every mechanic and system:

```
PILLAR ALIGNMENT MATRIX
Mechanic / system       | Consequence | Discovery | Rhetoric | Orphan?
evidence examination    | Yes         | Yes       | --       | No
witness interrogation   | Yes         | Yes       | Yes      | No
office decoration       | --          | --        | --       | YES -> cut, add pillar, or clarify
```

Also check each pillar is falsifiable (it excludes something) and served by three or more features.

### 3. MDA consistency

```
Target aesthetic | Dynamics it needs       | Mechanics that deliver | Gap?
Discovery        | exploration, revelation | hidden evidence, witness facts | OK
Challenge        | escalating skill tests  | [none after case 3]    | GAP (Major)
```
Common misalignments: Discovery with linear progression; Challenge with no mastery curve;
Expression with no player-facing tools; Fellowship in a single-player design.

### 4. Player psychology

```
SDT          | Evidence in design | Threats in design | Rating (A/B/C/F)
Autonomy     |                    |                   |
Competence   |                    |                   |
Relatedness  |                    |                   |

FLOW         | Present? | Notes
Clear goals / Immediate feedback / Challenge-skill balance / Sense of control /
Loss of self-consciousness / Time distortion
```
At least one finding in every full review must come from this dimension.

### 5. Internal consistency

Cross-check: pillars vs mechanics; core loop vs progression pacing; tone vs art and audio;
difficulty vs audience; feature scope vs team; platform vs controls; numbers in §5 vs §6 vs §9;
acceptance criteria vs rules. Quote both passages for every conflict.

### 6. Scope feasibility

Count systems and content volume (levels, enemies, items, lines of dialogue, assets), compare with
team, availability and date. Flag hidden complexity: pathfinding, procedural generation, netcode,
physics-driven gameplay, save systems, localisation, runtime AI. When the team builds with coding
agents, credit them for boilerplate and plumbing only; content, tuning, playtesting, review and
platform work do not compress the same way. Deep timeline analysis goes to `/gameforge:game-scope-check`.

### 7. Edge cases

Sequence breaks, exhausted "renewable" resources, refused mandatory systems, unintended system
interactions, extremes (max level, zero resources, simultaneous events), quitting mid-action.

### 8. Onboarding

Is the teaching sequence described? Does complexity ramp with it? Is there a "just play" entry for
players who skip tutorials? Does it teach through play rather than text walls?

### 9. Differentiation

Name the three closest comparables. For each, what is different at the experience level, not the
feature level? Is the difference mechanical or cosmetic? Can the hook be shown in a 30-second
trailer and understood in about five seconds of play?

### 10. Testability for agent-built games

Applies to every system that a coding agent will build or modify. Check:

- [ ] Each T1 system has 3+ acceptance criteria in Given / When / Then form with thresholds.
- [ ] At least two per T1 system are automatable (unit, simulation or browser test), and each says
      how it is observed.
- [ ] Feel and fun criteria are written as playtest checks with observable thresholds, not adjectives.
- [ ] Every number in the rules is a named tuning knob with default and range, in one data file.
- [ ] The design specifies state observation for tests: a state snapshot (on the web, a
      `render_game_to_text()`-style hook), deterministic stepping (`advanceTime(ms)`-style), seeded RNG.
- [ ] A project check command is named (test run, headless engine run, or Playwright suite).
- [ ] Each system has an out-of-scope list or build brief, so the agent does not add neighbours.
- [ ] No rule is defined only by reference to another game ("works like X").

A T1 system that an agent will build with no Auto checks is Critical: nobody can verify it between
playtests. Missing knobs are Major: every retune becomes another agent session and another diff.

### 11. Originality and IP risk

- [ ] The pitch stands without naming another game; comparisons stay in the overview.
- [ ] No character names, logos, level layouts, UI trade dress, music or assets taken from
      existing games; no ripped, exported or decompiled material.
- [ ] Licensed IP and fan-game status are explicit, with the licence or permission named.
- [ ] Asset sources are named for every content category (made, licensed, generated).

A design that is a renamed recreation of a specific existing game is Critical on two counts: it
is legal exposure, and as of late October 2026 Claude Code declines to build recreations of
specific existing games, so an agent-built project stalls. Recommend reframing around the genre
mechanic the designer loves plus their own twist.

### 12. AI content and disclosure

Read `${CLAUDE_SKILL_DIR}/references/compliance-and-ip.md` before scoring this dimension; it maps
design features to platform and legal obligations with dates. Check that the design states:

- [ ] Which player-facing content may be AI-generated (art, audio, voice, text, localisation,
      store and marketing assets), with a review owner and a provenance log.
- [ ] For anything generated at runtime (AI NPCs, generated quests or images): guardrails,
      player-facing disclosure, a report mechanism, and cost per player-hour, all tiered T1.
- [ ] A voice plan that covers performer consent if any synthetic or cloned voice is used.
- [ ] No reliance on tools whose licence excludes target regions or whose legal status is
      unsettled for shipped content.

Runtime AI with no guardrails or disclosure is Critical. Undecided disclosure for shipped AI
content is Major. Code written with agents is not a disclosure issue on Steam.

### 13. Accessibility hooks

- [ ] Input: full remapping, toggle alternatives to holds, no required simultaneous presses
      without an alternative, adjustable timing windows.
- [ ] Visual: colour never the only carrier of meaning, scalable text, readable contrast,
      reduced motion and flash options.
- [ ] Audio: subtitles with speaker names, visual equivalents for gameplay-critical sounds.
- [ ] Cognitive: objective reminders, pausable or adjustable timers, difficulty options.
- [ ] Purchase flows, player chat and console releases noted as European Accessibility Act scope
      (in force since 2025-06-28; microenterprise service exemption applies to some teams).
- [ ] At least one acceptance check per T1 accessibility option.

Deep audits go to `/gameforge:game-accessibility-specialist` with
`${CLAUDE_PLUGIN_ROOT}/templates/accessibility-audit.md`.

## Severity and Readiness

| Severity | Meaning |
|---|---|
| **Critical** | Blocks implementation or creates legal or platform exposure. Fix before building. |
| **Major** | Will cause significant rework or a weaker game if ignored. Fix this milestone. |
| **Minor** | Clarity or polish. Fix when convenient. |
| **Suggestion** | Not a problem; an opportunity. |

Readiness verdict (always give one, per reviewed section or for the whole document):

- **Ready to build** -- no Critical, at most two Major, all of them outside dimensions 10-12.
- **Ready with fixes** -- no Critical; Major findings have agreed owners and dates.
- **Not ready** -- any Critical finding.

## Working with AI Coding Agents

How the review fits a build that uses Claude Code or similar agents.

- **Gate before every build brief.** Run the build-readiness gate on a section before it goes to
  `/gameforge:game-vibe-code`. Anthropic's Claude Code guidance recommends a written spec and a
  check that returns pass or fail; dimension 10 is that check applied to the spec.
- **Use an agent for the mechanical sweep, then judge yourself.** Delegate: listing every number
  without a knob, every rule without a check, every term used two ways, every reference to another
  game. Keep human: severity calls, pillar and fun judgements, anything legal.
- **Independent reviewer.** A fresh session or subagent that reads only the GDD (not the
  conversation that produced it) catches assumptions the author's session absorbed. Tell it to
  check against the spec and skip prose style.
- **Review the delta, not just the plan.** When agent-built code has drifted from the GDD (extra
  mechanics, changed numbers), review the GDD against what was built and record which one wins.
  Agents are good at adding features and poor at noticing when the structure underneath must change.
- **Provenance check.** If AI-generated assets already exist, confirm they appear in the project's
  provenance log (kept by `/gameforge:game-ai-assets`); unlogged placeholders are how disclosure
  goes wrong at launch.

Prompt for the independent sweep:
```
Read design/gdd.md and design/pillars.md only. Do not edit anything. List: (1) numbers in rules
with no tuning knob, (2) T1 systems with fewer than two automatable acceptance checks, (3) terms
used with two meanings, (4) contradictions between sections, quoting both, (5) any mechanic
described only by reference to another game. Skip style comments.
```

## Output: Design Review Report

Write to `design/reviews/design-review-<YYYY-MM-DD>.md` (ask before writing) and add one line to
`production/session-state/active.md` under **Decisions** or **Next**. A filled-in example is in
`${CLAUDE_SKILL_DIR}/references/review-example.md`; read it before your first review in a session.

```markdown
# Design Review: [GDD title] v[version]
**Reviewed:** [path] | **Mode:** Full / Build-readiness gate / Focused: [topic]
**Date:** [date] | **Phase:** [from project.json] | **Reviewer:** GameForge design review

## Verdict
**[Ready to build / Ready with fixes / Not ready]** -- [one sentence why]
Biggest strength: [one line]. Most critical issue: [one line].

## Scorecard
| # | Dimension | Rating (OK / Concern / Fail / n.a.) | Findings |
|---|---|---|---|
| 1 | Completeness | | CRIT-01 |
| 2 | Pillar alignment | | |
| ... | | | |
| 10 | Testability | | MAJ-02 |
| 11 | Originality & IP | | |
| 12 | AI content & disclosure | | |
| 13 | Accessibility hooks | | |

## Findings
### Critical
- **[CRIT-01] [Title]** (§[section], dimension [n]): [what, with a quote or reference]
  **Why it matters:** [theory, risk or rule]  **Recommendation:** [specific fix]  **Owner:** [role]
### Major
- **[MAJ-01] ...**
### Minor
- **[MIN-01] ...**
### Suggestions
- **[SUG-01] ...**

## Matrices
[Pillar alignment matrix] [MDA consistency] [SDT / Flow]

## Strengths
- [What the document does well, with section references]

## Next Actions
1. [Fix CRIT-01 -- owner -- date]
2. [...]
**Suggested skills:** /gameforge:game-gdd-author ([sections]), /gameforge:game-scope-check, ...
```

## Quality Criteria

- Every finding cites a section or quote and has a severity and a recommendation.
- Pillar alignment covers every described mechanic.
- At least one finding comes from player psychology (SDT or Flow).
- Dimensions 10-13 are scored in every full review, or marked n.a. with a reason.
- Compliance findings carry the rule's date and are framed as flags, not legal conclusions.
- Strengths are listed; the review is not only problems.
- The verdict follows the readiness rules above.

## Example Requests

| Request | Focus |
|---|---|
| "Review my GDD before we start coding." | Full review; lead with Criticals and the verdict. |
| "Is §5.2 ready to hand to Claude Code?" | Build-readiness gate on that section; dimension 10 in depth. |
| "Our playtest went badly. Is it the design?" | Dimensions 3, 4, 7; use the playtest notes as evidence. |
| "Is our scope too big?" | Dimension 6; count systems and content, then route to scope-check. |
| "Should we add crafting?" | Dimension 2; if it serves no pillar it is scope creep in a feature costume. |
| "We want AI companions that chat with players." | Dimensions 12 and 13; runtime AI obligations, disclosure UX, guardrails. |
