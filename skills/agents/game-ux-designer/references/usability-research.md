# Usability Research for Games (UX Designer reference)

Methods, scripts, sample sizes, and the validation protocol for AI-summarized feedback. For running
full playtest sessions and surveys, pair with `/gameforge:game-playtest` and the plugin's
playtester survey template (linked from the UX Designer skill's research section).

---

## 1. Choosing a method

| Question you need answered | Method | Participants (rule of thumb) |
|---|---|---|
| Can players find and use X? | Task-based usability test | 5-8 per input type per round |
| Do players understand the rules? | Think-aloud on a fresh build | 5-6 |
| Where do players drop off? | Funnel analytics (first input, first core action, first fail, end) | All sessions |
| Is the first minute working? | Fresh-profile session recordings | 10-20 short sessions |
| What do players say they feel? | Post-session survey, short interview | 10+ for patterns |
| Can disabled players play? | Sessions with disabled testers via AbleGamers, SpecialEffect, or community partners | Per accommodation area |

Jakob Nielsen's widely cited argument (2000) that about five users find most usability problems in a
round applies to *task-based* tests of one interface, repeated over several rounds. It does not
apply to balance, difficulty perception, or preference questions, which need more players.

---

## 2. Session script (task-based, 30-45 minutes)

```
Intro (2 min): "We are testing the game, not you. Please think aloud."
Warm-up (3 min): play from the title screen without instructions. Observe only.
Tasks (20-30 min), one at a time, read aloud:
  1. "Turn the subtitles bigger."
  2. "Change which button makes you jump."
  3. "Find out what your next objective is."
  4. "Quit to the menu without losing your progress."
Probe after each task: "What did you expect to happen?" (never "Was that easy?")
Wrap-up (5 min): "What confused you? What would you change?" + survey
```

Rules: do not help unless the participant is stuck for more than about two minutes; note the
exact moment and screen of every hesitation; record screen and voice with consent.

---

## 3. Observation coding sheet

| Time | Screen | Behavior | Code | Severity | Quote |
|---|---|---|---|---|---|
| 03:12 | Settings | Opened Display looking for subtitles | WRONG-PATH | Major | "Is it under display?" |
| 05:40 | Remap | Focus disappeared after slider | FOCUS-LOST | Blocker | -- |

Codes: WRONG-PATH, HESITATE (over 5 s), MISREAD, GAVE-UP, FOCUS-LOST, INPUT-FAIL, DELIGHT.
Severity: Blocker (cannot continue), Major (continues with difficulty or help), Minor (slows down).

---

## 4. Metrics

- **Task success**: completed without help / attempts.
- **Time on task**: median, not mean (a single lost participant skews the mean).
- **Errors**: wrong paths and mis-inputs per task.
- **First-session funnel** (web): page load -> first input -> first core action -> first failure ->
  second run. Instrument with `/gameforge:game-analytics-setup`.
- **SUS-style satisfaction** questionnaires are fine for trends between rounds; do not compare scores
  across different games.

---

## 5. Validating AI-summarized feedback

Feedback summarizers (FirstLook, Accord, or an LLM prompt over exported reviews and Discord threads)
publish no accuracy benchmarks. Treat their output as a hypothesis and validate it on your own data
before it changes the roadmap.

**Protocol**
1. **Freeze the input**: export the exact corpus (reviews, posts, survey answers) with IDs and dates.
2. **Run the summary** and save it with the tool name, version or model, prompt, and date.
3. **Hand-code a random sample**: at least 10% of items or 50 items, whichever is larger (rule of
   thumb), coded by a person who has not read the summary.
4. **Compare themes**: for each summarized theme, does it appear in the hand-coded sample at a
   similar rate? Mark each as confirmed, overstated, understated, or not found.
5. **Check evidence**: every quote the summary cites must exist verbatim in the corpus. Fabricated
   or merged quotes invalidate the summary.
6. **Look for what it dropped**: list hand-coded issues the summary missed. Pay special attention to
   low-frequency, high-severity reports (accessibility barriers, crashes on one device, payment
   problems) that frequency-based clustering hides.
7. **Decide**: act on confirmed themes; re-run or hand-code more for overstated ones; add the missed
   blockers to the backlog directly.

**Report block**
```
Summary source: [tool/model], [date], corpus = [N] items ([sources], [date range])
Hand-coded sample: [n] items, coder [name]
Themes: confirmed [x] | overstated [y] | understated [z] | not found [w]
Quotes verified: [k/k]   Missed issues added: [list with item IDs]
Decision: [what changes, owner]
```

**Prompting tips when you run the summary yourself**
- Ask for item IDs next to every theme and every quote.
- Ask for counts per theme and a list of single-mention issues flagged as possible blockers.
- Ask it to separate "bug", "usability", "balance", "content request", and "praise".
- Never paste personal data the players did not publish; strip usernames from private surveys.

---

## 6. Testing with disabled players

- Recruit through organizations and communities, pay participants, and ask what assistive
  technology and setup they use; let them bring their own.
- Test the accommodations they actually use (their remaps, their screen reader, their contrast
  settings), not your idea of them.
- Share findings with `game-accessibility-specialist`; barriers found here outrank aesthetic issues.

---

## 7. Turning findings into changes

| Finding | Becomes |
|---|---|
| Blocker in a flow | Spec change + regression test (Playwright or engine test) before next build |
| Repeated wrong path | Information architecture change (rename, move, or duplicate the entry point) |
| Misread icon | Label added or icon redesigned with the art director; re-test |
| Drop-off before first input | Load budget or title-screen change; re-measure the funnel |
| AI-summary theme not confirmed | No change; note it in the report so it does not resurface as fact |
