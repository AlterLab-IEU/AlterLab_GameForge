---
name: game-brainstorm
description: >
  Runs designer-led ideation that turns a mood, theme, genre or "something like X" into three
  original concepts and one chosen Game Concept Document with core loop, pillars, player fit and
  scope, plus 5-10 minute web or jam hooks. Use for "game idea", "brainstorm", "pitch", "what should
  I make", "a game like X". Not for market sizing (use game-market-research).
argument-hint: "[theme, genre, 'like <game>', 'web hook', or 'open']"
effort: medium
allowed-tools: Read, Glob, Grep, Write, AskUserQuestion
---

# AlterLab GameForge -- Structured Ideation Workflow

Most game ideas die from lack of structure, not lack of creativity. A notebook of "what if" lines
never becomes a game without deliberate shaping. This workflow takes raw interest through seven
phases that alternate between divergent thinking (expand) and convergent thinking (decide), and ends
with an original concept a team, or a team of one plus coding agents, can build.

It is a conversation, not a form. Claude brings structure, provocations and options; the designer
makes every decision. Early phases have no wrong answers. By the end, every answer has survived
player psychology, a quick reality check, and honest scope.

**Continuity through files.** Read `.gameforge/project.json` (engine, phase, existing pillars),
anything in `design/`, and `production/session-state/active.md` before starting. Write the result to
`design/concept.md` (or `design/concepts/<slug>.md` when comparing several) and update `active.md`
with the decision and the next step.

## When NOT to use me

| The user wants... | Route to |
|---|---|
| Market size, comparable titles, positioning with real data | `/gameforge:game-market-research` |
| Feedback on a design document that already exists | `/gameforge:game-design-review` |
| A full GDD written section by section | `/gameforge:game-gdd-author` |
| To test whether a mechanic is fun | `/gameforge:game-prototype` |
| A jam: theme just dropped, clock running | `/gameforge:game-jam-mode` (its 20-minute theme step replaces this skill) |
| To build the chosen hook tonight with an agent | `/gameforge:game-vibe-code` |
| Vision and pillars for a game already in production | `/gameforge:game-creative-director` |

## Choose a mode

Ask with one AskUserQuestion at the start (skip if the argument makes it obvious):

| Mode | When | Time | Output |
|---|---|---|---|
| **Full concept session** (default for commercial projects) | Starting a real project | 1-3 hours, can span sessions | Game Concept Document |
| **Fast lane: web hook** | Weekend, portal or AI-friendly jam game; "playable tonight" | 20-40 minutes | Three concept cards, one chosen, handed to `/gameforge:game-vibe-code` |
| **"A game like X"** | The user names an existing game | +10 minutes | Originality protocol first, then either mode |
| **Genre pack variant** | Roguelike/roguelite or narrative-driven game | Adds to either mode | Genre-specific prompts layered on Phases 1-4 |

## Critical Rules

1. **The designer decides.** Offer options, frameworks and provocations; never hand over a finished
   concept as if it were theirs. Even in the fast lane, present three and let them choose.
2. **Emotions before features.** "What should the player feel?" comes before "what do they press?"
3. **Constraints are fuel.** Team, time, budget, platform and skills shape the concept from minute
   one, not at the end.
4. **The 30-second loop must be fun naked.** Strip progression, story and unlocks; if the moment-to-
   moment loop is not engaging on its own, no content will save it.
5. **No precious ideas.** A concept that fails a later phase is discarded or reshaped. Kill concepts
   here, not six months into development.
6. **Original IP only.** Genre mechanics are free to use; another game's names, characters, art,
   music, levels, story and recognizable look are not. "Clone X" becomes an original design that
   keeps the mechanic the user loves (see the Originality Guardrail below).
7. **Honest scope.** Twenty enemy types with one part-time artist is a finding, not a detail.
8. **Use the shared theory.** MDA, Self-Determination Theory, Bartle types and Flow are defined in
   `${CLAUDE_PLUGIN_ROOT}/docs/game-design-theory.md`. Point there; do not reinvent definitions.

## Step 0: Context and constraints

