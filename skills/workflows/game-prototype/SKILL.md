---
name: "game-prototype"
description: >
  Use when the user asks about "rapid prototyping", "testing a mechanic", "proof of concept",
  "hypothesis-driven development", "prototype evaluation", or needs to quickly validate a game
  idea before committing to full production. Part of the AlterLab GameForge collection.
---

# AlterLab GameForge -- Hypothesis-Driven Prototyping

Prototypes are experiments, not demos. Every prototype exists to answer one question: "Is this worth building?" The moment you start polishing a prototype, you have stopped prototyping and started building -- and you may be building the wrong thing. This workflow enforces a rigorous scientific approach to game prototyping: define a hypothesis, build the minimum viable test, observe real players, and make a binary kill-or-promote decision based on evidence.

### Purpose & Triggers

**Invoke this workflow when:**
- A team member proposes a new mechanic and the response should be "prove it" rather than "ship it"
- The design document contains an assumption that has never been tested with real players
- Two competing mechanic designs need a head-to-head bake-off to determine which one feels better
- A feature sounds good on paper but the team has no visceral sense of whether it will be fun
- Pre-production needs to validate core loops before committing engineering resources
- A pivot is being considered and the new direction needs rapid feasibility confirmation

**Do NOT use this workflow when:**
- The mechanic is well-understood and already validated in similar games (just build it properly)
- You need a vertical slice for stakeholder presentation (that is a demo, not a prototype)
- The question is about content, not mechanics (content questions need playtesting, not prototyping)

### Critical Rules

1. **One hypothesis per prototype.** If you are testing two things, you have two prototypes. Combining hypotheses contaminates your results -- when it fails, you will not know which part failed.
2. **Time-box or die.** Every prototype gets a strict time limit: 1-3 days maximum. If the hypothesis cannot be tested in that window, the scope is too large. Decompose it further.
3. **Prototype code is biohazard.** It does not graduate to production. Ever. It served its purpose. When a hypothesis is validated, the real implementation starts from scratch with proper architecture. Letting prototype code leak into production is how technical debt is born.
4. **Ugly is correct.** Colored rectangles for characters. Placeholder sounds. Programmer art. Comic Sans labels. If anyone comments on the visual quality of a prototype, they have misunderstood its purpose.
5. **Observe behavior, not opinions.** Players will tell you what they think you want to hear. Watch what they DO. A player who says "yeah it was fine" but leaned forward and played for 20 minutes straight is giving you different data than their words suggest.
6. **Kill without sentiment.** If the evidence says the hypothesis is false, the prototype dies. It does not matter how clever the idea was, how much you personally like it, or how much time you spent building it. Attachment to disproven ideas is the most expensive emotion in game development.
7. **Always reference `docs/game-design-theory.md`** for shared theoretical frameworks (MDA, Flow Theory, SDT) when formulating hypotheses about player experience.

### Workflow

**Step 1: Define the Hypothesis**

Write the hypothesis in this exact format: "We believe that [mechanic/system] will produce [player behavior/emotion] when [specific condition]."

Then define falsification criteria -- what evidence would DISPROVE the hypothesis? This is the most important part. If you cannot define what failure looks like, your hypothesis is unfalsifiable and therefore untestable.

Examples of strong hypotheses:
- "We believe that a grappling hook with momentum preservation will make traversal feel exhilarating when the player chains three or more swings without touching the ground."
- "We believe that asymmetric co-op roles (one player builds, one player defends) will produce emergent communication when the builder can see threats the defender cannot."
- "We believe that a stamina system with visible recovery will create tactical tension when the player faces two enemies and cannot defeat both without resting."

Examples of weak hypotheses (and why):
- "The combat will be fun" -- unfalsifiable. What is fun? Under what conditions? For whom?
- "Players will like the art style" -- this is a content question, not a mechanic question. You do not need a prototype for this.
- "The game will be better with multiplayer" -- too broad. Which specific multiplayer interaction? What does "better" mean measurably?

Map the hypothesis to the MDA framework from `docs/game-design-theory.md`: which aesthetic are you targeting (Sensation, Fantasy, Narrative, Challenge, Fellowship, Discovery, Expression, Submission)? This grounds the hypothesis in established theory and helps you define what success looks like.

**Step 2: Scope Ruthlessly**

Ask: "What is the absolute minimum implementation that tests this hypothesis?" Then cut it in half.

