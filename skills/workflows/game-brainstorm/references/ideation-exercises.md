# Ideation Exercises: Full Prompts and Templates

Fill-in templates for every phase of `game-brainstorm`. Ask the questions, let the designer answer,
then fill the template with their words. Do not pre-fill answers for them.

---

## Phase 1: Creative discovery

### 1.1 Excitement inventory

```
DISCOVERY QUESTIONS (ask all, discuss the answers)
-------------------------------------------------
1. What is the last game that made you lose track of time? Why?
2. What moment in any game do you still think about years later?
3. What emotion do you most want your player to feel?
   (wonder, tension, triumph, melancholy, mischief, mastery, connection, dread, calm)
4. What non-game experience would you love to turn into play?
   (a sport, a job, a relationship dynamic, a natural phenomenon, a ritual)
5. If you could keep only ONE system from your favorite game, which one and why?
6. Which game almost got it right but fumbled? What would you fix?
-------------------------------------------------
Recurring themes across the answers: [1] [2] [3]
Target emotion: [one word]
```

### 1.2 Reference mining

```
REFERENCE MAP
-------------------------------------------------
Category   | Title           | What it contributes
-------------------------------------------------
Games      | [designer]      | [specific mechanic or feeling]
Film / TV  | [designer]      | [pacing, framing, theme]
Books      | [designer]      | [world logic, character arc]
Music      | [designer]      | [mood, rhythm, atmosphere]
Real life  | [designer]      | [system, interaction, sensation]
-------------------------------------------------
Unexpected connection worth exploring: [reference A] x [reference B]
```

### 1.3 Constraint inventory

```
CONSTRAINTS
-------------------------------------------------
Team size        | [1 / 2-5 / 6-15 / 15+]
Agents           | [coding agents do most implementation? yes/no]
Timeline         | [jam / 1-3 months / 3-12 months / 12+ months]
Hours per week   | [N]
Budget           | [zero / small / moderate / funded]
Platform         | [web / PC / console / mobile / VR / several]
Engine           | [chosen or undecided]
Art capacity     | [programmer art / asset packs / own skills / artist / AI with provenance]
Audio capacity   | [stock / freelance / own skills / AI with provenance]
Tech skill       | [beginner / intermediate / advanced]
Genre comfort    | [genres the team has shipped or prototyped]
-------------------------------------------------
```

### 1.4 Anti-inspiration

```
ANTI-INSPIRATION
-------------------------------------------------
- Which genre are you tired of?
- Which mechanic is tedious to you even when it is done well?
- Which current trend makes you roll your eyes?
- What player experience do you refuse to create?
- Which game do people keep telling you to clone, and why do you resist?
-------------------------------------------------
Refusals that will become anti-pillars: [1] [2]
```

---

## Phase 2: Concept generation

### 2.1 Verb-first

```
VERB-FIRST
-------------------------------------------------
Step 1: Pick a core verb
  build, explore, survive, negotiate, compose, rescue, deceive, cultivate,
  investigate, perform, dismantle, connect, translate, terraform, herd, balance,
  sort, steer, untangle, trade, hide, repair

Step 2: Add a constraint world
  "The player [VERB] in a world where [CONSTRAINT]."
  Example constraints:
  - gravity flips every 30 seconds
  - every action is permanent
  - you perceive one sense at a time
  - resources are emotions, not materials
  - the world is one continuous loop
  - you share a body with something that wants other things

Step 3: Immediacy test
  Is the verb fun to perform with no reason to perform it?
  Yes: strong candidate. No: find a more expressive version of the verb.
-------------------------------------------------
Concepts (one sentence each):
1. [...]
2. [...]
```

### 2.2 Mashup