Read the project files listed above. Then capture constraints in one AskUserQuestion round (offer
defaults; skip what `project.json` already answers):

| Constraint | Options |
|---|---|
| Team | Solo / 2-5 / 6+ (and whether coding agents do most of the implementation) |
| Time | Jam or weekend / 1-3 months / 3-12 months / 12+ months |
| Platform | Web / PC (Steam) / console / mobile / several |
| Art and audio capacity | Programmer art / own skills / asset packs / dedicated artist / AI-generated with provenance |

## The seven phases

Full prompts and fill-in templates for every exercise are in
`${CLAUDE_SKILL_DIR}/references/ideation-exercises.md`. Read the relevant section before running a
phase; below is the purpose, the deliverable and the judgment calls.

### Phase 1: Creative discovery (diverge)

*Goal: find what genuinely excites the designer before touching mechanics.*

- **Excitement inventory:** the game that made them lose track of time, a moment they still think
  about, the emotion they most want to create, a non-game experience worth translating.
- **Reference mining** across games, film, books, music and real life. Unexpected connections (the
  pacing of a film with the system logic of a real job) beat "X but with guns."
- **Constraint inventory** (from Step 0).
- **Anti-inspiration:** what they are tired of, mechanics they find tedious, what they refuse to make.

Deliverable: three to five recurring themes and one target emotion. Ask, listen, reflect the themes
back; do not rush to concepts.

### Phase 2: Concept generation (diverge)

*Goal: three to five distinct concepts from at least two different techniques.*

| Technique | Prompt | Strength |
|---|---|---|
| **Verb-first** | "The player [verb] in a world where [constraint]." Test: is the verb fun with no reason to do it? | Strong moment-to-moment play |
| **Mashup** | System A from one genre in context B from an unrelated field; keep only combinations that change the play, not just the skin | Novel hooks |
| **MDA-backward** | Pick 2-3 target aesthetics, derive the dynamics that produce them, then the mechanics | Psychologically grounded concepts |
| **Fast-lane generators** | Toy-first, one-screen, share-moment and constraint-twist tables | 5-10 minute web hooks |

The fast-lane generators are in `${CLAUDE_SKILL_DIR}/references/web-hook-generators.md`.

Compare the candidates (Excitement, Feasibility, Uniqueness, Team fit, each out of 5). Do not just
add the scores: a 5/2 on excitement and feasibility deserves a different conversation than a 3/3.
Name the trade-off and let the designer pick.

### Phase 3: Quick validation (converge)

*Goal: a cheap reality check before investing in loops and pillars.*

Three gates. Failing two sends the concept back to Phase 2.

1. **Stranger test.** Describe it to five people outside the team and outside your friends. Would
   they wishlist it, or click it on a portal? Fewer than three yes means the hook is not compelling
   yet.
2. **Two-sentence test.** Explain it to someone who does not play games. Do they ask "how does that
   work?" or nod politely?
3. **Competition test.** What else competes for this player's money and evening? If the answer is a
   free-to-play giant or a franchise with a sequel coming, sharpen the angle.

Also name the three closest existing games and the one-sentence gap this concept fills. Real market
data (comparables, revenue estimates, saturation, 2026 store conditions) belongs to
`/gameforge:game-market-research`; offer it for any commercial project.

### Phase 4: Core loop (converge)

*Goal: the heartbeat of the game at four timescales, each a full cycle of action, feedback, reward
and decision.*

| Timescale | Question | Fast lane needs it? |
|---|---|---|
| 30 seconds | What does the player do, see and decide? Fun with no progression? | Yes |
| 5 minutes | What sub-goal shapes a play window, and how does it escalate and resolve? | Yes (this is the whole game) |
| Session (30-60 min) | Why start, what is gained, where is the natural stop? | No |
| Full game | Beginning, mastery, endgame, completion | No |

Draw each loop as a cycle. A list that does not return to its start is a sequence, not a loop.

### Phase 5: Pillars and boundaries (converge)

*Goal: 3-5 falsifiable pillars and the anti-pillars that let the team say no.*