You do not need:
- A menu system. Start the prototype in the test scenario directly.
- Multiple levels. One room, one encounter, one situation.
- Save/load functionality. Nobody is playing this for more than 10 minutes.
- Audio. Unless audio IS the hypothesis (e.g., testing rhythm-based mechanics).
- Any UI beyond what the player needs to understand the core interaction.
- Animations. Lerp between states. Snap to positions. Teleport if you must.
- Edge case handling. If a player finds a bug in a prototype, congratulations -- they are exploring. Note it and move on.

You DO need:
- The core input-to-feedback loop working at full speed. If the hypothesis is about how a mechanic FEELS, input latency and response timing must be representative.
- Enough game state to test the hypothesis. If you are testing resource management tension, you need at least a minimal economy that creates scarcity.
- A way to reset quickly. Testers will play multiple rounds. A 30-second restart cycle kills your testing velocity.

Create a scope checklist with exactly three columns:
| Must Have (tests hypothesis) | Nice to Have (improves test clarity) | Out of Scope (save for production) |

If the "Must Have" column has more than 5 items, you have not scoped ruthlessly enough. Go back and decompose.

**Step 3: Build Dirty**

This is the only time in your career when bad code is the correct code.

- Hardcode everything. Magic numbers everywhere. No config files. No data-driven anything.
- One script file if you can manage it. No architecture. No separation of concerns. No design patterns.
- Copy-paste instead of abstracting. You are writing code that will be deleted in 72 hours.
- Use the fastest path to playable, even if that means ignoring every best practice you know.
- If your engine has a visual scripting system (Blueprints, Bolt, VisualScript), consider using it -- faster iteration for throwaway logic.
- Commit nothing to the main repository. Prototype code lives in a throwaway branch or a separate folder that will be deleted after the decision.

The build phase should consume no more than 60% of your time budget. If you are spending 2 of your 3 days building, you have 0.5 days for testing and 0.5 days for analysis. That is not enough. Target a 40/30/30 split: 40% build, 30% test, 30% analyze.

**Step 4: Structured Evaluation**

Do NOT test alone. Your own assessment of your own prototype is the least valuable data you can collect.

Minimum viable test: 3-5 people who are NOT on the development team play the prototype while you observe silently.

Observation protocol:
- **Silent observation only.** Do not explain, help, hint, or react. If the player is confused, note what confused them and why. If they are stuck, note where and let them struggle for at least 60 seconds before offering any guidance (and note that you had to intervene -- that is a finding).
- **Record everything.** Screen recording at minimum. Face camera if available. Verbal think-aloud protocol if the player is comfortable with it.
- **Track time-stamped events:** moments of visible frustration, moments of visible delight, moments of confusion, moments where the player pauses to think (strategic engagement), moments where the player disengages (checks phone, looks away).
- **Post-session questions** (keep to 3-5 questions max):
  1. "What were you trying to do?" (tests comprehension of the core mechanic)
  2. "Was there a moment that felt really good?" (identifies delight peaks)
  3. "Was there a moment that felt frustrating?" (identifies friction points)
  4. "Would you play this again?" (blunt retention signal -- their body language while answering matters more than the words)

Apply the Flow Theory lens from `docs/game-design-theory.md`: did the player appear to enter a flow state? Was the challenge-skill balance in the right zone? Did they experience anxiety (challenge too high) or boredom (challenge too low)?

**Step 5: Kill or Promote Decision**

This is a binary decision. There is no "maybe" and there is no "let's iterate on the prototype." Either the hypothesis was validated or it was not.

**KILL criteria (any one is sufficient):**
- Fewer than 2 out of 5 testers exhibited the target behavior/emotion
- The core interaction does not produce the intended feeling even when it works correctly
- The mechanic requires extensive explanation to be understood (indicates it will not onboard naturally)
- The "fun" came from a secondary interaction, not the one you were testing (the hypothesis was wrong about what would be engaging)
- Players found a degenerate strategy that makes the intended interaction unnecessary