```
MASHUP
-------------------------------------------------
System A (a gameplay system): tower defense, dating sim, courtroom drama,
  factory management, rhythm game, deck building, flight sim, cooking show,
  stealth, city builder, racing

Context B (unrelated): underwater archaeology, corporate espionage, ant colony
  behavior, musical composition, geological survey, political negotiation,
  night-shift hospital, beekeeping, lighthouse keeping

Force the connection:
  "What if [A] mechanics existed in a [B] context?"
  "What if [B]'s core tension were expressed through [A] play?"

  Example: falling-block packing x courtroom drama
  -> Evidence pieces fall; arrange them into an argument before the gavel.
     Misplaced evidence weakens the case; the jury reacts live.

Surprise test: does the combination create play neither source has alone?
  Yes: structural mashup, keep. No: cosmetic reskin, drop.
-------------------------------------------------
```

### 2.3 MDA-backward

```
MDA-BACKWARD
-------------------------------------------------
Step 1: Choose 2-3 target aesthetics
  Sensation, Fantasy, Narrative, Challenge, Fellowship, Discovery,
  Expression, Submission

Step 2: Dynamics that deliver each
  Discovery  -> unknown spaces, revealed information, "aha" moments
  Challenge  -> escalating difficulty, mastery curves, meaningful failure
  Expression -> customization depth, creative tools, shareable output
  Fellowship -> shared goals, complementary roles, communication pressure

Step 3: Mechanics that produce each dynamic
  "Aha" moments        -> hidden connections, environmental clues, fog of war
  Escalating challenge -> adaptive pressure, scarcity curves, enemy mixing
  Creative tools       -> modular building, palettes, player-authored levels

Step 4: Assemble
  "A game where the player [mechanic cluster] to feel [aesthetic pair]."
-------------------------------------------------
```

### 2.4 Concept comparison

```
CONCEPT COMPARISON
-------------------------------------------------
Concept | Excitement | Feasibility | Uniqueness | Team fit | Notes
-------------------------------------------------
[A]     | /5         | /5          | /5         | /5       | [trade-off]
[B]     | /5         | /5          | /5         | /5       |
[C]     | /5         | /5          | /5         | /5       |
-------------------------------------------------
Discuss trade-offs explicitly. Do not pick by total alone.
```

---

## Phase 3: Quick validation

```
VALIDATION GATES
-------------------------------------------------
Gate 1: Stranger test
  "If you saw this game's page right now, would you wishlist it / click it?"
  Five people, not on the team, not close friends. Result: [N/5]
  Fewer than 3: hook not compelling yet.

Gate 2: Two-sentence test
  Explain it to someone who does not play games.
  Result: [asked how it works / polite nod]

Gate 3: Competition test
  "What else competes for this player's money and evening?"
  Answer: [...]   Angle that avoids the giants: [...]

Closest existing games: [A] [B] [C]
The gap in one sentence: [...]
-------------------------------------------------
Fail two gates: back to Phase 2.
```

---

## Phase 4: Core loop

```
30-SECOND LOOP
-------------------------------------------------
Action:    [what the player physically does]
Feedback:  [what the game shows, plays, shakes immediately]
Reward:    [progress, resource, information, satisfaction]
Decision:  [the choice this creates]
Repeat:    [how it feeds the next action]
Naked test (no progression, unlocks, story): [fun / not yet]
-------------------------------------------------

5-MINUTE LOOP
-------------------------------------------------
Objective:   [what the player is trying to do in this window]
Escalation:  [how tension or complexity builds]
Resolution:  [boss, puzzle solved, wave cleared, trade done]
Carry-over:  [what persists into the next segment]
-------------------------------------------------

SESSION LOOP (30-60 MINUTES)
-------------------------------------------------
Session goal:   [why start a session]
Session arc:    [intensity over the session]
Session reward: [meaningful progress by the end]
Session hook:   [why come back]
Quit point:     [natural stop; never trap players]
-------------------------------------------------

PROGRESSION LOOP (FULL GAME)
-------------------------------------------------
Beginning:  [starting capability]
Middle:     [how capability, complexity or story evolves]
Mastery:    [when the player understands the systems]
Endgame:    [late game without a content drought]
Completion: [the end; post-completion content?]
-------------------------------------------------
```