A good pillar is falsifiable, distinct, memorable and decides arguments: "The world reacts to
everything", "Failure teaches, never punishes", "Every resource has two uses." "Fun gameplay" and
"beautiful art" guide nothing. Document with `${CLAUDE_PLUGIN_ROOT}/templates/game-pillars.md` and,
with the user's OK, write them to `pillars` in `.gameforge/project.json`.

Finish with the bar test: two sentences, no jargon, no "X meets Y", and it must provoke a follow-up
question.

### Phase 6: Player fit (converge)

*Goal: the concept serves identifiable motivations.*

- **Bartle mapping:** which of Achievers, Explorers, Socializers, Killers are primary, secondary, or
  not served.
- **SDT check:** strong in at least one of autonomy, competence, relatedness; undermines none.
- **Exclusion statement:** "This game is not for players who want [X], because our pillars
  prioritize [Y]." Focus, not gatekeeping.

### Phase 7: Scope and feasibility (converge)

*Goal: the concept survives contact with the team's real capacity.*

- **Vertical slice:** the complete 30-second loop, the 5-minute loop once, placeholder art, basic
  game feel. No progression system, no multiple areas, no monetization.
- **Feature tiers (MoSCoW):** Must / Should / Could / Won't. The Won't list matters as much as the
  Must list.
- **Timeline:** rough phases with rules-of-thumb buffers (solo developer about 1.5x, first game about
  2x, unfamiliar engine plus a few weeks of ramp-up). These are planning heuristics, not data.
- **Top five risks** (technical, content, scope, team, market) with a mitigation each.

Deeper scope checks go to `/gameforge:game-scope-check`.

## The Originality Guardrail

When the user names an existing game ("make Stardew in space", "a Slay the Spire clone"), do not
refuse and stop, and do not design the clone. Turn it into an original concept that keeps what they
love. This is also practical: Claude Code declines to build recreations of specific existing games
(a rule added around late October 2026), and rights holders act, as Activision's October 2026 DMCA
takedowns of AI-built Call of Duty browser ports showed.

**Protocol (about 10 minutes):**

1. **Extract the loved part.** Ask what exactly they love: the core verb, the progression shape, the
   feel, the social dynamic, or the theme.
2. **Name it in genre terms.** "Seasonal farming with relationship calendars", "deck-building run
   with a branching map", "hidden-role deduction in short rounds." Genre mechanics are shared
   vocabulary; rules and systems are generally not protected by copyright, while expression is.
3. **Separate free from protected.** Free: the genre mechanic, the general structure. Not free: names,
   characters, story, art, music, sound, level layouts, UI look and the overall recognizable
   presentation. Copying a game's look, not just its rules, is what lost the defendant *Tetris
   Holding v. Xio Interactive* (D.N.J. 2012). This is design guidance, not legal advice.
4. **Change at least three things:** the fantasy, the art direction, and at least one core rule, so
   the design stands on its own.
5. **Generate three original variants** and run them through Phase 2's comparison.

| Request | Keep (the loved mechanic) | Original variants |
|---|---|---|
| "Stardew Valley but in space" | Seasonal crop cycle, calendar pressure, slow relationships | A tide-pool keeper on a moon with a 28-day tide: plant in the low-water window, trade with drifting barge families |
| "A Slay the Spire clone" | Deck-building run, branching map, persistent relics | A night-bus driver whose deck is the route; cards are stops, passengers are relics with opinions |
| "Among Us for my friends" | Hidden roles, short rounds, discussion and vote | Museum night guards; one is the forger swapping paintings; votes happen at the coffee machine |

Record the closest existing games and what is different in the concept document's "Originality"
section. Original art and audio follow the same rule: the user's own assets, licensed packs, or
generated assets logged through `/gameforge:game-ai-assets`.

## Fast lane: hooks for 5-10 minute web games

Small web games live or die on the first five seconds. The 2026 Vibe Jam winners were 5-10 minute
games with one clear idea, and the vendor guides that followed agree on the same shape: one hook a
player understands in about five seconds, one mechanic, near-instant load, no login. Use the
generators in `${CLAUDE_SKILL_DIR}/references/web-hook-generators.md`, then hold every candidate to:

