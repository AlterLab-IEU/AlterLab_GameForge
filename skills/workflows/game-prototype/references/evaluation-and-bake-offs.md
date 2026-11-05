# Evaluation, Bake-Offs and Solo Testing

Detailed protocols for Steps 5 and 6 of `game-prototype`. The aim is behavioral evidence that a
skeptic would accept, gathered in a few hours.

---

## 1. Observation protocol

**Before the session**
- Recording works (test it on a dummy run before the prototype exists).
- The build starts directly in the test scenario; restart is one key.
- You have a sheet with columns: timestamp, event type, note.

**During the session**
- Say only: "Play this however you like. I can't help, but I'll answer questions afterwards."
- Do not explain, hint, react or laugh along. Your face is a tutorial.
- Log, with timestamps:

| Event | What it looks like |
|---|---|
| Delight | Smile, exclamation, leaning in, immediate retry |
| Frustration | Sighs, repeated failure at the same spot, button mashing |
| Confusion | Long idle, random inputs, looking at you |
| Strategic pause | Stops moving, scans the screen, then acts decisively |
| Disengagement | Checks phone, looks away, slows down |
| Intervention | You had to say something (always a finding) |

- If a player is stuck, wait at least 60 seconds before intervening.

**After the session (three to five questions, no more)**
1. "What were you trying to do?" (comprehension of the core mechanic)
2. "Was there a moment that felt really good?" (delight peaks)
3. "Was there a moment that felt frustrating?" (friction)
4. "Would you play again?" (watch how they answer, not just the words)

**Flow lens** (definitions in `${CLAUDE_PLUGIN_ROOT}/docs/game-design-theory.md`): did the player
show anxiety (challenge above skill), boredom (skill above challenge), or absorption?

Behavioral evidence outranks attitudinal evidence. A tester who says "it was fine" but played 20
minutes without looking up is telling you something different from their words.

## 2. MDA aesthetic signal table

Use it to make the hypothesis observable. If the hypothesis maps to several rows, split it.

| Aesthetic | The prototype tests | Signal to look for |
|---|---|---|
| Sensation | Moment-to-moment feel, juice, responsiveness | Unprompted comments on how something feels; leaning forward |
| Fantasy | Role embodiment | "I" language: "I felt powerful when I..." |
| Narrative | Story comprehension and investment | Asks what happens next; decides by story logic |
| Challenge | Difficulty and fair failure | Immediate retry; "I almost had it" |
| Fellowship | Social interaction | Spontaneous call-outs, negotiation, laughter |
| Discovery | Exploration drive | Leaves the critical path voluntarily |
| Expression | Creativity and identity | Choices that express taste rather than optimize |
| Submission | Calm, rhythmic engagement | Quiet, relaxed, steady pace |

## 3. Bake-off protocol

When two designs compete, test them simultaneously, not one after the other; sequential tests mix
in tester mood, team familiarity and outside events.

**Setup**
1. Build both to the same minimum scope. With agents, build them in parallel from the same
   `QUESTION.md`, with identical hooks, restart key and tuning names; diff the folders to confirm
   only the design variable differs.
2. At least three testers per variant (six total). Each tester plays one variant only.
3. Identical observation sheet and debrief questions for both groups.
4. Blind the debrief where possible: the person asking questions does not know which variant the
   tester played.

**Analysis**
- Compare behavioral data first: flow duration, hesitation counts, interventions, delight peaks.
  Verbal data second.
- A clearly stronger behavioral signal wins, whatever the team prefers.
- Inconclusive (both similar) means the variants were not different enough. Sharpen both and rerun;
  do not average them into a compromise.
- Document both. The loser often teaches more than the winner.

**Do not** let the team vote after watching. Authorship bias contaminates preference.

## 4. Solo developer adaptation

You cannot observe yourself objectively. Workarounds, in order of value:

1. **Three external testers, no exceptions.** Friends, family or a local or online dev community
   still beat self-testing.
2. **Remote sessions.** A private itch.io page or a static link plus a screen-shared call (OBS,
   Discord). Remote testers lose face-camera data but give honest cold starts.
3. **Record yourself and review the next day.** Watch the recording as if it were a stranger.
4. **Time-shifted self-test.** Wait 48 hours before playing your own build; memory fades enough to
   approximate a new player. Weakest option; use it only in addition to the above.
5. **Budget overhead.** You carry design, build, facilitation and analysis, so a "3-day" prototype
   is closer to 2 days of focused work. Plan the box accordingly (a rule of thumb, not data).

## 5. AI playtest agents

Vendor tools (for example modl.ai and nunu.ai) and engine MCP test runners can drive a build to check
reachability, crashes and softlocks at volume. None publishes accuracy benchmarks for judging fun or
comprehension. Use them as a pre-flight check before human sessions, never as the evidence for a
kill-or-promote decision about feel.

## 6. Anti-patterns

| You hear | Why it is wrong | Do instead |
|---|---|---|
| "Let me just clean up the prototype a bit." | Emotional investment in throwaway code | Stop. Promote means a clean rebuild from a spec |
| "The prototype works, let's ship it." | No error handling, accessibility, save system, telemetry; collapses under content | Write the production brief |
| "One more feature in the prototype." | Scope creep; you are now testing a different question | New question, new prototype |
| "We need 20 testers." | Three to five gives a binary signal; ambiguity at five usually means kill | Decide, or sharpen the hypothesis |
| "It didn't work, but with more time..." | Sunk cost | Reformulate with a tighter question |
| "The agent says all tests pass." | Claims are not evidence | Read the output; open the screenshot; play it |
| "The AI art looks good enough to keep." | Placeholders leak into public builds | Review it as a final asset through `/gameforge:game-ai-assets`, or replace it |

## 7. Pre-build checklist

- [ ] The question and the decision it drives are written in `QUESTION.md`.
- [ ] Hypothesis in the required form, with at least two falsification signals.
- [ ] One MDA aesthetic named.
- [ ] Time box with a fixed end, not "when it feels done".
- [ ] Must / Nice / Out lists filled; at most five Must items.
- [ ] Testers booked (names and times) before building.
- [ ] Recording tested.
- [ ] Throwaway branch and `prototypes/<name>/` folder created.
- [ ] `AI-USE.md` created if any generated asset will be used.