Loop diagram:

```
      +--> [ACTION] --+
      |               v
 [DECISION]      [FEEDBACK]
      ^               |
      +-- [REWARD] <--+
```

---

## Phase 5: Pillars and boundaries

```
PILLAR
-------------------------------------------------
Pillar       | "Every moment is a meaningful choice"
Supports     | branching outcomes, build diversity, multiple solutions
Violates     | linear corridors, one optimal build, single right answers
Design test  | "Does this feature give the player a real decision?"
-------------------------------------------------

ANTI-PILLAR
-------------------------------------------------
Anti-pillar  | "No grinding"
Meaning      | power comes from skill and knowledge, never from repeating
             | content for small stat gains
Implication  | no XP bars, no level-gated content, no farming loops
-------------------------------------------------

BAR TEST
-------------------------------------------------
"It's a game where you [core verb] [in what context].
 The twist is [what makes it unique]."
Rules: no jargon, no "X meets Y", must provoke a follow-up question.
-------------------------------------------------
```

Weak pillars to rewrite: "fun gameplay", "beautiful art", "immersive world" (immersive how?).

---

## Phase 6: Player fit

```
BARTLE MAPPING
-------------------------------------------------
Type        | How the game serves them | Priority
-------------------------------------------------
Achievers   | [systems]                | [Primary / Secondary / Not served]
Explorers   | [systems]                | [...]
Socializers | [systems]                | [...]
Killers     | [systems]                | [...]
-------------------------------------------------

SDT CHECK
-------------------------------------------------
Need        | How the game delivers it          | Strength
-------------------------------------------------
Autonomy    | [agency, meaningful choice]       | [Strong / Moderate / Weak]
Competence  | [skill expression, mastery curve] | [...]
Relatedness | [connection, shared experience]   | [...]
-------------------------------------------------
Strong in at least one; undermines none.

EXCLUSION
-------------------------------------------------
"This game is NOT for players who want [experience], because our
 pillars prioritize [alternative] instead."
-------------------------------------------------
```

---

## Phase 7: Scope and feasibility

```
VERTICAL SLICE
-------------------------------------------------
Must include:
- the complete 30-second loop, playable
- enough content to show the 5-minute loop once
- placeholder art and audio
- one complete player decision cycle
- basic game feel (responsive controls, clear feedback)
Must NOT include:
- full progression, multiple areas, polished UI, story beyond setup,
  monetization, multiplayer (unless the core loop needs it)
-------------------------------------------------

FEATURE TIERS (MoSCoW)
-------------------------------------------------
MUST   [feature] -> serves [pillar]
SHOULD [feature] -> enhances [pillar]
COULD  [feature]
WON'T  [feature] -> why deferred
-------------------------------------------------

TIMELINE (ROUGH)
-------------------------------------------------
Phase            | Duration          | Milestone
Concept document | ~1 week           | concept reviewed
Vertical slice   | [weeks]           | core loop playable, pillar tested
Alpha            | [team-dependent]  | all Must-haves working
Beta             | [team-dependent]  | feature complete, bug fixing
Release          | [team-dependent]  | store-ready
Rules of thumb (heuristics, not data): solo about x1.5, first game about x2,
unfamiliar engine plus a few weeks; part-time teams convert to calendar time
from real available hours.
-------------------------------------------------

RISK REGISTER
-------------------------------------------------
Risk           | Probability | Impact | Mitigation
[technical]    | H/M/L       | H/M/L  | [plan]
[content]      | H/M/L       | H/M/L  | [plan]
[scope]        | H/M/L       | H/M/L  | [plan]
[team]         | H/M/L       | H/M/L  | [plan]
[market]       | H/M/L       | H/M/L  | [plan]
-------------------------------------------------
```