| Test | Pass condition |
|---|---|
| Five-second read | A stranger watching a 5-second clip can say what to do |
| One-screen | The core loop fits on one screen, no tutorial text |
| Ten-minute arc | There is an escalation and an end state inside ten minutes |
| Share moment | Something worth a screenshot, a clip or a score |
| Input | Works with mouse or touch alone, or with a few keys |
| Load | No mandatory backend or account; static hosting is enough |

Produce three concept cards (template below), let the user pick one, and hand it to
`/gameforge:game-vibe-code` with the card as the starting spec. Background on what ships and
what fails in agent-built games: `${CLAUDE_PLUGIN_ROOT}/docs/vibe-coding.md`. For a jam, the card goes into the
jam concept sheet instead (`/gameforge:game-jam-mode`).

## Genre pack variants

If the concept is a roguelike or roguelite, read
`${CLAUDE_PLUGIN_ROOT}/genre-packs/roguelike/brainstorm-variant.md`; if it is narrative-driven, read
`${CLAUDE_PLUGIN_ROOT}/genre-packs/narrative/brainstorm-variant.md`. Layer their prompts onto Phases
1-4 (run identity and persistence for roguelikes; central question and emotional arc for narrative
games). Other packs follow the same `brainstorm-variant.md` layout inside the plugin's `genre-packs/`
directory; Glob for them before starting.

## World models and AI imagery: mood and pitch only

World models generate explorable video-like scenes from a prompt or image. As of November 2026 none
is a production engine:

| Model | Status (as of 2026-11-05) | Useful for |
|---|---|---|
| Google DeepMind Genie 4 | Research preview (2026-10-27): native audio, mid-session prompt steering, roughly two minutes of consistency; Google acknowledges drift and illegible in-world text | Feeling out a mood or a traversal fantasy |
| Project Genie | US-only, AI Ultra subscribers, 60-second sessions (since 2026-01-29) | The same, briefly |
| Microsoft Muse / WHAM | Research model (Feb 2025), low-resolution output, positioned for gameplay ideation | Ideation experiments |
| World Labs Marble | Exports Gaussian splats and GLB meshes (export needs the paid plan) | Spatial reference for a greybox |

Rules: a world-model clip proves nothing about whether a loop is fun (only a prototype does); never
let generated imagery set the art direction by default (that is `/gameforge:game-art-director`'s
call); and anything that reaches players, including trailers and store art, counts as AI content
for Steam disclosure. Log what you generated, with which tool and when.

## AI-Assisted Workflow

Brainstorming is the most common generative-AI use among game developers who use it at all (81% of
users in the GDC 2026 State of the Industry survey), while 52% of all respondents said generative AI
is harming the industry. Use the speed; protect the authorship and the audience's trust.

- **Delegate to Claude:** volume (20 verbs, 15 mashups, 10 constraint twists), devil's-advocate
  critique, "which existing games is this closest to?" checks, filling templates from the designer's
  answers, summarizing a long session into the concept document.
- **Keep human:** choosing the target emotion, picking among concepts, pillars, and the final pitch
  wording. US copyright protection requires human authorship; prompts alone are not enough, so the
  design decisions should visibly be the designer's.
- **Fight the median idea.** Model suggestions cluster around the most familiar genre takes. Ask for
  distance explicitly: "Give me five versions that a player of this genre would not expect, and say
  what convention each one breaks."
- **Critique before building.** "Research and critique this concept as a skeptical player with five
  minutes to spare. Do not suggest fixes yet." Then fix.
- **Test the loop, not the pitch.** A one-hour agent-built prototype of the 30-second loop answers
  more than another hour of talk: `/gameforge:game-prototype`, or `/gameforge:game-vibe-code` in the
  fast lane.
- **Decide the AI stance early** if generated art, audio or voice is on the table:
  `${CLAUDE_PLUGIN_ROOT}/templates/ai-content-policy.md`, then `/gameforge:game-ai-assets`.

Useful prompts:

