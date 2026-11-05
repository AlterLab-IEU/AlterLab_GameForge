# Facilitation Guide and Anti-Patterns

Read for team retrospectives, for a solo developer's first retro, or when a retro keeps producing
the same findings.

## Solo developers

You are participant and facilitator. Nobody challenges your assumptions, which makes this more
important, not less. Write the answers down; reflection that is not written is forgotten by the
next sprint.

```
SOLO RETRO PROMPTS
1. What did I spend the most time on? Was it the right thing, or the comfortable thing?
2. Which task took 3x longer than estimated? Why was the estimate wrong, specifically?
3. What am I avoiding? Which part of the project do I open last? That avoidance is data.
4. How much of my time went to verifying agent output vs building? Did I plan for it?
5. Run the seven lenses. Two sentences per lens is enough.
6. Fill the Kill List. Was each cut right?
7. Excitement about the project, 1-10. Track it every retro. A downward trend that reaches 3
   means change something fundamental (scope, direction, schedule), not just push through.
8. The One Thing. Force yourself to pick one.
```

## Teams (2+ people)

The facilitator's job is to protect honesty. People self-censor in groups.

```
BEFORE
[ ] Review the previous retro and its actions
[ ] Collect playtest notes, velocity, bug counts, and the AI metrics block (agent can pre-fill)
[ ] Send the seven lenses 24 hours ahead so people arrive with findings
[ ] Set the timebox: about 15 minutes for a sprint, 45 for a milestone

DURING
[ ] Previous actions first. Accountability before new ideas.
[ ] Each lens in order: 2-3 minutes per lens for sprints, 5-7 for milestones.
[ ] The Kill List gets its own block. Do not skip it.
[ ] One voice at a time; no defending or explaining away.
[ ] When someone says "it's fine" about something that is not, ask:
    "What would you change about it if you could?"
[ ] Everyone writes The One Thing silently first, then shares. Divergent answers are informative.

AFTER
[ ] Share the document within an hour
[ ] Actions go into the next sprint backlog immediately
[ ] File the retro (production/sprints/ or production/milestones/)
[ ] Check actions mid-sprint
```

## Anti-patterns

- **The sanitized version.** Everything phrased as a positive: "we had the opportunity to learn
  about scope management" means "we cut half the game and it hurt". Say the honest version.
- **The blame retro.** "John broke the build three times" is not analysis. "There was no
  pre-merge check, so broken builds reached main" is. Redirect every blame to a system question.
- **"The agent did it."** Blaming the coding agent is the same mistake. The agent did what the
  card, the checks and the review allowed. Ask what in the inputs let the defect through.
- **Vibes verdict on agents.** "Claude was great this sprint" or "the AI code is garbage" without
  numbers. Use the Lens 7 metrics.
- **Commits as progress.** Agent sessions produce many commits. Completed Must hours and the goal
  check are progress; commit counts are activity.
- **The action graveyard.** Twelve actions last time, three done. Generate fewer and do them;
  three completed actions beat twelve abandoned ones.
- **The missing Kill List.** "We didn't cut anything." Either you overscoped silently or the
  scope was too safe. Both are worth examining.
- **The comfortable One Thing.** "We learned a lot." Push until the sentence is slightly
  uncomfortable to say out loud; that one is usually true.
- **The skipped retro.** "Too busy" is the clearest sign you need one. Fifteen minutes.