**PROMOTE criteria (all must be met):**
- At least 3 out of 5 testers exhibited the target behavior/emotion without prompting
- The core interaction produces the intended feeling reliably, not just occasionally
- At least one tester said something equivalent to "can I play again?" unprompted
- No degenerate strategy was discovered that trivializes the core challenge
- The mechanic aligns with at least one design pillar (check against the project's vision document)

When you KILL a prototype:
- Document what you learned. The failed experiment has value -- it eliminated a possibility.
- Share the findings with the team. Failed prototypes prevent future teams from testing the same dead-end.
- Delete the prototype code. Not archive -- delete. Its purpose is served.

When you PROMOTE a prototype:
- Write a design brief for the production implementation. Specify what the prototype proved and what still needs design work.
- The production implementation starts from zero. No prototype code carries forward.
- Identify the open questions the prototype did NOT answer (there will always be some) and plan playtests to address them.

### Output Format

```
## Prototype Report: [Prototype Name]
## Date: [YYYY-MM-DD]
## Time Budget: [X days allocated, Y days used]

### Hypothesis
[Full hypothesis statement in the required format]

### Falsification Criteria
[What evidence would disprove this hypothesis]

### MDA Alignment
- Target Aesthetic: [which MDA aesthetic this tests]
- Relevant Design Pillar(s): [which project pillars this serves]

### What Was Built
[2-3 sentence description of the prototype]
[Screenshots or video links]

### Scope Decisions
| Must Have | Nice to Have | Out of Scope |
|-----------|-------------|--------------|
| [items]   | [items]     | [items]      |

### Observation Notes
| Tester | Key Observations | Delight Moments | Friction Points | Flow State? |
|--------|-----------------|-----------------|-----------------|-------------|
| P1     | [notes]         | [moments]       | [points]        | [Y/N/Partial] |
| P2     | [notes]         | [moments]       | [points]        | [Y/N/Partial] |
| ...    |                 |                 |                 |             |

### Evidence Assessment
**For the hypothesis:**
- [Observation supporting the hypothesis]
- [Observation supporting the hypothesis]

**Against the hypothesis:**
- [Observation contradicting the hypothesis]
- [Observation contradicting the hypothesis]

### Decision: [KILL / PROMOTE]
**Reasoning:** [2-3 sentences explaining the decision based on evidence]

### Lessons Learned
- [Insight 1 -- applicable beyond this prototype]
- [Insight 2]
- [Insight 3]

### Next Steps
- If KILL: [What alternative approaches might work, or what to test next]
- If PROMOTE: [Design brief summary for production implementation, open questions remaining]
```

### Quality Criteria

- **Hypothesis clarity**: Could a stranger read the hypothesis and understand exactly what is being tested? If it requires context or jargon, it is not clear enough.
- **Scope discipline**: Was the prototype built in less than 60% of the time budget, leaving sufficient time for testing and analysis?
- **Evidence quality**: Are the observations behavioral (what players DID) rather than attitudinal (what players SAID)? Behavioral evidence is worth five times attitudinal evidence.
- **Decision integrity**: Does the kill/promote decision follow logically from the evidence? Could you defend it to a skeptic using only the observation data?
- **Learning extraction**: Does the report contain at least one insight that applies beyond this specific prototype? Every experiment should teach you something about your game, your players, or game design itself.
- **Anti-pattern avoidance**: The report should explicitly note if any anti-patterns were triggered during the process (scope creep, polish temptation, prototype-to-production leak).

### Anti-Patterns to Watch For

**"Let me just clean up the prototype a bit."**
No. You are not cleaning it up. You are emotionally investing in throwaway code. Stop. If the hypothesis is validated, you will build it properly from scratch. If it is not validated, you just wasted time polishing something destined for the trash.

**"The prototype works, let's just ship it."**
No. Prototype architecture does not scale. Prototype code has no error handling, no edge cases, no accessibility, no localization hooks, no save system, no telemetry. Shipping a prototype is how you create a game that technically runs but collapses the moment you try to add content or fix bugs.

**"Let me add one more feature to the prototype."**
No. You are scope creeping. The hypothesis was defined in Step 1. If testing that hypothesis requires features you did not anticipate, either your hypothesis was poorly scoped or you are testing a different question than the one you started with. Go back to Step 1.

**"We need more data -- let's test with 20 people."**
No, not at the prototype stage. 3-5 testers is sufficient for a binary signal. If 5 people play it and the results are ambiguous, the answer is probably "kill" -- a strong mechanic is obvious even to a small sample.

**"It didn't work but I think with more time..."**
The sunk cost fallacy is the most expensive bias in game development. If 3 days could not validate the hypothesis, more time will not help. Either the hypothesis is wrong, or the scope is too large. Reformulate and try again with a tighter focus.

### Example Use Cases

1. "I want to test whether a rewind mechanic feels satisfying in a platformer. Set up a prototype hypothesis and scope for me."
2. "We have two competing designs for our combat system -- turn-based with action elements versus real-time with pause. Help me design a bake-off prototype for both."
3. "Our GDD assumes players will enjoy a base-building loop between dungeon runs, but nobody on the team has tested this assumption. Walk me through prototyping it."
4. "I built a prototype for our grappling hook mechanic and tested it with 4 people. Here are my notes -- help me analyze the results and make a kill/promote decision."
5. "We validated our core combat loop last sprint. Now I need to prototype the progression meta-layer. Help me define the hypothesis and scope."