```
List 15 verbs that are satisfying with a mouse alone. For each, one sentence on why the verb
itself is fun, with no story reason.

Here are my three concepts. For each, name the three closest existing games and the single
rule that most separates mine from them. Be blunt if the separation is cosmetic.
```

## Output Format

### Game Concept Document (full session)

Save as `design/concept.md`; the full template is `${CLAUDE_PLUGIN_ROOT}/templates/game-concept.md`.

```markdown
# Game Concept: [Working title]
**Date:** [YYYY-MM-DD]   **Designer:** [name]   **Mode:** Full session
**Genre:** [genre or blend]   **Platform:** [primary]   **Team:** [size, agents yes/no]

## Pitch
**Two sentences:** [bar-test version]
**Target emotion:** [one word, from Phase 1]
**Unique hook:** [the one rule or fantasy nobody else has]

## Originality
**Closest existing games:** [A], [B], [C]
**What is different:** [fantasy / art direction / rule changes]
**Assets:** [own / licensed packs / AI-generated, logged in the provenance log]

## Core loop
- 30 s: [action -> feedback -> reward -> decision]
- 5 min: [objective -> escalation -> resolution -> carry-over]
- Session: [goal, arc, natural stop]
- Full game: [start, mastery, end]

## Pillars and anti-pillars
| Pillar | Supports | Violates | Design test |
|---|---|---|---|
| [The world reacts to everything] | [...] | [...] | [Does this feature react?] |
**Anti-pillars:** [No grinding: power comes from skill and knowledge]

## Player fit
**Primary motivations:** [Bartle + SDT summary]   **Not for:** [exclusion statement]

## Quick validation
| Gate | Result | Notes |
|---|---|---|
| Stranger test | [4/5 yes] | |
| Two-sentence test | [pass] | |
| Competition test | [pass, angle: ...] | |

## Scope
**Vertical slice:** [contents]   **Won't have in v1:** [list]
**Timeline (rough):** [phases and buffers]
**Top risks:** [risk -> mitigation] x5

## Next steps
1. [/gameforge:game-prototype to test the 30-second loop]
2. [/gameforge:game-market-research for comparables]
```

### Concept card (fast lane, three per session)

```markdown
## [Title]: [hook in one line a player gets in 5 seconds]
- **Verb:** [one]    **Input:** [mouse / touch / 3 keys]
- **10-minute arc:** [start -> escalation -> end state]
- **Share moment:** [what gets screenshotted or posted]
- **Generator used:** [toy-first / one-screen / constraint twist / share-moment]
- **Closest games and the difference:** [A, B; we differ by ...]
- **Done when:** [a stranger finishes a run and asks to play again]
- **Stack guess:** [Three.js / Phaser 4], static hosting, no login
- **Next:** /gameforge:game-vibe-code "[hook]"
```

## Quality Criteria

- The designer made the creative decisions; Claude supplied structure and options.
- At least three distinct concepts were generated before one was chosen.
- The 30-second loop passes the "fun without progression" test, at least on paper.
- The concept is original: closest games named, differences concrete, no borrowed names or art.
- Pillars are falsifiable and the Won't-have list exists.
- Scope matches the constraints from Step 0; risks are named honestly.
- A developer who missed the session could read the document and know what to build.
- Framework terms match `${CLAUDE_PLUGIN_ROOT}/docs/game-design-theory.md`.

## Example Use Cases

1. **"I want to make a game but have no idea what kind."** Full session from Phase 1; the excitement
   inventory surfaces themes, Phase 2 turns them into concepts.
2. **"Give me a hook for a browser game I can build this weekend with Claude."** Fast lane: three
   concept cards from the generators, pick one, hand to `/gameforge:game-vibe-code`.
3. **"I love Hades and Slay the Spire; I want something in that space."** Originality protocol plus
   the roguelike pack variant; the loved part is "build-defining choices each run", the fantasy and
   rules change.
4. **"My team wants to pick our next project."** Full session with the concept comparison matrix as
   the group decision tool; market data from `/gameforge:game-market-research` before committing.
5. **"I keep starting projects and abandoning them."** Emphasize Phase 5 (pillars give permission
   to say no) and Phase 7 (a finishable vertical slice).
